classdef PoissonLikeDecoder < handle
    % POISSONLIKEDECODER Given spike data, returns can decode likelihood
    % function over the stimulus
    properties
        nbins; % number of bins to divide stimulus domain into
        w; % Poisson like kernel logistic weigths
        bincc; % bin center for logistic fits
        unitFilter = ':'; % filter out bad units when computing likelihood distr
    end
    
    methods
        function obj = PoissonLikeDecoder(nbins)
            % Constructer for PoissonLikeCodec
            if nargin > 0
                obj.nbins = nbins;
            else
                obj.nbins = 10;
            end
        end
        

        
        function train(self, dataSet)

            counts = dataSet.counts;
            ori = dataSet.orientation;
            n_prc = self.nbins;
            edges = prctile(dataSet.orientation, linspace(0,100, n_prc));
            n_labels = length(edges) - 1;
            labels = sum(bsxfun(@le, edges(1:end-1), ori(:)), 2);
            binc = 0.5 * (edges(1:end-1) + edges(2:end));
            N = size(counts, 1);

            w = zeros(N, n_labels - 1);
            wo = w;
            for i = 1:n_labels - 1
                pos = labels == i | labels == i + 1;
                r  = counts(:, pos);
                lbl = labels(pos) == (i+1);
                v = glmfit(r', lbl, 'binomial', 'link', 'logit', 'constant', 'off');
                wo(:, i) = v;
                w(:, i) = v / (binc(i+1) - binc(i));
            end

            bincc = 0.5 * (binc(1:end-1) + binc(2:end));
            
            self.w = w;
            self.bincc = bincc;
            

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
            
            deltaS = decodeOri(2) - decodeOri(1);

            dh = interp1(self.bincc, self.w', decodeOri, 'PCHIP', 0);
            h = cumsum(dh, 1) * deltaS;
            
            plot(decodeOri, h);
            
            logL = h * spikeCounts;
            normL = exp(bsxfun(@minus, logL, max(logL))); % max normalized likelihood
            normL(isnan(normL)) = 0;
            L = bsxfun(@rdivide, normL, sum(normL)); %likelihood function with normalized area
        end
        
        
        function configSet = getModelConfigs(self)
            % Returns a structure with all configurable component for the
            % model. This includes ALL (fixed and non-fixed) parameters,
            % fix map, bounds, and model name
            configSet = [];
            configSet.nbins = self.nbins;
            configSet.w = self.w;
            configSet.bincc = self.bincc;
        end
        
        function setModelConfigs(self, configSet)
            self.nbins = configSet.nbins;
            self.w = configSet.w;
            self.bincc = configSet.bincc;
        end  
    end
end