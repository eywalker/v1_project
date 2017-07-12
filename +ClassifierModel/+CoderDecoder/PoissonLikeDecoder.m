classdef PoissonLikeDecoder < handle
    % POISSONLIKEDECODER Given spike data, returns can decode likelihood
    % function over the stimulus
    properties
        binWidth; % binWidth for adj bin logistic regression
        h; % Poisson like kernel
        ori; % ori bins
    end
    
    methods
        function obj = PoissonLikeDecoder(binWidth)
            % Constructer for PoissonLikeCodec
            if nargin > 0
                obj.binWidth = binWidth;
            else
                obj.binWidth = 5;
            end
        end
        
        function spikeCounts = encode(self, stimulus, contrast)
            % ENCODE Takes in stimulus and contrast and encode
            % probabilistic population coding
            spikeCounts = self.baseEncoder.encode(stimulus, contrast); % obtains base deterministic population code
            spikeCounts = poissrnd(spikeCounts); % add Poisson noise
        end
        
        function train(self, dataSet)
            [ori, h] = fitPoissonLike(self.binWidth, dataSet);
            self.ori = ori;
            self.h = h;
        end
        
%         function logLList = getLogLikelihood(self, stimulus, contrast, spikeCounts)
%             % GETLOGLIKELIHOOD Evaluate the log likelihood of observing the 
%             % spikeCounts for given stimulus for each units per trial
%             F = self.baseEncoder.encode(stimulus, contrast);
%             %logLList = -F + log(F).* spikeCounts - gammaln(spikeCounts+1);
%             logLList = log(poisspdf(spikeCounts, F));
%             
%         end
        
        function L = getLikelihoodDistr(self, decodeOri, contrast, spikeCounts)
            % GETLIKELIHOODDISTR Calculates the likelihood distribution
            % over the range of orientation (decodeOri) for observing given
            % set of spikeCounts and contrast value for each trial
            crudeLL = self.h' * spikeCounts;
            logL = interp1(self.ori, crudeLL, decodeOri, 'cubic');
            normL = exp(bsxfun(@minus, logL, max(logL))); % max normalized likelihood
            normL(isnan(normL)) = 0;
            L = bsxfun(@rdivide, normL, sum(normL)); %likelihood function with normalized area

%             L = interp1(self.ori, crudeL, decodeOri, 'cubic', NaN);
%             L(isnan(L)) = 0;
%             L = bsxfun(@rdivide, L, sum(L));
            %L(L < 0) = 0;

        end
        
        
        function configSet = getModelConfigs(self)
            % Returns a structure with all configurable component for the
            % model. This includes ALL (fixed and non-fixed) parameters,
            % fix map, bounds, and model name
            configSet = [];
            configSet.binWidth = self.binWidth;
            configSet.ori = self.ori;
            configSet.h = self.h;
        end
        
        function setModelConfigs(self, configSet)
            self.binWidth = configSet.binWidth;
            self.ori = configSet.ori;
            self.h = configSet.h;
        end  
    end
end