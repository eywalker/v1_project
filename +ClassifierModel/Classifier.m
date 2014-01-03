classdef (Abstract) Classifier < handle
    % CLASSIFIER Abstract class defining generalized Classifier that can
    % perform orientation stimulus classification experiment
    %   Any object that inherits and implements this class should be able
    %   to perform orientation stimulus category classifisication task
    
    methods (Abstract)
        
        p=pRespAGivenS(stimulus,contrast);
        [muLL, logLList] = getLogLikelihood(self, decodeOri, likelihood, classResp)
        logL=train(stimulus,contrast,subject_response);
    end
    
    methods
        [class_response]=classify(stimulus,contrast);
    end
end

