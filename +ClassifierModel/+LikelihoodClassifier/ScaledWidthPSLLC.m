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
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pwExtractor = pwExtractor;
            obj.params = [obj.params {'scale'}];
            obj.fixedParams = [obj.fixedParams false];
            obj.p_lb = [obj.p_lb 0];
            obj.p_ub = [obj.p_ub 50];
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
        function [logLRatio, dataStruct] = getLogLRatio(self, dataStruct) %decodeOri, likelihood)
            if isfield(dataStruct, 'computed_peak') && isfield(dataStruct, 'computed_width')
                s_hat = dataStruct.computed_peak;
                sigma = dataStruct.computed_width;
            elseif isfield(dataStruct, 'decodeOri') && isfield(dataStruct, 'likelihood')
                decodeOri = dataStruct.decodeOri;
                likelihood = dataStruct.likelihood;
                [s_hat, sigma] = self.pwExtractor(decodeOri, likelihood);% extract center and width of the likelihood function
                dataStruct.computed_peak = s_hat;
                dataStruct.computed_width = sigma;
            elseif isfield(dataStruct, 'likelihood_peak') && isfield(dataStruct, 'likelihood_width')
                s_hat = dataStruct.likelihood_peak;
                sigma = dataStruct.likelihood_width;
            end

            s_hat = s_hat(:);
            sigma = self.scale * sigma(:); % scale the extracted width of the likelihood function
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
end
