classdef GaussianDPCEncoder < handle
    % GPENCODER Gaussian process based deterministic population encoder of 
    % the orientation stimuli (tuning curve based)
    %   Note that this is a DETERMINISTIC encoder (i.e. same stimulus
    %   always elicit identical responses). To make this into a PPC
    %   encoder, wrap it with a noise model such as PoissonNoisePPC
    properties
        mu;
        sigma;
        gain;
        NUM_UNITS; % number of recording units
    end
    
    methods
        function obj=GaussianDPCEncoder(NUM_UNITS)
            % Constructer that takes in number of units
            obj.NUM_UNITS=NUM_UNITS;
            obj.mu(NUM_UNITS)=0;
            obj.sigma=ones(1,NUM_UNITS);
            obj.gain=ones(1,NUM_UNITS);
        end
        
        function train(self, stimulus, contrast, spikeCounts)
            % Fit the GP-based tuning curves onto the training set
            sigma_obs = self.sigma_obs;
            sigma_kernel = self.sigma_kernel;
            x = stimulus(:);
            self.trainStimulus = stimulus;
            self.alpha = zeros(self.NUM_UNITS,length(stimulus));
            for indUnit = 1:self.NUM_UNITS
                y = spikeCounts(indUnit,:);
                
                self.y_bias(indUnit) = mean(y);

                K = cov_kernel(x,x,1/sigma_kernel^2);

                L = chol(K+sigma_obs^2*eye(size(K,1)),'lower');
                alpha = L'\(L\(y'-self.y_bias(indUnit)));
                self.alpha(indUnit,:) = alpha;
            end
        end
        
        function spikeCounts = encode(self, stimulus, contrast)
            % ENCODE Encode the given stimulus and contrast into spike counts.
            % Returns spike count array of N x T wher N is number of units and
            % T is number of trials
            spikeCounts = zeros(self.NUM_UNITS,length(stimulus));
            for indUnit = 1:self.NUM_UNITS
                spikeCounts(indUnit,:) = self.gain(indUnit)*...
                    normpdf(stimulus,self.mu(indUnit),self.sigma(indUnit))*sqrt(2*pi)*self.sigma(indUnit);
            end
        end
        
        function plot(self)
            % Plot out resultant tuning functions
            ROW = ceil(sqrt(self.NUM_UNITS));
            COL = ceil(self.NUM_UNITS/ROW);
            xlb = min(self.mu - 3 * self.sigma);
            xub = max(self.mu + 3 * self.sigma);
            yub = max(self.gain) * 1.05;
            stim = linspace(xlb, xub, 100);
            spikeCounts = self.encode(stim, []);
            for indUnit=1:self.NUM_UNITS
                subplot(ROW, COL, indUnit);
                plot(stim, spikeCounts(indUnit, :));
                axis([xlb xub 0 yub]);
            end
        end
        
        function setModelParameters(self, paramValues)
            % SETPARAMETERS Immeidately sets the model parameters to the
            % specified values.
            %   WARNING: You have to know the correct number and condition of
            %   the parameters before setting them.
            self.mu = paramValues(1 : self.NUM_UNITS);
            self.sigma = paramValues(self.NUM_UNITS + 1 : 2 * self.NUM_UNITS);
            self.gain = paramValues(2 * self.NUM_UNITS + 1 : 3 * self.NUM_UNITS);
        end
        
        function paramSet = getModelParameters(self)
            % GETPARAMETERS Returns a structure containing information about
            % model parameters needed for optimization/training
            paramSet = [];
            paramSet.numParameters = 3 * self.NUM_UNITS;
            paramSet.initValues = [self.mu, self.sigma, self.gain];
            paramSet.lowerBounds = [-Inf * ones(1, self.NUM_UNITS), ...
                                    zeros(1, self.NUM_UNITS), ...
                                    zeros(1, self.NUM_UNITS)];
            paramSet.upperBounds = [Inf * ones(1, 3 * self.NUM_UNITS)];
        end
        
    end
end