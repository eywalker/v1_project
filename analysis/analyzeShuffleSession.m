function cvResults = analyzeShuffleSession(trialInfo, d)
% This code takes a trialInfo structure array and perform v1-decoding
% analysis, returning cross-validated analysis results for each contrast
% found within the trialInfo structure.
% 
% Author: Edgar Y. Walker
% Created: Aug, 2013
% Email: edgar.walker@gmail.com
%
% Lasted edited on Feb 10, 2014 by Edgar Walker (edgar.walker@gmail.com)

    if nargin < 2
        d = 3;
    end
    % analysis constants
    UNIT_THR = -4; % threshold for selecting good unit tuning curve fit, note current value is fairly arbitrary

    % experiment configuration
    sigmaA = 3;
    sigmaB = 15;
    sCenter = 270;
    decodeOri = [220:0.5:320];
    N = 10; % N way cross validation
    
    % extract details trial info
    all_counts = cat(2,trialInfo.counts);             
    all_orientation = [trialInfo.orientation];
    %all_orientation=mod(all_orientation,180)+180; %?? not really sure why I did that...
    all_contrast = [trialInfo.contrast];
    all_resp = {trialInfo.selected_class};
    
    contList = sort(unique(all_contrast)); % list of all contrasts
    contPrior = ones(size(contList)) ./ length(contList); %assume equal-probability for each contrast


    % train tuning curves and obtain likelihood for all contrasts
    fprintf('Training tuning curves...\n');
    
    gpCurve = ClassifierModel.CoderDecoder.ContrastAdjustedGPDPCEncoder(96);
    gpCurve.train(all_orientation, all_contrast, all_counts); % train GP tuning curves
    pnCodec = ClassifierModel.CoderDecoder.PoissonNoisePPCodec(gpCurve); % wrap GP tuning curves with Poisson noise
    logLAll = pnCodec.getLogLikelihood(all_orientation, all_contrast, all_counts); % assess quality of tuning curve
    unitLL = mean(logLAll, 2);
    goodUnits = (unitLL > UNIT_THR);
    pnCodec.baseEncoder = gpCurve.restrict(goodUnits); % remove channels with poor tuning curve fit
    %disp(size(all_contrast));
    %disp(size(all_counts(goodUnits, :)));
    %L = pnCodec.getLikelihoodDistrWithContrastPrior(decodeOri, contList, contPrior, all_counts(goodUnits, :)); % decode likelihood
    

    if sum(goodUnits) < 1 % if no units left after thresholding...
	fprintf('No units left after thresholding with threshold of %.2f...\n', UNIT_THR);
	cvResults = [];
	return;
    end
	
    %% run analysis for each contrast separately
    for indContrast = 1:length(contList)
        
        contrast = contList(indContrast); 
        fprintf('Analyzing contrast=%2.3f...\n',contrast);
        pos = find(all_contrast == contrast);
        
        % split trials for N-way cross validation
        %trialInd = pos(randperm(length(pos)));
        %splits = round(linspace(0,length(pos),N+1));

        L = pnCodec.getLikelihoodDistr(decodeOri, contrast, all_counts(goodUnits, :)); % decode likelihood
        
        cvData = struct();


        % build train and test set
        trainSet.decodeOri = decodeOri;
        trainSet.likelihood = L(:,pos);
        trainSet.stimulus = all_orientation(pos);
        trainSet.classResp = all_resp(pos);
        
        
        % build shuffled data
        R = all_counts(goodUnits, pos); % get all spikes for this contrast
        ori = trainSet.stimulus;
        orid = round(ori/d) * d; % round to the nearest d deg
        v = unique(orid);
        Rshuffle = zeros(size(R));
        for i = 1:length(v) % for each unique direction
            pos = find(orid == v(i));
            for j = 1:size(R, 1) % for each neuron
                p = randperm(length(pos));
                randpos = pos(p);
                Rshuffle(j,pos) = R(j, randpos);
            end
        end
        Lshuffle = pnCodec.getLikelihoodDistr(decodeOri, contrast, Rshuffle);
        
        testSet = trainSet;
        testSet.likelihood = Lshuffle;

           
        % switch trainset and testset
        temp = testSet;
        testSet = trainSet;
        trainSet = temp;
        fprintf('Training models...\n');
            
        %% create all model instances

        % create and initialize list of models
        modelList = {};
        model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter,'GaussianPeak');
        modelList = [modelList {model}];
        % Note that OptimalWidth model is mathematically equivalent to PointPSLLC using the same peak extractor, hence omitted here
        %model = ClassifierModel.LikelihoodClassifier.OptimalWidth2(sigmaA, sigmaB, sCenter, 'OptimizedWidth2', @ClassifierModel.getMeanStd);
        %modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter, 'MLPeak', @ClassifierModel.getMaxStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter, 'LikelihoodMean', @ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC(sigmaA, sigmaB, sCenter, 'GaussianPeakWidth');
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC(sigmaA, sigmaB, sCenter, 'LikelihoodMeanWidth',@ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.ScaledWidthPSLLC(sigmaA, sigmaB, sCenter, 'ScaledWidthLikelihoodMeanWidth', @ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.FullPSLLC(sigmaA, sigmaB, sCenter, 'FullLikelihood');
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC(sigmaA, sigmaB, sCenter, 'SCGaussianWidth');
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC(sigmaA, sigmaB, sCenter, 'SCLikelihoodWidth', @ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.ScaledWidthSBPSLLC(sigmaA, sigmaB, sCenter, 'SCScaledLikelihoodWidth', @ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
        %model = ClassifierModel.BehavioralClassifier.BPLClassifier2(sigmaA, sigmaB, sCenter);
        %modelList = [modelList {model}];

        %% train all models


        modelStruct = struct();

        for modelInd = 1:length(modelList)
            model = modelList{modelInd};
            modelStruct(modelInd).modelName = model.modelName;
            modelStruct(modelInd).trainLL = model.train(trainSet, 50);
            modelStruct(modelInd).configs = model.getModelConfigs;
        end

%             % train behavioral classifier
%             modelStruct(nA + nB + 1).modelName = behModel.modelName;
%             modelStruct(nA + nB + 1).trainLL = behModel.train(train.s, contrast, train.resp, 50);

        %% test all models
        for modelInd = 1:length(modelList)
            model = modelList{modelInd};
            modelStruct(modelInd).testLL = model.getLogLikelihood(testSet);
            fprintf('%s: %2.3f\n', model.modelName, modelStruct(modelInd).testLL);
        end


        %% store results of this CV run
        cvData.trainSet = trainSet;
        cvData.testSet = testSet;
        cvData.models = modelStruct;
            
        
        % Package up results for this contrast
        cvContrast(indContrast).contrast = contrast;
        cvContrast(indContrast).positions = pos;
        cvContrast(indContrast).data = cvData;
    end
    
    % populate cvResults
    cvResults.likelihood = L;
    cvResults.sigmaA = sigmaA;
    cvResults.sigmaB = sigmaB;
    cvResults.sCenter = sCenter;
    cvResults.decodeOri = decodeOri; 
    cvResults.contList = contList;
    cvResults.contPrior = contPrior;
    cvResults.N = N;
    cvResults.pnCodec = pnCodec;
    cvResults.goodUnits = goodUnits;
    cvResults.cvContrast = cvContrast;
end
