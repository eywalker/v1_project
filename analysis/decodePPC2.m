%Fetch session list - run only if sessionData struct lost
%key = acq.Sessions('session_datetime > "2013-06-01"');
sessionData=fetch((class_discrimination.ClassDiscriminationExperiment * ephys.SpikesAlignedSet));

hSession=waitbar(0,sprintf('Completed session %d out of %d',0,length(sessionData)));
h=waitbar(0,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
for idxSess=1:length(sessionData)
    session=sessionData(idxSess);
    info=fetch(acq.Sessions & session,'*');
    date=info.session_datetime;
    trial_info=fetch(class_discrimination.ClassDiscriminationTrial & session, '*');
    
    
%     waitbar(0,h,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
%     for i = 1:length(trial_info)
%         spikes = fetch(ephys.SpikesAlignedTrial & trial_info(i), 'spikes_aligned');
%         trial_info(i).counts = arrayfun(@(x) sum(x.spikes_aligned > 0 & x.spikes_aligned < 500), spikes);
%         waitbar(i/length(trial_info),h, sprintf('Fetching Recording Data (%2.2f%% complete)',i/length(trial_info)*100));
%     end
    sessionData(idxSess).trial_info=trial_info;
    sessionData(idxSess).date=date;
    waitbar(idxSess/length(sessionData),hSession,sprintf('Completed session %d out of %d',idxSess,length(sessionData)));
end
close(h);
close(hSession);
%% Specify session number
%for sessionNum = 1 : length(sessionData)
SESSION_NUM=20;

%%
% units = [1 2 3 7, ...
%         11 13 14 15 17 18 19 21 24 29 30, ...
%         41 44 46 47 51 52 53 54 55 56 57 58 61 62 63 64  66 67 68, ...
%         73 74 75 80 82 84 85 86 89 91 92 93];
trialInfo=sessionData(SESSION_NUM).trial_info;
all_counts = cat(2,trialInfo.counts);             
all_orientation = [trialInfo.orientation];
all_orientation=mod(all_orientation,180)+180;
all_contrast = [trialInfo.contrast];
all_resp = {trialInfo.selected_class};

decodeOri = [200:0.5:340];
sigmaA = 3;
sigmaB = 15;
sCenter = 270;

N = 10; % N way cross validation
trialInd = randperm(length(trialInfo));
splits = round(linspace(0,length(trialInfo),N+1));
%%
h = waitbar(0,'Working');
modelScores = zeros(3, N);
for ind = 1 : N
%%
    testInd = trialInd(splits(ind)+1:splits(ind+1)); % pick test sets
    trainInd = trialInd([1:splits(ind), splits(ind+1)+1:end]); % pick trials sets
    
    trainSet.counts = all_counts(:, trainInd);
    trainSet.orientation = all_orientation(trainInd);
    trainSet.contrast = all_contrast(trainInd);
    trainSet.resp = all_resp(trainInd);
    
    testSet.counts = all_counts(:, testInd);
    testSet.orientation = all_orientation(:, testInd);
    testSet.contrast = all_contrast(:, testInd);
    
    counts = all_counts(:, trainInd);            
    orientation = all_orientation(trainInd);
    contrast = all_contrast(trainInd);
    resp = all_resp(trainInd);

    % GET TUNING CURVES AND TRAIN CLASSIFIER MODELS
    contrastList = sort(unique(contrast(:)),1,'descend');
    likelihood = zeros(length(decodeOri), length(orientation));
    clear codecList;
    for indCont = 1:length(contrastList)
        contVal = contrastList(indCont);
        trials = find(contrast==contVal);
        if(indCont == 1) % highest contrast case
            gpCurve = ClassifierModel.CoderDecoder.GPDPCEncoder(96);
            gpCurve.train(orientation(trials),[], counts(:, trials));
            pnCodec = ClassifierModel.CoderDecoder.PoissonNoisePPCodec(gpCurve);
            logLAll = pnCodec.getLogLikelihood(orientation(trials), [], counts(:, trials));
            unitLLMU = mean(logLAll, 2); % obtain mean log-likelihood for each unit
            unit = (unitLLMU > -3); % exclude units for which mean log-likelihood of TC -> response is < exp(-3) ~ 0.05
            pnCodec.baseEncoder = gpCurve.restrict(unit);
        else
            gpCurve = ClassifierModel.CoderDecoder.GPDPCEncoder(sum(unit));
            gpCurve.train(orientation(trials),[],counts(unit, trials));
            pnCodec = ClassifierModel.CoderDecoder.PoissonNoisePPCodec(gpCurve);
        end
        L = pnCodec.getLikelihoodDistr(decodeOri, [], counts(unit, trials));
        likelihood(:, trials) = L;
        codecList(indCont).contrast = contVal;
        codecList(indCont).pnCodec = pnCodec;
    end

    % train models
    nb = ClassifierModel.LikelihoodClassifier.NBLikelihoodClassifier(sigmaA, sigmaB, sCenter);
    nb.train(decodeOri, likelihood, resp, 30);
    bpl = ClassifierModel.LikelihoodClassifier.BPLLikelihoodClassifier(sigmaA, sigmaB, sCenter);
    bpl.train(decodeOri, likelihood, resp, 30);
    fl = ClassifierModel.LikelihoodClassifier.FullLikelihoodClassifier(sigmaA, sigmaB, sCenter);
    fl.train(decodeOri, likelihood, resp, 30);
    
    % TEST
    counts = all_counts(:, testInd);            
    orientation = all_orientation(testInd);
    contrast = all_contrast(testInd);
    resp = all_resp(testInd);
    
    likelihood = zeros(length(decodeOri), length(orientation));
    
    for indCodec = 1:length(codecList)
        contVal = codecList(indCodec).contrast;
        pnCodec = codecList(indCodec).pnCodec;
        trials = find(contrast == contVal);
        L = pnCodec.getLikelihoodDistr(decodeOri, [], counts(unit, trials));
        likelihood(:, trials) = L;
    end
    
    modelScores(1, ind) = nb.getLogLikelihood(decodeOri, likelihood, resp);
    modelScores(2, ind) = bpl.getLogLikelihood(decodeOri, likelihood, resp);
    modelScores(3, ind) = fl.getLogLikelihood(decodeOri, likelihood, resp);
    waitbar(ind/N, h, 'Working');
end
sessionData(SESSION_NUM).modelScores = modelScores;

%end



