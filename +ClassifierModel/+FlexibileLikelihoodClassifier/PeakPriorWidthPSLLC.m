classdef PeakPriorWidthPSLLC < ClassifierModel.FlexibileLikelihoodClassifier.PSLLC
    % Posterior-Sampling with Lapse rate based Flexible Likelihood Classifier
    % (PSLLC) model that would extract peak and width information from the
    % full likelihood function and replace it with Gaussian likelihood of
    % equivalent peak (mean) and width (standard deviation). By default the
    % model will fit gaussian curve to the full likelihood function, but
    % alternative method of peak/width extraction may be employed by
    % passing in a peak-width extractor (pwExtractor) function. The
    % pwExtractor must accept decode orientation over which the likelihood
    % function matrix is defined, and return peak and width for each
    % sample.
    %
    % Author: Edgar Y. Walker
    % e-mail: edgar.walker@gmail.com
    % Last modified: Feb 16, 2014
    %
    properties
        pwExtractor;
        priorSigma2 = 1000;
    end
    
    methods
        function obj = PeakPriorWidthPSLLC(sigmaA, sigmaB, stimCenter, modelName, pwExtractor)
        % Initializes the object with experiment settings about
        % standard deviation (sigmaA and sigmaB) and center
        % (stimCenter) of two distributions. You can optionally pass in
        % name of the model (modelName) and a function handle to the
        % likelihood peak and width extractor (pwExtractor).
            if nargin < 5
                pwExtractor = @ClassifierModel.getMeanStd;
            end
            if nargin < 4
                modelName = 'PeakWidthPSLLC';
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.FlexibileLikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pwExtractor = pwExtractor;
            obj.params = [obj.params {'priorSigma2'}];
            obj.fixedParams = [obj.fixedParams false ];
            obj.p_lb = [obj.p_lb 0];
            obj.p_ub = [obj.p_ub Inf];
        end
        
        
        function configSet = getModelConfigs(self)
            configSet = getModelConfigs@ClassifierModel.FlexibileLikelihoodClassifier.PSLLC(self);
            configSet.pwExtractorName = func2str(self.pwExtractor);
        end
        
        function setModelConfigs(self, configSet)
            setModelConfigs@ClassifierModel.FlexibileLikelihoodClassifier.PSLLC(self, configSet);
            self.pwExtractor = eval(['@' configSet.pwExtractorName]);
        end
        
        
    end
    
    methods (Access = protected)
        function [logLRatio, dataStruct] = getLogLRatio(self, dataStruct) %decodeOri, likelihood)
            if isfield(dataStruct, 's_hat') && isfield(dataStruct, 'sigma')
                s_hat = dataStruct.s_hat;
                sigma = dataStruct.sigma;
            elseif isfield(dataStruct, 'decodeOri') && isfield(dataStruct, 'likelihood')
                decodeOri = dataStruct.decodeOri;
                likelihood = dataStruct.likelihood;
                [s_hat, sigma] = self.pwExtractor(decodeOri, likelihood);% extract center and width of the likelihood function
                dataStruct.s_hat = s_hat;
                dataStruct.sigma = sigma;
            elseif isfield(dataStruct, 'likelihood_peak') && isfield(dataStruct, 'likelihood_width')
                s_hat = dataStruct.likelihood_peak;
                sigma = dataStruct.likelihood_width;
            end
            
            s_hat = s_hat(:);
            sigma2 = sigma(:).^2;
            sigma2 = 1./(1./sigma2 + 1./self.priorSigma2);
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
    
end