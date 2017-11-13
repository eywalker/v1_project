classdef ExplicitCodingClassifier < ClassifierModel.LikelihoodClassifier.PSLLC
    % Posterior-Sampling with Lapse rate based Classifier that approximates
    % the likelihood function via EXPLICIT CODING  - each neuron "votes"
    % for it's preferred orientation value (the orientation with maximum
    % response) for each spike.
    %
    properties
        scale = 1; % scaling of the likelihood width
        bias = 0; % bias in the likelihood width
    end
    
    methods
        function obj = ExplicitCodingClassifier(sigmaA, sigmaB, stimCenter, modelName)
        % Initializes the object with experiment settings about
        % standard deviation (sigmaA and sigmaB) and center
        % (stimCenter) of two distributions. You can optionally pass in
        % name of the model (modelName)
            if nargin < 4
                modelName = 'ExplicitCodingModel';
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.params = [obj.params {'scale', 'bias'}];
            obj.fixedParams = [obj.fixedParams false false];
            obj.p_lb = [obj.p_lb 0 -Inf];
            obj.p_ub = [obj.p_ub Inf Inf];
            obj.precompLogLRatio = false; % make sure logLRatio gets recomputed with parameter update
        end
        
        
        
    end
    
    methods (Access = protected)
        function [logLRatio, dataStruct] = getLogLRatio(self, dataStruct) %decodeOri, likelihood)
            if isfield(dataStruct, 'explicit_mean') && isfield(dataStruct, 'explicit_std')
                s_hat = dataStruct.explicit_mean;
                sigma = dataStruct.explicit_std;
            else
                decoder = dataStruct.decoder;
                s = linspace(220, 320, 3000);
                resp = decoder.baseEncoder.encode(s, []);
                [~, pos] = max(resp, [], 2);
                peak_ori = s(pos);
                total_counts = decoder.unitFilter' * dataStruct.counts + eps;
                s_hat = (peak_ori .* decoder.unitFilter') * dataStruct.counts ./ total_counts;
                sigma = sqrt((peak_ori.^2 .* decoder.unitFilter') * dataStruct.counts ./ total_counts - s_hat.^2);
                % cache results for faster computation turnaround
                dataStruct.explicit_mean = s_hat;
                dataStruct.explicit_std = sigma;
            end
            
            s_hat = s_hat(:) + self.bias;
            sigma = self.scale * sigma(:); % scale the estimated width of the explictly encoded likelihood width
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
    
end