classdef PeakWidthSBPSLLC < ClassifierModel.LikelihoodClassifier.StimBiased_PSLLC
    % Posterior-Sampling with Lapse rate based Likelihood Classifier
    properties
        pwExtractor;
    end
    
    methods
        function obj = PeakWidthSBPSLLC(sigmaA, sigmaB, stimCenter, modelName, pwExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 5
                pwExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            if nargin < 4
                modelName = 'PeakWidthSBPSLLC';
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.StimBiased_PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pwExtractor = pwExtractor;
        end
    end
    
    methods (Access = protected)
        function logLRatio = getLogLRatio(self, decodeOri, likelihood, stimulus)
            [~, sigma] = self.pwExtractor(decodeOri, likelihood);% extract center and width of the likelihood function
            s_hat = stimulus(:);
            sigma = sigma(:);
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
    
end