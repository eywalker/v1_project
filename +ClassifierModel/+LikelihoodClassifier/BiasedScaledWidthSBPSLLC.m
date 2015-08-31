classdef BiasedScaledWidthSBPSLLC < ClassifierModel.LikelihoodClassifier.PSLLC
    % Stimulus-biased Posterior-Sampling with Lapse rate based Likelihood Classifier that
    % centers the likelihood function at the stimulus and uses a *scaled*
    % version of the extracted standard deviation!
    properties
        scale=1;
        bias = 0;
        pwExtractor;
    end
    
    methods
        function obj = BiasedScaledWidthSBPSLLC(sigmaA, sigmaB, stimCenter, modelName, pwExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 5
                pwExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            if nargin < 4
                modelName = 'BiasedScaledWidthSBPSLLC';
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pwExtractor = pwExtractor;
            obj.params = [obj.params {'scale', 'bias'}];
            obj.fixedParams = [obj.fixedParams false false];
            obj.p_lb = [obj.p_lb 0 0];
            obj.p_ub = [obj.p_ub Inf 300];
            obj.precompLogLRatio = false; %make sure logLRatio gets recomputed with parameter update
        end
        
        function configSet = getModelConfigs(self)
            configSet = getModelConfigs@ClassifierModel.LikelihoodClassifier.PSLLC(self);
            configSet.pwExtractorName = func2str(self.pwExtractor);
        end
        
        function setModelConfigs(self, configSet)
            setModelConfigs@ClassifierModel.LikelihoodClassifier.PSLLC(self, configSet);
            self.pwExtractor = eval(['@' configSet.pwExtractorName]);
        end
    end
    
    methods (Access = protected)
        function [logLRatio, dataStruct] = getLogLRatio(self, dataStruct) %decodeOri, likelihood, stimulus)
            if isfield(dataStruct, 'computed_width')
                sigma = dataStruct.computed_width;
            elseif isfield(dataStruct, 'decodeOri') && isfield(dataStruct, 'likelihood')
                decodeOri = dataStruct.decodeOri;
                likelihood = dataStruct.likelihood;
                [~, sigma] = self.pwExtractor(decodeOri, likelihood);% extract center and width of the likelihood function
                dataStruct.computed_width = sigma;
            elseif isfield(dataStruct, 'likelihood_width')
                sigma = dataStruct.likelihood_width;
            end
            stimulus = dataStruct.orientation;
            
            sigma = self.scale * sigma + self.bias;
            s_hat = stimulus(:);
            sigma = sigma(:);
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
    
end
