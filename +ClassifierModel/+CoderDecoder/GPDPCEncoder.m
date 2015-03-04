classdef GPDPCEncoder < handle
    % GPENCODER Gaussian process based deterministic population encoder of 
    % the orientation stimuli (tuning curve based)
    %   Note that this is a DETERMINISTIC encoder (i.e. same stimulus
    %   always elicit identical responses). To make this into a PPC
    %   encoder, wrap it with a noise model such as PoissonNoisePPCodec
    properties
        sigma_obs=2; % baseline observation
        sigma_kernel=20; % Covariance kernel smoothness parameter
        
        trainStimulus=[]; % Stimulus values on which GP was trained
        alpha; % weight vector (?)
        y_bias; % bias in the firing rate
        NUM_UNITS; % number of recording units
    end
    
    methods
        function obj=GPDPCEncoder(NUM_UNITS)
            if nargin < 1
                NUM_UNITS = 96; % default to Utah array
            end
            % Constructer that takes in number of units
            obj.NUM_UNITS=NUM_UNITS;
            obj.alpha(NUM_UNITS)=0;
            obj.y_bias(NUM_UNITS, 1)=0;
            
        end
        
        function obj = restrict(self, units)
            numUnits = sum(units);
            obj = ClassifierModel.CoderDecoder.GPDPCEncoder(numUnits);
            obj.sigma_obs = self.sigma_obs;
            obj.sigma_kernel = self.sigma_kernel;
            obj.trainStimulus = self.trainStimulus;
            obj.alpha = self.alpha(units, :);
            obj.y_bias = self.y_bias(units);
        end
        
        function train(self, stimulus, contrast, spikeCounts)
            % TRAIN Fit the GP-based tuning curves onto the training set
            % consisting of stimulus, contrast and recorded spikeCounts.
            
            if isstruct(stimulus) % if first argument is a structure
                dataSet = stimulus;
                stimulus = dataSet.orientation;
                contrast = dataSet.contrast;
                spikeCounts = dataSet.counts;
            end
            
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
            figure;
            % Plot out resultant tuning functions
            % Currently implemented dirtily just to get the desired plot
            % when plotting for total of 96 units - ought to generalize it!
            margin = 0.05;
            w = (1 - 2*margin)/10;
            ROW = ceil(sqrt(self.NUM_UNITS));
            COL = ceil(self.NUM_UNITS/ROW);
            lb = 230;%min(self.trainStimulus);
            ub = 310;%max(self.trainStimulus);
            stim = linspace(lb, ub, 100);
            spikeCounts = self.encode(stim);
            indSkip = [1, 10, 91, 100];
            count = 1;
            for indUnit=1:100
                if ismember(indUnit, indSkip)
                    continue;
                end
                %hax=subplot(ROW,COL,indUnit);
                hax = axes;
                scale=max(spikeCounts(count,:))-min(spikeCounts(count,:));
                hf=plot(stim,(spikeCounts(count,:)-min(spikeCounts(count,:)))/scale);
                xlabel([]);
                ylabel([]);
                set(hax,'Position',[margin+w*floor((indUnit-1)/10), margin + w*mod(indUnit-1, 10), w, w]);
                set(hax,'xtick',[],'ytick',[]);
                set(hax,'xticklabel',[]);
                set(hax,'yticklabel',[]);
                count = count + 1;
                xlim([lb, ub]);
                ylim([-.05,1.05])
                %ylim([0, 10]);
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
        
        function configSet = getModelConfigs(self)
            % Returns a structure with all configurable component for the
            % model. This includes ALL (fixed and non-fixed) parameters,
            % fix map, bounds, and model name
            
            configSet = [];
            configSet.sigma_obs = self.sigma_obs;
            configSet.sigma_kernel = self.sigma_kernel;
            configSet.trainStimulus = self.trainStimulus;
            configSet.alpha = self.alpha;
            configSet.y_bias = self.y_bias;
            configSet.NUM_UNITS = self.NUM_UNITS;
        end
        
        function setModelConfigs(self, configSet)
            self.sigma_obs = configSet.sigma_obs;
            self.sigma_kernel = configSet.sigma_kernel;
            self.trainStimulus = configSet.trainStimulus;
            self.alpha = configSet.alpha;
            self.y_bias = configSet.y_bias;
            self.NUM_UNITS = configSet.NUM_UNITS;
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