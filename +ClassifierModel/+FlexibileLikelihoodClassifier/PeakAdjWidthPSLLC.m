classdef PeakAdjWidthPSLLC < ClassifierModel.FlexibileLikelihoodClassifier.PointPSLLC
    % Posterior-Sampling with Lapse rate based Likelihood Classifier that
    % extracts center while learning an optimal width. This should be
    % mathematically equivalent to PeakWidthPSLLC but here the learned
    % width is made explicit.

    properties
        width = 5; % learned width of the likelihood function
    end
    
    methods
        function obj = PeakAdjWidthPSLLC(sigmaA, sigmaB, stimCenter, modelName, pointExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 5
                pointExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            if nargin < 4
                modelName = 'AdjustedWidthPSCLL';
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.FlexibileLikelihoodClassifier.PointPSLLC(sigmaA, sigmaB, stimCenter, modelName, pointExtractor);
            obj.params = [obj.params {'width'}];
            obj.fixedParams = [obj.fixedParams false];
            obj.p_lb = [obj.p_lb 0];
            obj.p_ub = [obj.p_ub 30];
        end
    end
    
    methods (Access = protected)
        function [logLRatio, dataStruct] = getLogLRatio(self, dataStruct) %decodeOri, likelihood)
            if isfield(dataStruct, 'computed_peak')
                s_hat = dataStruct.computed_peak;
            elseif isfield(dataStruct, 'decodeOri') && isfield(dataStruct, 'likelihood')
                decodeOri = dataStruct.decodeOri;
                likelihood = dataStruct.likelihood;
                s_hat = self.pointExtractor(decodeOri, likelihood);% extract center and width of the likelihood function
                dataStruct.computed_peak = s_hat;
            elseif isfield(dataStruct, 'likelihood_peak')
                s_hat = dataStruct.likelihood_peak;
            end

            s_hat = s_hat(:);
            sigma = self.width; % the width of the curve is learned explicitly
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
end
