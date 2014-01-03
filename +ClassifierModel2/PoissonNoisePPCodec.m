classdef PoissonNoisePPCodec < ClassifierModel.PPCEncoder
    % POISSONNOISEPPCodec Takes the base DPCEncoder and "wraps" it with
    % Poisson noise based coder-decoder (codec).
    properties
        baseEncoder; % underlying deterministic population code encoder
    end
    
    methods
        function obj = PoissonNoisePPCodec(baseEncoder)
            % Constructer for PoissonNoisePPCWrapper that takes base
            % DPC encoder
            obj.baseEncoder = baseEncoder;
        end
        
        function spikeCounts = encode(self, stimulus, contrast)
            % ENCODE Takes in stimulus and contrast and encode
            % probabilistic population coding
            spikeCounts = self.baseEncoder.encode(stimulus, contrast); % obtains base deterministic population code
            spikeCounts = poissrnd(spikeCounts); % add Poisson noise
        end
        
        function muLL = train(self, stimulus, contrast, spikeCounts, nRepeats)
            % TRAIN Warning! - This function has not been implemented
            % appropriately yet! Currently, it simply uses train method
            % provided by the base encoder
            if (nargin < 5)
                nRepeats = 1; % number of times to randomize the initial condition
            end
            
            paramSet = self.baseEncoder.getModelParameters();
            numParam = paramSet.numParameters;
            x0 = paramSet.initValues;
            lb = paramSet.lowerBounds;
            ub = paramSet.upperBounds;
            function cost = cf(x)
                self.setModelParameters(x);
                cost = -self.getLogLikelihood(stimulus, contrast, spikeCounts);
            end
            %[x, cost] = ga(@cf, numParam, [], [], [], [], lb, ub);
            [x, cost] = fmincon(@cf, x0, [], [], [], [], lb, ub); 
            self.setModelParameters(x);
            muLL = -cost; % return final mean log likelihood
        end
        
        function logLList = getLogLikelihood(self, stimulus, contrast, spikeCounts)
            % GETLOGLIKELIHOOD Evaluate the log likelihood of observing the 
            % spikeCounts for given stimulus for each units per trial
            F = self.baseEncoder.encode(stimulus, contrast);
            %logLList = -F + log(F).* spikeCounts - gammaln(spikeCounts+1);
            logLList = log(poisspdf(spikeCounts, F));
        end
        
        function L = getLikelihoodDistr(self, decodeOri, contrast, spikeCounts)
            % GETLIKELIHOODDISTR Calculates the likelihood distribution
            % over the range of orientation (decodeOri) for observing given
            % set of spikeCounts for each trial
            F = self.baseEncoder.encode(decodeOri, contrast)'; % assumes that base encoder is deterministic
            logL = bsxfun(@minus, bsxfun(@minus, log(F)*spikeCounts, sum(F,2)), sum(gammaln(spikeCounts+1) ,1));
            normL = exp(bsxfun(@minus, logL, max(logL))); % max normalized likelihood
            L = bsxfun(@rdivide, normL, sum(normL)); %likelihood function with normalized area
        end
         
        function setModelParameters(self, paramValues)
            % SETMODELPARAMETERS Sets the value of model parameters based
            % on paramValues argument. If there are internal model
            % structures, then the first n paremeters needed for this level
            % is taken and the rest is passed onto internal model(s).
            self.baseEncoder.setModelParameters(paramValues);
        end
        
        function paramSet = getModelParameters(self)
            % GETPARAMETERS Returns a structure containing information about
            % underlying model parameters needed for optimization/training
            paramSet=self.baseEncoder.getModelParameters();
        end
    end
end