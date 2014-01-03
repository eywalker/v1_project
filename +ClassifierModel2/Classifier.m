classdef (Abstract) Classifier < handle
    % CLASSIFIER Abstract class defining generalized Classifier that can
    % perform orientation stimulus classification experiment
    %   Any object that inherits and implements this class should be able
    %   to perform orientation stimulus category classifisication task
    
    methods (Abstract)
        [class_response]=classify(stimulus,contrast);
        p=pRespAGivenS(stimulus,contrast);
        logL=train(stimulus,contrast,subject_response);
    end
end

