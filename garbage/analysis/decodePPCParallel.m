%  % Fetch session list - run only if sessionData struct lost
% key = acq.Sessions('session_datetime > "2013-06-01"');
% sessionData=fetch((class_discrimination.ClassDiscriminationExperiment * ephys.SpikesAlignedSet) & key);
% 
% hSession=waitbar(0,sprintf('Completed session %d out of %d',0,length(sessionData)));
% h=waitbar(0,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
% for idxSess=1:length(sessionData)
%     session=sessionData(idxSess);
%     info=fetch(acq.Sessions & session,'*');
%     date=info.session_datetime;
%     trial_info=fetch(class_discrimination.ClassDiscriminationTrial & session, '*');
%     
%     
%     waitbar(0,h,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
%     for i = 1:length(trial_info)
%         spikes = fetch(ephys.SpikesAlignedTrial & trial_info(i), 'spikes_aligned');
%         trial_info(i).counts = arrayfun(@(x) sum(x.spikes_aligned > 0 & x.spikes_aligned < 500), spikes);
%         waitbar(i/length(trial_info),h, sprintf('Fetching Recording Data (%2.2f%% complete)',i/length(trial_info)*100));
%     end
%     sessionData(idxSess).trial_info=trial_info;
%     sessionData(idxSess).date=date;
%     waitbar(idxSess/length(sessionData),hSession,sprintf('Completed session %d out of %d',idxSess,length(sessionData)));
% end
% close(h);
% close(hSession);

%% Specify session number
sigmaA = 3;
sigmaB = 15;
sCenter = 270;
decodeOri = [220:0.5:320];

N = 10; % N way cross validation 
% NOTE: Session 10 apparently sucks!

for sessionNum = 1%length(sessionData)
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
    contPrior = ones(size(contList)) ./ length(contList); %assume equal-probability for each contrast
%     
%     ind = (all_contrast == contList(end));
%     all_counts = all_counts(:, ind);
%     all_orientation = all_orientation(ind);
%     all_contrast = all_contrast(ind);
%     all_resp = all_resp(ind);
%     contList = sort(unique(all_contrast));
%     contPrior = ones(size(contList)) ./ length(contList); 
    
    clear cvResults
 
    cvResults.decodeOri = decodeOri;
    cvResults.contList = contList;
    cvResults.contPrior = contPrior;
    
    
    % train tuning curves on all data
    % train tuning curves and obtain likelihood for all contrasts
    fprintf('Training tuning curves...\n');
    gpCurve = ClassifierModel.CoderDecoder.ContrastAdjustedGPDPCEncoder(96);
    gpCurve.train(all_orientation, all_contrast, all_counts);
    pnCodec = ClassifierModel.CoderDecoder.PoissonNoisePPCodec(gpCurve);
    logLAll = pnCodec.getLogLikelihood(all_orientation, all_contrast, all_counts);
    unitLL = mean(logLAll, 2);
    goodUnits = (unitLL > -3);
    pnCodec.baseEncoder = gpCurve.restrict(goodUnits);
    L = pnCodec.getLikelihoodDistrWithContrastPrior(decodeOri, contList, contPrior, all_counts(goodUnits, :));
    
    clear cvContrast
    for indContrast = 1:length(contList)
        
        contrast = contList(indContrast);
        fprintf('Analyzing contrast=%2.3f...\n',contrast);
        pos = find(all_contrast == contrast);
        
        trialInd = pos(randperm(length(pos)));
        splits = round(linspace(0,length(pos),N+1));
        
        clear cvData;
        for ind = 1 : N
            fprintf('Processing %d out of %d CV\n',ind, N);
            testInd = trialInd(splits(ind)+1:splits(ind+1)); % pick test sets
            trainInd = trialInd([1:splits(ind), splits(ind+1)+1:end]); % pick trials sets

            % build train and test set
            
            train.L = L(:,trainInd);
            train.resp = all_resp(trainInd);
            train.s = all_orientation(trainInd);
            test.L = L(:,testInd);
            test.resp = all_resp(testInd);
            test.s = all_orientation(testInd);

            % train models for each contrast separately

            fprintf('Training models...\n');
            
            % create and initialize list of non-stim-biased models
            modelListA = {};
            model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter,'GaussianPeak');
            modelListA = [modelListA {model}];
            model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter, 'ML_Peak', @ClassifierModel.getMaxStd);
            modelListA = [modelListA {model}];
            model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter, 'LikelihoodMean', @ClassifierModel.getMeanStd);
            modelListA = [modelListA {model}];
            model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC(sigmaA, sigmaB, sCenter, 'GaussianPeakWidth');
            modelListA = [modelListA {model}];
            model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC(sigmaA, sigmaB, sCenter, 'LikelihoodMeanWidth',@ClassifierModel.getMeanStd);
            modelListA = [modelListA {model}];
            model = ClassifierModel.LikelihoodClassifier.FullPSLLC(sigmaA, sigmaB, sCenter, 'FullLikelihood');
            modelListA = [modelListA {model}];
            
            nA = length(modelListA);
            
            % create and initialize list of stim-biased models
            modelListB = {}
            model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC(sigmaA, sigmaB, sCenter, 'SC_GaussianWidth');
            modelListB = [modelListB {model}]
            model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC(sigmaA, sigmaB, sCenter, 'SC_LikelihoodWidth', @ClassifierModel.getMeanStd);
            modelListB = [modelListB {model}]
            
            % train non stim_biased models
            modelStruct = struct()
            
            for modelInd = 1:length(modelListA)
                model = modelListA{modelInd};
                modelStruct(modelInd).modelName = model.modelName;
                modelStruct(modelInd).trainLL = model.train(decodeOri, train.L, train.resp, 50);
            end
            
            % train stim-biased moedls
            for modelInd = 1:length(modelListB)
                model = modelListB{modelInd};
                modelStruct(modelInd + nA).modelName = model.modelName;
                modelStruct(modelInd + nA).trainLL = model.train(decodeOri, train.L, train.s, train.resp, 50);
            end
            
            % test all models
            for modelInd = 1:length(modelListA)
                model = modelList{modelInd};
                modelStruct(modelInd).testLL = model.getLogLikelihood(decodeOri, test.L, test.resp);
                fprintf('%s: %2.3f\n', model.modelName, modelStruct(modelInd).testLL);
            end
            
            for modelInd = 1:length(modelListB)
                model = modelList{modelInd};
                modelStruct(modelInd+nA).testLL = model.getLogLikelihood(decodeOri, test.L, test.s, test.resp);
                fprintf('%s: %2.3f\n', model.modelName, modelStruct(modelInt+nA).testLL);
            end



            % TEST

            cvData(ind).trainSet = train;
            cvData(ind).testSet = test;
            cvData(ind).models = modelStruct;
            
        end
        cvContrast(indContrast).contrast = contrast;
        cvContrast(indContrast).positions = pos;
        cvContrast(indContrast).trialInd = trialInd;
        cvContrast(indContrast).splits = splits;
        cvContrast(indContrast).data = cvData;
        
    end
    cvResults.N = N;
    cvResults.pnCodec = pnCodec;
    cvResults.goodUnits = goodUnits;
    cvResults.cvContrast = cvContrast;
    
    sessionData(sessionNum).cvResults = cvResults;
    fprintf('Completed!\n');
    
end

% %%
% testStat=[]
% for indSession = 1:length(sessionData)
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indConrast = 1:length(cvContrast)
%         cvData = cvContrast(indContrast).data;
%         testLL = []
%         for indCV = 1:length(cvData)
%             testLL = [testLL vertcat(cvData(indCV).models.testLL)]
%         end
%         testStat = [testStat mean(testLL,2)]
%     end
% end
% 
% 
% %%
% figure;
% nbStats = zeros(10, 2);
% bplStats = zeros(10, 2);
% flStats = zeros(10, 2);
% colorMap = lines;
% for ind = 1:10
%     cvData = sessionData(ind).cvResults.data;
%     nbTest = [cvData.nbTestLL]
%     nbStats(ind, :) = [mean(nbTest), std(nbTest)/sqrt(10)];
%     bplTest = [cvData.bplTestLL];
%     bplStats(ind, :) = [mean(bplTest), std(bplTest)/sqrt(10)];
%     flTest = [cvData.flTestLL];
%     flStats(ind, :) = [mean(flTest), std(flTest)/sqrt(10)];
%     plot([1,2,3], [mean(nbTest), mean(bplTest), mean(flTest)], 'Color', colorMap(ind,:));
%     hold on;
% end
% set(gca,'xtick',[1,2,3]);
% set(gca,'xticklabel',{'Peak-only', 'Peak+Width', 'Full-likelihood'});
% ylabel('Average log-likelihood');
% %%
% figure;
% plot(1:13, exp(nbStats(:,1)-nbStats(:,1)), 1:13, exp(bplStats(:,1)-nbStats(:,1)), 1:13, exp(flStats(:, 1)-nbStats(:,1)));
% %%
% cvData = sessionData(1).cvResults.data;
% nbTrain = [cvData.nbTrainLL]
% nbTest = [cvData.nbTestLL]
% bplTrain = [cvData.bplTrainLL];
% bplTest = [cvData.bplTestLL];
% flTrain = [cvData.flTrainLL];
% flTest = [cvData.flTestLL];
% figure;
% 
% plot(1:N, nbTrain,'--', 1:N, bplTrain, '--', 1:N, flTrain, '--');
% hold on;
% plot(1:N, nbTest, 1:N, bplTest, 1:N, flTest);
% 
% %%
% logL_vals = [];
% model_group = {};
% session_group = [];
% 
% for indSession = 1:10
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indCont = 1:length(cvContrast)
%         cvData = cvContrast(indCont).data;
%         for indRun = 1:length(cvData)
%             data = cvData(indRun);
%             vals = [data.nbTestLL data.bplTestLL, data.flTestLL];
%             vals = vals - mean(vals);
%             logL_vals = cat(2, logL_vals, vals);
%             model_group = cat(2,model_group, {'nb','bpl', 'fl'});
%             session_group = cat(2,session_group, indSession * ones(size(vals)));
%         end
%         
%     end
% end
% 
% p = anovan(logL_vals, {model_group, session_group});
% nbInd = strcmp(model_group, 'nb');
% nbVals = logL_vals(nbInd);
% bplInd = strcmp(model_group, 'bpl');
% bplVals = logL_vals(bplInd);
% 
% [h, p] = ttest2(nbVals, bplVals)
% 
% %%
% logL_vals = [];
% model_group = {};
% session_group = [];
% 
% for indSession = 1:17
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indCont = 1:length(cvContrast)
%         cvData = cvContrast(indCont).data;
%         for indRun = 1:length(cvData)
%             data = cvData(indRun);
%             vals = [data.nbTestLL data.bplTestLL];% data.flTestLL];
%             logL_vals = cat(2, logL_vals, vals);
%             model_group = cat(2,model_group, {'nb','bpl'});% 'fl'});
%             session_group = cat(2,session_group, indSession * ones(size(vals)));
%         end
%         
%     end
% end
% 
% p = anovan(logL_vals, {model_group, session_group});
% %%
% nbInd = strcmp(model_group, 'nb');
% nbVals = logL_vals(nbInd);
% bplInd = strcmp(model_group, 'bpl');
% bplVals = logL_vals(bplInd);
% 
% [h, p] = ttest2(nbVals, bplVals)
% 
% 
% 
% 
% %% paired t-test based approach
% nbVals = [];
% bplVals = [];
% flVals = [];
% sessionInd = [];
% nSession = 20;
% for indSession = 1:20
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indCont = 1:length(cvContrast)
%         cvData = cvContrast(indCont).data;
%         nbVals = cat(2, nbVals, mean([cvData.nbTestLL]));
%         bplVals =cat(2, bplVals, mean([cvData.bplTestLL]));
%         flVals =cat(2,flVals, mean([cvData.flTestLL]));
%         sessionInd = cat(2, sessionInd, indSession);
%     end
% end
% allData = [nbVals; bplVals; flVals];
% allData = bsxfun(@minus, allData, mean(allData,1));
% shortData = [];
% for ind =1:nSession
%     pos = sessionInd == ind;
%     shortData=cat(2,shortData,mean(allData(:,pos),2))
% end
% 
% 
% figure;
% hold on;
% plot(sessionInd, allData(1,:),'ro');
% plot(sessionInd, allData(2,:),'go');
% plot(sessionInd, allData(3,:),'bo');
% hold on;
% plot(1:nSession, shortData(1,:),'r');
% plot(1:nSession, shortData(2,:),'g');
% plot(1:nSession, shortData(3,:),'b');
% 
% legend({'Gaussian-peak', 'Gaussian-peak-and-width', 'Full-likelihood'});
% 
% [h, p] = ttest(nbVals, bplVals)
% fprintf('nb vs bpl %f', p)
% 
% [h, p] = ttest(nbVals, flVals)
% fprintf('nb vs fl %f', p)
% 
% labels = [repmat({'nb'}, size(nbVals)), repmat({'fl'}, size(flVals))];
% [h, p] = anovan([nbVals, bplVals], {[sessionInd, sessionInd], labels})