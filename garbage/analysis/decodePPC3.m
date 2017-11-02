 % Fetch session list - run only if sessionData struct lost
key = acq.Sessions('session_datetime > "2013-06-01"');
sessionData=fetch((class_discrimination.ClassDiscriminationExperiment * ephys.SpikesAlignedSet) & key);

hSession=waitbar(0,sprintf('Completed session %d out of %d',0,length(sessionData)));
h=waitbar(0,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
for idxSess=1:length(sessionData)
    session=sessionData(idxSess);
    info=fetch(acq.Sessions & session,'*');
    date=info.session_datetime;
    trial_info=fetch(class_discrimination.ClassDiscriminationTrial & session, '*');
    
    
    waitbar(0,h,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
    for i = 1:length(trial_info)
        spikes = fetch(ephys.SpikesAlignedTrial & trial_info(i), 'spikes_aligned');
        trial_info(i).counts = arrayfun(@(x) sum(x.spikes_aligned > 0 & x.spikes_aligned < 500), spikes);
        waitbar(i/length(trial_info),h, sprintf('Fetching Recording Data (%2.2f%% complete)',i/length(trial_info)*100));
    end
    sessionData(idxSess).trial_info=trial_info;
    sessionData(idxSess).date=date;
    waitbar(idxSess/length(sessionData),hSession,sprintf('Completed session %d out of %d',idxSess,length(sessionData)));
end
close(h);
close(hSession);

%% Specify session number
for sessionNum = 1:1%length(sessionData)
    fprintf('Working on session %d...\n',sessionNum);
    %
    % units = [1 2 3 7, ...
    %         11 13 14 15 17 18 19 21 24 29 30, ...
    %         41 44 46 47 51 52 53 54 55 56 57 58 61 62 63 64  66 67 68, ...
    %         73 74 75 80 82 84 85 86 89 91 92 93];
    trialInfo=sessionData(sessionNum).trial_info;
    
    all_counts = cat(2,trialInfo.counts);             
    all_orientation = [trialInfo.orientation];
    all_orientation=mod(all_orientation,180)+180;
    all_contrast = [trialInfo.contrast];
    all_resp = {trialInfo.selected_class};
    
    contList = sort(unique(all_contrast));
    contPrior = ones(size(contList)) ./ length(contList);
    ind = (all_contrast == contList(end));
    
    decodeOri = [220:0.5:320];
    sigmaA = 3;
    sigmaB = 15;
    
    sCenter = 270;

    N = 10; % N way cross validation
    trialInd = randperm(length(trialInfo));
    splits = round(linspace(0,length(trialInfo),N+1));
    
    clear cvResults;
    cvResults.decodeOri = decodeOri;
    cvResults.contList = contList;
    cvResults.contPrior = contPrior;
    cvResults.N = N;
    cvResults.trialPerm = trialInd;
    cvResults.splits = splits;
    clear cvData;

    for ind = 1 : N
        fprintf('Processing %d out of %d CV\n',ind, N);
        testInd = trialInd(splits(ind)+1:splits(ind+1)); % pick test sets
        trainInd = trialInd([1:splits(ind), splits(ind+1)+1:end]); % pick trials sets

        % build training set
        train.counts = all_counts(:, trainInd);            
        train.orientation = all_orientation(trainInd);
        train.contrast = all_contrast(trainInd);
        train.resp = all_resp(trainInd);
        
        fprintf('Training tuning curves...\n');
        % train tuning curves and obtain likelihood
        gpCurve = ClassifierModel.CoderDecoder.ContrastAdjustedGPDPCEncoder(96);
        gpCurve.train(train.orientation, train.contrast, train.counts);
        pnCodec = ClassifierModel.CoderDecoder.PoissonNoisePPCodec(gpCurve);
        logLAll = pnCodec.getLogLikelihood(train.orientation, train.contrast, train.counts);
        unitLL = mean(logLAll, 2);
        goodUnits = (unitLL > -3);
        pnCodec.baseEncoder = gpCurve.restrict(goodUnits);
        train.L = pnCodec.getLikelihoodDistrWithContrastPrior(decodeOri, contList, contPrior, train.counts(goodUnits, :));

        % train models
        
        fprintf('Training models...\n');
        nb = ClassifierModel.LikelihoodClassifier.BPLNB2LikelihoodClassifier(sigmaA, sigmaB, sCenter);
        nbTrainLL = nb.train(decodeOri, train.L, train.resp, 30);
        bpl = ClassifierModel.LikelihoodClassifier.BPL4LikelihoodClassifier(sigmaA, sigmaB, sCenter);
        bplTrainLL = bpl.train(decodeOri, train.L, train.resp, 30);
        fl = ClassifierModel.LikelihoodClassifier.FullLikelihoodClassifier2(sigmaA, sigmaB, sCenter);
        flTrainLL = fl.train(decodeOri, train.L, train.resp, 30);




        % TEST
        
        fprintf('Testing models...\n');
        test.counts = all_counts(:, testInd);            
        test.orientation = all_orientation(testInd);
        test.contrast = all_contrast(testInd);
        test.resp = all_resp(testInd);

        test.L = pnCodec.getLikelihoodDistrWithContrastPrior(decodeOri, contList, contPrior, test.counts(goodUnits, :));
        
        cvData(ind).trainSet = train;
        cvData(ind).testSet = test;
        cvData(ind).pnCodec = pnCodec;
        cvData(ind).goodUnits = goodUnits;
        cvData(ind).nb = nb;
        cvData(ind).nbTrainLL = nbTrainLL;
        cvData(ind).nbTestLL = nb.getLogLikelihood(decodeOri, test.L, test.resp);
        cvData(ind).bpl = bpl;
        cvData(ind).bplTrainLL = bplTrainLL;
        cvData(ind).bplTestLL = bpl.getLogLikelihood(decodeOri, test.L, test.resp);
        cvData(ind).fl = fl;
        cvData(ind).flTrainLL = flTrainLL;
        cvData(ind).flTestLL = fl.getLogLikelihood(decodeOri, test.L, test.resp);

    end
    cvResults.data = cvData;
    sessionData(sessionNum).cvResults = cvResults;
    fprintf('Completed!\n');
end

%%
figure;
nbStats = zeros(10, 2);
bplStats = zeros(10, 2);
flStats = zeros(10, 2);
colorMap = lines;
for ind = 1:10
    cvData = sessionData(ind).cvResults.data;
    nbTest = [cvData.nbTestLL]
    nbStats(ind, :) = [mean(nbTest), std(nbTest)/sqrt(10)];
    bplTest = [cvData.bplTestLL];
    bplStats(ind, :) = [mean(bplTest), std(bplTest)/sqrt(10)];
    flTest = [cvData.flTestLL];
    flStats(ind, :) = [mean(flTest), std(flTest)/sqrt(10)];
    plot([1,2,3], [mean(nbTest), mean(bplTest), mean(flTest)], 'Color', colorMap(ind,:));
    hold on;
end
set(gca,'xtick',[1,2,3]);
set(gca,'xticklabel',{'Peak-only', 'Peak+Width', 'Full-likelihood'});
ylabel('Average log-likelihood');
%%
figure;
plot(1:13, exp(nbStats(:,1)-nbStats(:,1)), 1:13, exp(bplStats(:,1)-nbStats(:,1)), 1:13, exp(flStats(:, 1)-nbStats(:,1)));
%%
cvData = sessionData(6).cvResults.data;
nbTrain = [cvData.nbTrainLL]
nbTest = [cvData.nbTestLL]
bplTrain = [cvData.bplTrainLL];
bplTest = [cvData.bplTestLL];
flTrain = [cvData.flTrainLL];
flTest = [cvData.flTestLL];
figure;

plot(1:N, nbTrain,'--', 1:N, bplTrain, '--', 1:N, flTrain, '--');
hold on;
plot(1:N, nbTest, 1:N, bplTest, 1:N, flTest);



