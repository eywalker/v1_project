classdef PoissonNoisePPCodec < handle
    % POISSONNOISEPPCodec Takes the base DPCEncoder and "wraps" it with
    % Poisson noise based coder-decoder (codec).
    properties
        baseEncoder; % underlying deterministic population code encoder
        filterThreshold = -3;
        unitFilter = ':'; % filter out bad units when computing likelihood distr
    end
    
    methods
        function obj = PoissonNoisePPCodec(baseEncoder)
            % Constructer for PoissonNoisePPCWrapper that takes base
            % DPC encoder
            if nargin > 0
                obj.baseEncoder = baseEncoder;
            end
        end
        
        function spikeCounts = encode(self, stimulus, contrast)
            % ENCODE Takes in stimulus and contrast and encode
            % probabilistic population coding
            spikeCounts = self.baseEncoder.encode(stimulus, contrast); % obtains base deterministic population code
            spikeCounts = poissrnd(spikeCounts); % add Poisson noise
        end
        
        function muLL = train(self, dataSet)
            self.baseEncoder.train(dataSet);
            orientation = [dataSet.orientation];
            contrast = [dataSet.contrast];
            counts = [dataSet.counts];
            muLL = mean(self.getLogLikelihood(orientation, contrast, counts), 2);
            self.unitFilter = muLL > self.filterThreshold;
        end
        
%         function muLL = train(self, stimulus, contrast, spikeCounts, nRepeats)
%             % TRAIN Trains the poisson noise codec by woring together with
%             % the underlying encoder.
%             if (nargin < 5)
%                 nRepeats = 1; % number of times to randomize the initial condition
%             end
%             
%             paramSet = self.baseEncoder.getModelParameters();
%             x0 = paramSet.initValues;
%             lb = paramSet.lowerBounds;
%             ub = paramSet.upperBounds;
%             function cost = cf(x)
%                 self.setModelParameters(x);
%                 cost = -self.getLogLikelihood(stimulus, contrast, spikeCounts);
%             end
%             %[x, cost] = ga(@cf, numParam, [], [], [], [], lb, ub);
%             [x, cost] = fmincon(@cf, x0, [], [], [], [], lb, ub); 
%             self.setModelParameters(x);
%             muLL = -cost; % return final mean log likelihood
%         end
        
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
            % set of spikeCounts and contrast value for each trial
            F = self.baseEncoder.encode(decodeOri, contrast)'; % assumes that base encoder is deterministic
            
            F  = F(:, self.unitFilter);
            spikeCounts = spikeCounts(self.unitFilter, :);
            
            logL = bsxfun(@minus, bsxfun(@minus, log(F)*spikeCounts, sum(F,2)), sum(gammaln(spikeCounts+1) ,1));
            normL = exp(bsxfun(@minus, logL, max(logL))); % max normalized likelihood
            L = bsxfun(@rdivide, normL, sum(normL)); %likelihood function with normalized area
        end
        
        function L = getLikelihoodDistrWithContrastPrior(self, decodeOri, contValues, contPrior, spikeCounts)
            contPrior(contPrior < 0) = 0;
            if length(contPrior)==1
                contPrior = ones(1,length(contValues));
            end
            contPrior = contPrior / sum(contPrior); % ensure contPrior is a valid prior over contrast values
%             L = 0;
%             shiftL = 0;
            for ind = 1 : length(contValues)
                contVal = contValues(ind);
                pC = contPrior(ind);
                F = self.baseEncoder.encode(decodeOri, contVal)';
                logLStack(:,:,ind) = bsxfun(@plus, bsxfun(@minus, bsxfun(@minus, log(F)*spikeCounts, sum(F,2)), sum(gammaln(spikeCounts+1) ,1)), log(pC));
%                 if(ind == 1)
%                     shiftL = max(logL);
%                 end
%                 normL = exp(bsxfun(@minus, logL, shiftL));
%                 L = L + normL;
            end
            maxLogL = max(max(logLStack, [], 1),[],3);
            normLL = bsxfun(@minus, logLStack, maxLogL);
            L = sum(exp(normLL),3);
            L = bsxfun(@rdivide, L, sum(L));
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
        
        function configSet = getModelConfigs(self)
            % Returns a structure with all configurable component for the
            % model. This includes ALL (fixed and non-fixed) parameters,
            % fix map, bounds, and model name
            configSet = [];
            configSet.filterThreshold = self.filterThreshold;
            configSet.unitFilter = self.unitFilter;
            configSet.baseEncoder = class(self.baseEncoder);
            configSet.baseEncoderConfig = self.baseEncoder.getModelConfigs();
        end
        
        function setModelConfigs(self, configSet)
            self.filterThreshold = configSet.filterThreshold;
            self.unitFilter = configSet.unitFilter;
            self.baseEncoder = eval(configSet.baseEncoder);
            self.baseEncoder.setModelConfigs(configSet.baseEncoderConfig);
        end  
    end
end