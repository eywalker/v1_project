classdef PointPSLLC < ClassifierModel.PointBasedLikelihoodClassifier.PSLLC
    % Posterior-Sampling with Lapse rate based point decoder based Likelihood Classifier
    
    methods
        function obj = PointPSLLC(sigmaA, sigmaB, stimCenter, modelName)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 4
                modelName = 'PointPSLLC';
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.PointBasedLikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
        end
    end
    
    methods (Access = protected)
        function [logLRatio, dataStruct] = getLogLRatio(self, dataStruct)
            if isfield(dataStruct, 's_hat')
                s_hat = dataStruct.s_hat;
            else
                dec = self.getPointDecoder(dataStruct);
                s_hat = dec.decode(dataStruct);
                dataStruct.s_hat = s_hat;
            end
            
            s_hat = s_hat(:);
            sigma = 0;
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
    
end