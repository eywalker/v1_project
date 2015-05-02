classdef PointPSLLC < ClassifierModel.LikelihoodClassifier.PSLLC
    % Posterior-Sampling with Lapse rate based Likelihood Classifier
    properties
        pointExtractor;
    end
    
    methods
        function obj = PointPSLLC(sigmaA, sigmaB, stimCenter, modelName, pointExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 5
                pointExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            if nargin < 4
                modelName = 'PointPSLLC';
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pointExtractor = pointExtractor;
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
            if isfield(dataStruct, 'decodeOri') && isfield(dataStruct, 'likelihood')
                decodeOri = dataStruct.decodeOri;
                likelihood = dataStruct.likelihood;
                s_hat = self.pointExtractor(decodeOri, likelihood);% extract center and width of the likelihood function
            elseif isfield(dataStruct, 'likelihood_peak')
                s_hat = dataStruct.likelihood_peak;
            end
            
            s_hat = s_hat(:);
            sigma = 0;
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
    
end