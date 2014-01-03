classdef BPLClassifier2 < handle
    % Posterior-Sampling with Lapse rate based Likelihood Classifier
    properties
        sigmaA; % standard deviation of class 'A'
        sigmaB; % standard deviation of class 'B'
        stimCenter; % center of class distributions
        priorA = 0.5; % prior for class 'A'
        sigma = 5; % posterior ratio power
        lapseRate = 0; % lapse rate
        modelName
    end
    

    methods
        function obj = BPLClassifier2(sigmaA, sigmaB, stimCenter, modelName)
            % BAYESIANBEHAVIORALCLASSIFIER Constructer that takes in sigmaA,
            % sigmaB and stimCenter describing the experiment
            if nargin < 4
                modelName = 'BPLClassifier';
            end
            obj.sigmaA = sigmaA;
            obj.sigmaB = sigmaB;
            obj.stimCenter = stimCenter;
            obj.modelName = modelName;
        end
        
        function response = classify(self, stimulus, contrast)
            % CLASSIFY Runs simulated classification of stimulus according to
            % the current model parameters
            pA = self.pRespA(stimulus, contrast);
            n = rand(size(stimulus(:)));
            response = cell(size(stimulus(:)));
            for ind = 1:length(response)
                if(pA(ind) > n(ind))
                    response{ind} = 'A';
                else
                    response{ind} = 'B';
                end
            end
        end
        
        function muLL = train(self, stimulus, contrast, classResp, nReps)
            % TRAIN Trains and optimize classifier using the training data set
            % {stimulus, response}
            fprintf('Training %s', self.modelName);
            if nargin < 5
                nReps = 10;
            end
            function cost=cf(param) % cost function for optimization, defined as negative log-likelihood
                self.setModelParameters(param);
                cost = -self.getLogLikelihood(stimulus, contrast, classResp);
                if(isnan(cost) || ~isreal(cost))
                    cost = Inf;
                end
            end
            
            paramSet = self.getModelParameters;
            minX = paramSet.values;
            minCost = min(cf(minX), Inf);
            options=optimset('Display','off','Algorithm','interior-point');
            

            for i = 1 : nReps
                fprintf('.');
                x0(1) = rand;
                x0(2) = 100*rand;
                x0(3) = rand;
                [x, cost] = fmincon(@cf, x0, [], [], [], [], paramSet.lowerBounds, paramSet.upperBounds,[],options);
                if (cost < minCost)
                    minCost = cost;
                    minX = x;
                end
            end
            self.setModelParameters(minX);
            muLL = -minCost; % obtain the final trial-average log liklihood value attained
            fprintf('%2.3f\n',muLL);
           
        end
        
        function [muLL, logLList] = getLogLikelihood(self, stimulus, contrast, classResp)
            % GETLOGLIKELIHOOD Calculate the log-likelihood for given
            % {stimulus, response} set based on current model settings
            classResp = classResp(:);
            respA = strcmp(classResp, 'A'); % trials for which subject responded 'A'
            respB = ~respA; % trials for which subject responded 'B'
            
            pRespA = self.pRespA(stimulus, contrast);
            pRespA = pRespA(:);
            pRespTotal = respA .* pRespA + respB .* (1-pRespA);
            
            logLList = log(abs(pRespTotal));
            muLL = mean(logLList);
            
        end
        
        function p = pRespA(self, stimulus, contrast)
            % PRESPAGIVENS Returns the probability of responding class 'A'
            % given the stimulus
            s = stimulus-self.stimCenter;
            k1 = 1/2*log((self.sigma.^2+self.sigmaB.^2)./(self.sigma.^2+self.sigmaA.^2))+log(self.priorA./(1-self.priorA));
            k2 = (self.sigmaB.^2-self.sigmaA.^2)./(2*(self.sigma.^2+self.sigmaA.^2)*(self.sigma.^2+self.sigmaB.^2));
            k = sqrt(k1./k2);
            
            if(~isreal(k))
                LCA=zeros(size(stimulus));
            else
                LCA = ((1/2)*(erf((s+k)/self.sigma/sqrt(2))-erf((s-k)./self.sigma./sqrt(2)))); % p(C='A' | s);
            end
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
            paramSet.values = [self.priorA, self.sigma, self.lapseRate];
            paramSet.lowerBounds = [0, ...
                                    0, ...
                                    0];
            paramSet.upperBounds = [1, ...
                                    Inf, ...
                                    1];
        end
    end
end