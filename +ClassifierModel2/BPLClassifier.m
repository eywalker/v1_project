classdef BPLClassifier < ClassifierModel.Classifier
    % BPLCLASSIFIER Full Bayesian Classifier with free prior
    % and lapse rate (BP-L model)
    %   This class represents Bayesian behavioral orientation stimulus
    %   classifier with free prior over stimulus category and lapse rate.
    properties
        priorA = 0.5; % prior over category 'A'
        sigmaA; % standard devation of category 'A'
        sigmaB; % standard deviation of category 'B'
        stimCenter = 0; % center of stimulus distribution for both category
        sigma = 5; % standard deviation of the sensory noise
        lapseRate = 0; % lapse rate for stimulus category classification
        beta0 = 0; % parameters for logistic fit to sigma = exp(beta0 + beta1 * contrast)/(1 + exp(beta0 + beta1 * contrast)
        beta1 = -1;
    end
    
    methods (Static)
        function [muLL, listLL] = modelLogLikelihood(sigmaA, sigmaB, priorA, sigma, lapseRate, stimCenter, stimulus, contrast, response)
            % MODELLOGLIKELIHOOD Static functio to calculate log likelihood
            % given full set of parameters.
            %   BayesianBehaviorClassifier.modelLogLikelihood(sigmaA, sigmaB,
            %   priorA, sigma, lapseRate, stimCenter, stimulus, contrast response) returns
            %   the calculated logLikelihood under 
            respA = strcmp(response, 'A'); % trials for which subject responded class 'A'
            respB = ~respA; % trials for which subject responded 'B'
            
            s = stimulus-stimCenter; % deviation of stimulus from the center of distribution
            k1 = 1/2*log((sigma.^2+sigmaB.^2)./(sigma.^2+sigmaA.^2))+log(priorA./(1-priorA));
            k2 = (sigmaB.^2-sigmaA.^2)./(2*(sigma.^2+sigmaA.^2)*(sigma.^2+sigmaB.^2));
            k = sqrt(k1./k2);
            
            % check if k is real. If it is not, p(responding 'A') = 0
            if(~isreal(k))
                listLL = zeros(1,length(stimulus));
                listLL(respA) = -Inf;
                muLL = mean(listLL);
                return
            end
            
            pCAs = ((1/2)*(erf((s+k)/sigma/sqrt(2))-erf((s-k)./sigma./sqrt(2)))); % p(C='A' | s)
            L = pCAs*(1-lapseRate)+lapseRate*0.5; % incorporation of lapse rate
            L(respB) = 1-L(respB); % invert probabilites for trials where response was 'B'
            
            listLL = log(max(L,realmin)); % avoid taking log of 0
            muLL = mean(listLL); % return average log likelihood
        end
    end
    
    methods
        function obj = BPLClassifier(sigmaA, sigmaB, stimCenter)
            % BAYESIANBEHAVIORALCLASSIFIER Constructer that takes in sigmaA,
            % sigmaB and stimCenter describing the experiment
            obj.sigmaA = sigmaA;
            obj.sigmaB = sigmaB;
            obj.stimCenter = stimCenter;
        end
        
        function response = classify(self, stimulus, contrast)
            % CLASSIFY Runs simulated classification of stimulus according to
            % the current model parameters
            pA = self.pRespAGivenS(stimulus, contrast);
            n = rand(size(stimulus));
            response = cell(size(stimulus));
            for ind = 1:length(response)
                if(pA(ind) > n(ind))
                    response{ind} = 'A';
                else
                    response{ind} = 'B';
                end
            end
        end
        
        function muLL = train(self, stimulus, contrast, response, nReps)
            % TRAIN Trains and optimize classifier using the training data set
            % {stimulus, response}
            if nargin < 10
                nReps = 5;
            end
            function cost=cf(param) % cost function for optimization, defined as negative log-likelihood
                self.priorA=abs(param(1));
                self.sigma=abs(param(2));
                self.lapseRate=abs(param(3));
                cost = -self.getLogLikelihood(stimulus, contrast, response);
            end
            
            minX = [self.priorA, self.sigma, self.lapseRate];
            minCost = cf(minX);
            
            for i = 1 : nReps
                x0(1) = rand;
                x0(2) = rand * 100;
                x0(3) = rand;
                [x, cost] = fmincon(@cf, x0, [], [], [], [], [0.000,0.000,0.0000],[1,Inf,1]);
                if (cost < minCost)
                    minCost = cost;
                    minX = x;
                end
            end
            
            self.priorA = minX(1);
            self.sigma = minX(2);
            self.lapseRate = minX(3);
            muLL = -minCost; % obtain the final trial-average log liklihood value attained
        end
        
        function [muLL, listLL] = getLogLikelihood(self, stimulus, contrast, response)
            % GETLOGLIKELIHOOD Calculate the log-likelihood for given
            % {stimulus, response} set based on current model settings
            [muLL, listLL] = ClassifierModel.BPLClassifier.modelLogLikelihood(self.sigmaA, self.sigmaB, self.priorA,...
                self.sigma, self.lapseRate, self.stimCenter, stimulus, contrast, response);
            
        end
        
        function p = pRespAGivenS(self, stimulus, contrast)
            % PRESPAGIVENS Returns the probability of responding class 'A'
            % given the stimulus
            s = stimulus-self.stimCenter;
            k1 = 1/2*log((self.sigma.^2+self.sigmaB.^2)./(self.sigma.^2+self.sigmaA.^2))+log(self.priorA./(1-self.priorA));
            k2 = (self.sigmaB.^2-self.sigmaA.^2)./(2*(self.sigma.^2+self.sigmaA.^2)*(self.sigma.^2+self.sigmaB.^2));
            k = sqrt(k1./k2);
            
            if(~isreal(k))
                p=zeros(size(stimulus));
                return;
            end
            
            LCA = ((1/2)*(erf((s+k)/self.sigma/sqrt(2))-erf((s-k)./self.sigma./sqrt(2)))); % p(C='A' | s);
            p = LCA*(1-self.lapseRate)+self.lapseRate*0.5;
        end
        
        function setModelParameters(self, paramValues)
            % SETPARAMETERS Sets the model parameters to the
            % specified values.
            %   WARNING: You have to know the correct number and condition of
            %   the parameters before setting them.
            self.priorA = paramValues(1);
            self.sigma = paramValues(2);
            self.lapseRate = paramValues(3);
        end
        
        function paramSet = getModelParameters(self)
            % GETPARAMETERS Returns a structure containing information about
            % model parameters needed for optimization/training
            paramSet = [];
            paramSet.numParameters = 3;
            paramSet.initValues = [self.priorA, self.sigma, self.lapseRate];
            paramSet.lowerBounds = [0, ...
                                    0, ...
                                    0];
            paramSet.upperBounds = [1, ...
                                    Inf, ...
                                    1];
        end
    end

    
end

