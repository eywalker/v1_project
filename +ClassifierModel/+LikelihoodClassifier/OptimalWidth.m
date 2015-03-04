classdef OptimalWidth < handle
    % Posterior-Sampling with Lapse rate based Likelihood Classifier
    properties
        sigmaA; % standard deviation of class 'A'
        sigmaB; % standard deviation of class 'B'
        stimCenter; % center of class distributions
        priorA = 0.5; % prior for class 'A'
        alpha = 1; % posterior ratio power
        lapseRate = 0; % lapse rate
        sigma = 5; % width of the likelihood function
        pointExtractor;
        modelName
    end
    
    
    
    
    methods
        function obj = OptimalWidth(sigmaA, sigmaB, stimCenter, modelName, pointExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 4
                modelName = 'OptimizedWidthWithPeak';
            end
            if nargin < 5
                pointExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            if nargin < 3
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            obj.sigmaA = sigmaA;
            obj.sigmaB = sigmaB;
            obj.stimCenter = stimCenter;
            obj.modelName = modelName;
            obj.pointExtractor = pointExtractor;
        end
        
        function pA = pRespA(self, decodeOri, likelihood)
            % PRESPA Returns the probability of the classifier responding 
            % class 'A' given the likelihood function over the orientation
            % decodeOri. Likelhood must have the dimension of D x T where D
            % is the size of decodeOri and T is number of trials
            
            logLRatio = self.getLogLRatio(decodeOri, likelihood);
            pA = self.pRespAHelper(logLRatio);
        end
        
        function classResp = classifyLikelihood(self, decodeOri, likelihood)
            % classifyLikelihood Classifies the given likelihood
            % distribution over decodeOri. Note that this is a stochastic
            % classifier and thus response vaies from run to run. 
            pA = self.pRespA(decodeOri, likelihood);
            nTrials = size(likelihood, 2);
            n = rand(nTrials, 1);
            classResp = cell(nTrials, 1);
            for ind = 1:nTrials
                if(pA(ind) > n(ind))
                    classResp{ind} = 'A';
                else
                    classResp{ind} = 'B';
                end
            end
        end
        
        function [muLL, logLList] = getLogLikelihood(self, decodeOri, likelihood, classResp)
            % GETLOGLIKELIHOOD Returns the log-liklihood of generating
            % response vector classResp given the likilihood functions over
            % orientation for each trial.
            logLRatio = self.getLogLRatio(decodeOri, likelihood);
            [muLL, logLList] = self.getLogLikelihoodHelper(logLRatio, classResp);
        end
        
        function muLL = train(self, decodeOri, likelihood, classResp, nReps)
            fprintf('Training %s', self.modelName);
            % TRAIN Trains the likelihood classifier to learn the model
            if nargin < 5
                nReps = 10; % defaults to 10 repetitions of training
            end
            
             % precompute the log-likelihood ratio
            
            function cost = cf(param)
                self.setModelParameters(param); % update parameter values
                logLRatio = self.getLogLRatio(decodeOri, likelihood);
                cost = -self.getLogLikelihoodHelper(logLRatio, classResp);
                if(isnan(cost) || ~isreal(cost))
                    cost = Inf;
                end
            end
            
            paramSet = self.getModelParameters;
            minX = paramSet.values;
            minCost = min(cf(minX), Inf);
            options=optimset('Display','off','Algorithm','interior-point');%'MaxFunEvals',500,'FunValCheck','on');
            
            for i = 1 : nReps
                fprintf('.');
                x0(1) = rand;
                x0(2) = 100*rand;
                x0(3) = rand;
                x0(4) = 100*rand;
                
                [x, cost] = fmincon(@cf, x0, [], [], [], [], paramSet.lowerBounds, paramSet.upperBounds,[],options);
                if (cost < minCost)
                    minCost = cost;
                    minX = x;
                end
            end
            self.setModelParameters(minX);
            muLL = -minCost;
            fprintf('%2.3f\n',muLL);
        end
        
         
        function setModelParameters(self, paramValues)
            % SETMODELPARAMETERS Immeidately sets the model parameters to the
            % specified values.
            %   WARNING: You have to know the correct number and condition of
            %   the parameters before setting them.
            self.priorA = paramValues(1);
            self.alpha = paramValues(2);
            self.lapseRate = paramValues(3);
            self.sigma = paramValues(4);
        end
        
        function paramSet = getModelParameters(self)
            % GETMODELPARAMETERS Returns a structure containing information about
            % model parameters needed for optimization/training
            paramSet = [];
%             paramSet.numParameters = 2;
%             paramSet.values = [self.priorA, self.alpha];
%             paramSet.lowerBounds = [0, 0];
%             paramSet.upperBounds = [1, Inf];
            paramSet.numParameters = 3;
            paramSet.values = [self.priorA, self.alpha, self.lapseRate, self.sigma];
            paramSet.lowerBounds = [0, 0, 0, 0];
            paramSet.upperBounds = [1, Inf, 1, Inf];
        end
    end
    
    methods (Access = protected)
        function logLRatio = getLogLRatio(self, decodeOri, likelihood)
            s_hat = self.pointExtractor(decodeOri, likelihood); % extract center of the likelihood function
            sigma = self.sigma;
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
        
        function pA = pRespAHelper(self, logLRatio)
            % Helper function that takes log-likelihood ratio of class A to
            % class B ( p(r | C = 'A') / p(r | C = 'B')) and returns the
            % probability of responding 'A' for each trial, incorporating
            % the accentuation (alpha) and lapse rate.
            logPostRatio = logLRatio + log(self.priorA ./ (1 - self.priorA)) ;% log(p(C = 'A' | r) / p(C = 'B' | r))
            p = exp(self.alpha .* logPostRatio); % exponentiated posterior ratio [p(B|~)/p(A|~)]^alpha
            pos = isinf(p);
            expRespA = p ./ (1 + p); % p(responding A | r) for 0 lapse rate
            expRespA(pos) = 1;
            pA = expRespA .* (1 - self.lapseRate) + self.lapseRate * 0.5; % final p(C = 'A') including the lapse rate
        end
        
        function [muLL, logLList] = getLogLikelihoodHelper(self, logLRatio, classResp)
            % GETLOGLIKELIHOODHELPER 
            classResp = classResp(:); % turn it into column vector
            
            respA = strcmp(classResp, 'A'); % trials for which subject responded 'A'
            respB = ~respA; % trials for which subject responded 'B'
            
            pRespA = self.pRespAHelper(logLRatio);
            pRespA = pRespA(:);
            pRespTotal = respA .* pRespA + respB .* (1-pRespA);
            
            logLList = log(abs(pRespTotal));
            muLL = mean(logLList);
        end
        
    end
end