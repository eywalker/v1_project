classdef ContrastAdjustedGPDPCEncoder < handle
    % Gaussian process based deterministic population encoder of 
    % the orientation stimuli (tuning curve based) with contrast
    % adjustments.
    %
    % This model extends the standard Gaussian Process based DPC by
    % assuming that the contrast only modifies the canonical tuning
    % function over orientation by a constant factor. Note that this is not
    % a strict contrast-gain model as no assumption is made about the trend
    % of the gain against the contrast (i.e. the constant gain is a
    % function of contrast but does not need to be of any particular form).
    % 
    % The current implementation of this model does NOT interpolate between
    % contrast values and thus the function's response can only be
    % simulated for set of contrast values used to train the model.
    %
    % Note that this is a DETERMINISTIC encoder (i.e. same stimulus
    % always elicit identical responses). To make this into a PPC
    % encoder, wrap it with a noise model such as PoissonNoisePPCodec
    %
    %
    properties
        contList; % list of contrasts for which tuning function is trained and thus defined
        normBias;
        
        sigma_obs=2; % baseline observation
        sigma_kernel=20; % Covariance kernel smoothness parameter
        
        trainStimulus=[]; % Stimulus values on which GP was trained
        alpha; % weight vector (?)
        y_bias; % bias in the firing rate
        NUM_UNITS; % number of recording units
    end
    
    methods
        function obj=ContrastAdjustedGPDPCEncoder(NUM_UNITS)
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
            obj = ClassifierModel.CoderDecoder.ContrastAdjustedGPDPCEncoder(numUnits);
            obj.contList = self.contList;
            obj.normBias = self.normBias(units,:);
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
            
            contList = sort(unique(contrast));
            contBias = zeros(self.NUM_UNITS, length(contList));
            for (ind = 1:length(contList))
                contVal = contList(ind);
                pos = contrast == contVal; % select trials with specific contrast
                contBias(:, ind) = mean(spikeCounts(:, pos),2);
            end
            % all bias expressed as ratio w.r.t. to the first (lowest contrast)
            normBias = bsxfun(@rdivide , contBias, contBias(:,1)); 
            
            contInd = arrayfun(@(x) find(contList == x), contrast);
            bias = normBias(:, contInd);
            
            spikeCounts = spikeCounts ./ bias;
            
            x = stimulus(:);
            K = cov_kernel(x, x, 1/sigma_kernel^2);
            self.trainStimulus = stimulus;
            self.alpha = zeros(self.NUM_UNITS, length(stimulus));
            for indUnit = 1:self.NUM_UNITS
                y = spikeCounts(indUnit,:);
                
                
                self.y_bias(indUnit) = mean(y);

                L = chol(K+sigma_obs^2*eye(size(K,1)),'lower');
                alpha = L'\(L\(y'-self.y_bias(indUnit)));
                self.alpha(indUnit,:) = alpha;
            end
            
            self.contList = contList;
            self.normBias = normBias;
        end
        
        function spikeCounts = encode(self, stimulus, contrast)
            % ENCODE Encode the given stimulus into spike counts
            if nargin < 3 % no contrast given -> assume highest contrast
                contrast = self.contList(end);
            end
            
            spikeCounts=zeros(self.NUM_UNITS,length(stimulus));
            for indUnit=1:self.NUM_UNITS
                alpha=self.alpha(indUnit,:)';
                K_test = cov_kernel(stimulus(:), self.trainStimulus(:), 1/self.sigma_kernel^2);
                f = K_test * alpha + self.y_bias(indUnit);
                %f = K_test * alpha;
                spikeCounts(indUnit,:)=f;
            end
            contInd = arrayfun(@(x) find(self.contList == x), contrast);
            
            if(length(contInd) == 1) % if only one contrast value given, assume it's the same for all sitmuli
                contInd = contInd * ones(size(stimulus));
            end
            bias = self.normBias(:, contInd);
            spikeCounts = spikeCounts .* bias;
            spikeCounts(spikeCounts(:)<0.01)=0.01; % give base line firing rate: all rate<0.1 is set to this value
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
            lb = min(self.trainStimulus);
            ub = max(self.trainStimulus);
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
                %scale=max(spikeCounts(count,:))-min(spikeCounts(count,:));
                %hf=plot(stim,(spikeCounts(count,:)-min(spikeCounts(count,:)))/scale);
                hf=plot(stim,spikeCounts(count,:));
                xlabel([]);
                ylabel([]);
                set(hax,'Position',[margin+w*floor((indUnit-1)/10), margin + w*mod(indUnit-1, 10), w, w]);
                set(hax,'xtick',[],'ytick',[]);
                set(hax,'xticklabel',[]);
                set(hax,'yticklabel',[]);
                count = count + 1;
                xlim([lb, ub]);
                %ylim([-.05,1.05])
                %ylim([0, 10]);
            end
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
            configSet.contList = self.contList;
            configSet.normBias = self.normBias;
        end
        
        function setModelConfigs(self, configSet)
            self.sigma_obs = configSet.sigma_obs;
            self.sigma_kernel = configSet.sigma_kernel;
            self.trainStimulus = configSet.trainStimulus;
            self.alpha = configSet.alpha;
            self.y_bias = configSet.y_bias;
            self.normBias = configSet.normBias;
            self.contList = configSet.contList;
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
