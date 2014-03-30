function cvResults = analyzeSessionNoCV(trialInfo)
% This code takes a trialInfo structure array and perform v1-decoding
% analysis, returning NON-cross-validated analysis results for each contrast
% found within the trialInfo structure.
% 
% Author: Edgar Y. Walker
% Created: Aug, 2013
% Email: edgar.walker@gmail.com
%
% Lasted edited on Feb 16, 2014 by Edgar Walker (edgar.walker@gmail.com)

    % analysis constants
    UNIT_THR = -3; % threshold for selecting good unit tuning curve fit, note current value is fairly arbitrary

    % experiment configuration
    sigmaA = 3;
    sigmaB = 15;
    sCenter = 270;
    decodeOri = [220:0.5:320];
    N = 10; % N way cross validation
    
    % extract details trial info
    all_counts = cat(2,trialInfo.counts);             
    all_orientation = [trialInfo.orientation];
    all_orientation=mod(all_orientation,180)+180;
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
    L = pnCodec.getLikelihoodDistrWithContrastPrior(decodeOri, contList, contPrior, all_counts(goodUnits, :)); % decode likelihood
    
    
    %% run analysis for each contrast separately
    clear cvContrast;
    for indContrast = 1:length(contList)
        
        contrast = contList(indContrast); 
        fprintf('Analyzing contrast=%2.3f...\n',contrast);
        pos = find(all_contrast == contrast);
        
        % train using all data points
        trainSet.decodeOri = decodeOri;
        trainSet.likelihood = L(:, pos);
        trainSet.stimulus = all_orientation(pos);
        trainSet.classResp = all_resp(pos);
        
        fprintf('Training models...\n');
        
        % create all model instances
        
        % create and initialize list of models
        modelList = {};
        model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter,'GaussianPeak');
        modelList = [modelList {model}];
        %model = ClassifierModel.LikelihoodClassifier.OptimalWidth(sigmaA, sigmaB, sCenter, 'OptimizedWidth', @ClassifierModel.getMeanStd);
        %modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter, 'ML_Peak', @ClassifierModel.getMaxStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, sCenter, 'LikelihoodMean', @ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC(sigmaA, sigmaB, sCenter, 'GaussianPeakWidth');
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC(sigmaA, sigmaB, sCenter, 'LikelihoodMeanWidth',@ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.FullPSLLC(sigmaA, sigmaB, sCenter, 'FullLikelihood');
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC(sigmaA, sigmaB, sCenter, 'StimCenteredGaussianWidth');
        modelList = [modelList {model}];
        model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC(sigmaA, sigmaB, sCenter, 'StimCenteredLikelihoodWidth', @ClassifierModel.getMeanStd);
        modelList = [modelList {model}];
            
        modelStruct = struct();
        
        % train all models
        for modelInd = 1:length(modelList)
            model = modelList{modelInd};
            modelStruct(modelInd).modelName = model.modelName;
            modelStruct(modelInd).trainLL = model.train(trainSet, 50);
        end

        % Package up results for this contrast
        cvContrast(indContrast).contrast = contrast;
        cvContrast(indContrast).positions = pos;
        cvContrast(indContrast).dataSet = trainSet;
        cvContrast(indContrast).modelFits = modelStruct;
    end
    
    % populate cvResults
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