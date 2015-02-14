classdef ScaledWidthPSLLC < ClassifierModel.LikelihoodClassifier.PSLLC
    % Posterior-Sampling with Lapse rate based Likelihood Classifier that
    % extracts center and width of the likelihood, and *scales* the width
    % before computing logLRatio. This is an attempt to account for missing
    % neurons (as increased neurons would expectedly decrease likelihood
    % width).
    properties
        scale = 1; % scaling of the likelihood width
        pwExtractor;
    end
    
    methods
        function obj = ScaledWidthPSLLC(sigmaA, sigmaB, stimCenter, modelName, pwExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 5
                pwExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            if nargin < 4
                modelName = 'ScaledWidthPSLLC';
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pwExtractor = pwExtractor;
            obj.params = [obj.params {'scale'}];
            obj.fixedParams = [obj.fixedParams false];
            obj.p_lb = [obj.p_lb 0];
            obj.p_ub = [obj.p_ub Inf];
            obj.precompLogLRatio = false; %make sure logLRatio gets recomputed with parameter update
        end
    end
    methods (Access = protected)
        function logLRatio = getLogLRatio(self, dataStruct) %decodeOri, likelihood)
            decodeOri = dataStruct.decodeOri;
            likelihood = dataStruct.likelihood;
            [s_hat, sigma] = self.pwExtractor(decodeOri, likelihood);% extract center and width of the likelihood function
            s_hat = s_hat(:);
            sigma = self.scale * sigma(:); % scale the extracted width of the likelihood function
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
end
