classdef OptimalWidth2 < ClassifierModel.LikelihoodClassifier.PSLLC
    % Posterior-Sampling with Lapse rate based Likelihood Classifier
    properties
        sigma = 5; % width of the likelihood function
        pointExtractor;    
    end
    
    
    
    
    methods
        function obj = OptimalWidth2(sigmaA, sigmaB, stimCenter, modelName, pointExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 4
                modelName = 'OptimizedWidthWithPeak';
            end
            if nargin < 5
                pointExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pointExtractor = pointExtractor;
            obj.params = [obj.params {'sigma'}];
            obj.fixedParams = false(1, 4);
            obj.p_lb = [obj.p_lb 0];
            obj.p_ub = [obj.p_ub Inf];
            obj.precompLogLRatio = false; %make sure logLRatio gets recomputed with parameter update
        end
        
        function configSet = getModelConfigs(self)
            configSet = getModelConfigs@ClassifierModel.LikelihoodClassifier.PSLLC(self);
            configSet.pointExtractorName = func2str(self.pointExtractor);
        end
        
        function setModelConfigs(self, configSet)
            setModelConfigs@ClassifierModel.LikelihoodClassifier.PSLLC(self, configSet);
            self.pointExtractor = eval(['@' configSet.pointExtractorName]);
        end
        
    end
    methods (Access = protected)
        function logLRatio = getLogLRatio(self, dataStruct)
            decodeOri = dataStruct.decodeOri(:);
            likelihood = dataStruct.likelihood;
            s_hat = self.pointExtractor(decodeOri, likelihood); % extract center of the likelihood function
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(self.sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (self.sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(self.sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (self.sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
end