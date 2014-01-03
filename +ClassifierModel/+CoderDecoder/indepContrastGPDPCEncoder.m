classdef indepContrastGPDPCEncoder < handle
    % GPENCODER Gaussian process based deterministic population encoder of 
    % the orientation stimuli (tuning curve based)
    %   Note that this is a DETERMINISTIC encoder (i.e. same stimulus
    %   always elicit identical responses). To make this into a PPC
    %   encoder, wrap it with a noise model such as PoissonNoisePPCodec
    properties
        c; %center of the sigmoid
        k; %slope of the sigmoid function
        
        sigma_obs=1; % baseline observation
        sigma_kernel=10; % Covariance kernel smoothness parameter
        
        trainStimulus=[]; % Stimulus values on which GP was trained
        alpha; % weight vector (?)
        y_bias; % bias in the firing rate
        NUM_UNITS; % number of recording units
    end
    
    methods
        function obj=indepContrastGPDPCEncoder(NUM_UNITS)
            % Constructer that takes in number of units
            obj.NUM_UNITS=NUM_UNITS;
            obj.alpha(NUM_UNITS)=0;
            obj.y_bias(NUM_UNITS, 1)=0;
            
            obj.c = 0.5 * ones(NUM_UNITS, 1);
            obj.k = ones(NUM_UNITS, 1);
            
        end
        
        function obj = restrict(self, units)
            numUnits = sum(units);
            obj = ClassifierModel.GPDPCEncoder(numUnits);
            obj.sigma_obs = self.sigma_obs;
            obj.sigma_kernel = self.sigma_kernel;
            obj.trainStimulus = self.trainStimulus;
            obj.alpha = self.alpha(units, :);
            obj.y_bias = self.y_bias(units);
        end
        
        function logLList = train(self, stimulus, contrast, spikeCounts, nReps)
            if nargin < 6
                nReps = 10; % defaults to 10 repetitions of training
            end
            
            
            self.trainStimulus = stimulus;
            self.alpha = zeros(self.NUM_UNITS,length(stimulus));
            logLList = zeros(self.NUM_UNITS,1);
            for indUnit = 1:self.NUM_UNITS
                logLList(indUnit) = trainUnit(self, stimulus, contrast, spikeCounts, indUnit, nReps);
            end
        end
        
        function LL = trainUnit(self, stimulus, contrast, spikeCounts, indUnit, nReps)
            
            function cost = cf(param)
                c = param(1);
                k = param(2);
                g = 1./(1+exp(-k * (contrast - c)));
                scaledSpikes = spikeCounts(indUnit, :) ./ g;
                [~, ~, LL] = gpFit(self, stimulus, scaledSpikes);
                cost = -LL;
            end
            
            
            
            minCost = Inf;
            
            paramLB = [0; 0];
            paramUB = [1; 300];
            for i = 1 : nReps
                x0(1) = rand;
                x0(2) = rand * 1000;
                [x, cost] = fmincon(@cf, x0, [], [], [], [], paramLB, paramUB);
                if (cost < minCost)
                    minCost = cost;
                    minX = x;
                end
            end
            self.c(indUnit) = minX(1);
            self.k(indUnit) = minX(2);
            
            c = minX(1);
            k = minX(2);
            g = 1./(1+exp(-k * (contrast - c)));
            scaledSpikes = spikeCounts(indUnit, :) ./ g;
            [y_bias, alpha, LL] = gpFit(self, stimulus, scaledSpikes);
            
            self.y_bias(indUnit) = y_bias;
            self.alpha(indUnit, :) = alpha;
            
        end
        
        function [y_bias, alpha, LL] = gpFit(self, x, y)
            sigma_obs = self.sigma_obs;
            sigma_kernel = self.sigma_kernel;
            x = x(:);
            y = y(:)';

            y_bias = mean(y);

            K = cov_kernel(x,x,1/sigma_kernel^2);

            L = chol(K+sigma_obs^2*eye(size(K,1)),'lower');
            alpha = L'\(L\(y'-y_bias));
            
            LL = -1/2 * y * alpha - trace(log(L)) - length(x)/2 * log(2*pi);
        end
        
        function spikeCounts = encode(self, stimulus, contrast)
            % ENCODE Encode the given stimulus into spike counts
            spikeCounts=zeros(self.NUM_UNITS,length(stimulus));
            for indUnit=1:self.NUM_UNITS
                alpha=self.alpha(indUnit,:)';
                K_test = cov_kernel(stimulus(:), self.trainStimulus(:), 1/self.sigma_kernel^2);
                f = K_test * alpha+self.y_bias(indUnit);
                spikeCounts(indUnit,:)=f;
            end
            spikeCounts(spikeCounts(:)<0)=0.1; % give base line firing rate: all rate<0 is set to this value
        end
        
        function plot(self)
            % Plot out resultant tuning functions
            ROW = ceil(sqrt(self.NUM_UNITS));
            COL = ceil(self.NUM_UNITS/ROW);
            stim = linspace(min(self.trainStimulus),max(self.trainStimulus),100);
            spikeCounts = self.encode(stim,[]);
            for indUnit=1:self.NUM_UNITS
                subplot(ROW,COL,indUnit);
                plot(stim,spikeCounts(indUnit,:));
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

function K = cov_kernel(x1,x2,prec)
    % COV_KERNEL Helper function that calculates covariance kernel for the
    % Gaussian process
    K = zeros(size(x1,1),size(x2,1));
    for i = 1:size(x1,1)
        d = bsxfun(@minus,x1(i,:),x2);
        K(i,:) =  sum(exp(- 1/2 * (d * prec) .* d),2)';
    end
end
    

