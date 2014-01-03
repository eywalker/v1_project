classdef NB2LikelihoodClassifier < handle
    % NBLIKELIHOODCLASSIFIER Non-Bayesian single point model
    % based classifier running on peak parameters extracted from the
    % likelihood function
    properties
        sigmaA; % standard deviation of class 'A'
        sigmaB; % standard deviation of class 'B'
        stimCenter; % center of class distributions
        priorA = 0.5; % prior for class 'A'
        lapseRate = 0; % lapse rate
        peakExtractor; % reference to the function that takes in likelihood and returns its center
    end
    
    methods
        
        function obj = NB2LikelihoodClassifier(sigmaA, sigmaB, stimCenter)
            % Constructor Initializes with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions
            obj.sigmaA = sigmaA;
            obj.sigmaB = sigmaB;
            obj.stimCenter = stimCenter;
            obj.peakExtractor = @ClassifierModel.fitGaussToLikelihood; % defaults to center extracted from Gaussian fit
        end
        
        function setPeakExtractor(self, func)
            self.peakExtractor = func;
        end
        
        function classResp = classifyLikelihood(self, decodeOri, likelihood)
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
        
        function pA = pRespAHelper(self, s_hat)
            pALapse = 0.5  * self.lapseRate * ones(size(s_hat));
            
            k1 = 1 / 2 * log((self.sigmaB.^2) ./ (self.sigmaA.^2)) + ...
                log(self.priorA ./ (1 - self.priorA));
            k2 = (self.sigmaB.^2 - self.sigmaA.^2) ./ (2 * (self.sigmaA.^2) .* (self.sigmaB.^2));
            
            if(k1 / k2 < 0)
                pA = pALapse;
                return;
            end
            k = sqrt(k1 / k2); % calculate the decision boundary
            expRespA = (abs(s_hat - self.stimCenter) < k); % trials for which response 'A' is expected
            pA = expRespA .* (1 - self.lapseRate) + pALapse;
        end
        
        function [muLL, logLList] = getLogLikelihoodHelper(self, s_hat, classResp)
            % GETLOGLIKELIHOOD Returns the log-liklihood of generating
            % response vector classResp given the likilihood functions over
            % orientation for each trial.
            s_hat = s_hat(:);
            classResp = classResp(:);
            
            respA = strcmp(classResp, 'A'); % trials for which subject responded 'A'
            respB = strcmp(classResp, 'B'); % trials for which subject responded 'B'
            
            pRespA = self.pRespAHelper(s_hat);
            
            pRespTotal = respA .* pRespA + respB .* (1-pRespA);
           
            logLList = log(pRespTotal);
            muLL = mean(logLList);
        end
        
        
        function pA = pRespA(self, decodeOri, likelihood)
            % PRESPA Returns the probability of the classifier responding 
            % class 'A' given the likelihood function over orientation
            s_hat = self.peakExtractor(decodeOri, likelihood); % extract center and width of the likelihood function
            pA = self.pRespAHelper(s_hat);
        end
        
        function [muLL, logLList] = getLogLikelihood(self, decodeOri, likelihood, classResp)
            % GETLOGLIKELIHOOD Returns the log-liklihood of generating
            % response vector classResp given the likilihood functions over
            % orientation for each trial.
            s_hat = self.peakExtractor(decodeOri, likelihood); % extract center and width of the likelihood function
            [muLL, logLList] = self.getLogLikelihoodHelper(s_hat, classResp);
        end
        
        function muLL = train(self, decodeOri, likelihood, classResp, nReps)
            fprintf('Training NB2 Classifier');
            % TRAIN Trains the likelihood classifier to learn the model
            if nargin < 5
                nReps = 10;
            end
            s_hat = self.peakExtractor(decodeOri, likelihood);
            function cost = cf(param)
                self.setModelParameters(param); % update parameter values
                cost = -self.getLogLikelihoodHelper(s_hat, classResp);
            end
            
            paramSet = self.getModelParameters;
            minX = paramSet.values;
            minCost = cf(minX);
            options=optimset('Display','off','Algorithm','active-set','MaxFunEvals',1000);
            
            for i = 1 : nReps
                fprintf('.');
                x0(1) = rand;
                x0(2) = rand;
                [x, cost] = fmincon(@cf, x0, [], [], [], [], paramSet.lowerBounds, paramSet.upperBounds,[],options);
                if (cost < minCost)
                    minCost = cost;
                    minX = x;
                end
            end
            self.setModelParameters(minX);
            muLL = -minCost;
            fprintf('\n');
        end
        
         
        function setModelParameters(self, paramValues)
            % SETMODELPARAMETERS Immeidately sets the model parameters to the
            % specified values.
            %   WARNING: You have to know the correct number and condition of
            %   the parameters before setting them.
            self.priorA = paramValues(1);
            self.lapseRate = paramValues(2);
        end
        
        function paramSet = getModelParameters(self)
            % GETMODELPARAMETERS Returns a structure containing information about
            % model parameters needed for optimization/training
            paramSet = [];
            paramSet.numParameters = 2;
            paramSet.values = [self.priorA, self.lapseRate];
            paramSet.lowerBounds = [0, 0];
            paramSet.upperBounds = [1, 1];
        end
    end
end