classdef MLPDecoder < handle
    % MLPDECODER Given spike data, returns decoded likelihood
    % function over the stimulus using trained MLP
    properties
        w1;
        b1;
        w2;
        b2;
        wo;
        bo;
        decodeOri;
        unitFilter = ':'; % filter out bad units when computing likelihood distr
    end
    
    methods
        function obj = MLPDecoder()
            % Constructer for MLPDecoder
        end
        
        function train(self, dataSet)
            error('Training MLP in MATLAB not supported (yet)');
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
            x = spikeCounts;
            x = relu(bsxfun(@plus, self.w1 * x, self.b1));
            x = relu(bsxfun(@plus, self.w2 * x, self.b2));
            x = bsxfun(@plus, self.wo * x, self.bo);
            logL = x;
            %logL = self.wo * relu(self.w2 * relu(self.w1 * spikeCounts + self.b1) + self.b2) + self.bo;
            normL = exp(bsxfun(@minus, logL, max(logL))); % max normalized likelihood
            normL(isnan(normL)) = 0;
            normL = interp1(self.decodeOri, normL, decodeOri, 'pchip', 0);
            L = bsxfun(@rdivide, normL, sum(normL)); %likelihood function with normalized area
        end
        
        
        function configSet = getModelConfigs(self)
            % Returns a structure with all configurable component for the
            % model. This includes ALL (fixed and non-fixed) parameters,
            % fix map, bounds, and model name
            configSet = [];
            configSet.w1 = self.w1;
            configSet.b1 = self.b1;
            configSet.w2 = self.w2;
            configSet.b2 = self.b2;
            configSet.wo = self.wo;
            configSet.bo = self.bo;
            configSet.decodeOri = self.decodeOri;
        end
        
        function setModelConfigs(self, configSet)
            self.w1 = configSet.w1;
            self.b1 = configSet.b1;
            self.w2 = configSet.w2;
            self.b2 = configSet.b2;
            self.wo = configSet.wo;
            self.bo = configSet.bo;
            self.decodeOri = configSet.decodeOri;
        end  
    end
end