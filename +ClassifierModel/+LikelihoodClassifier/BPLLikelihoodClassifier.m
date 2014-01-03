classdef BPLLikelihoodClassifier < handle
    % BPLLIKELIHOODCLASSIFIER BPL (Bayesian, free-Prior with Lapse rate) model
    % based classifier running on peak and width parameters extracted from the
    % likelihood function
    properties
        sigmaA; % standard deviation of class 'A'
        sigmaB; % standard deviation of class 'B'
        stimCenter; % center of class distributions
        priorA = 0.5; % prior for class 'A'
        lapseRate = 0; % lapse rate
        cwExtractor; % reference to function that takes in likelihood and returns its center and width
    end
    
    methods
        
        function obj = BPLLikelihoodClassifier(sigmaA, sigmaB, stimCenter)
            % Constructor Initializes with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions
            obj.sigmaA = sigmaA;
            obj.sigmaB = sigmaB;
            obj.stimCenter = stimCenter;
            obj.cwExtractor = @ClassifierModel.fitGaussToLikelihood;
        end
        
        function setCenterWidthExtractor(self, func)
            self.cwExtractor = func;
        end
        
        function classResp = classifyLikelihood(self, decodeOri, likelihood)
            pA = self.pRespA(decodeOri, likelihood); % probability of responding A
            nTrials = size(likelihood, 2);
            randRoll = rand(nTrials, 1);
            classResp = cell(nTrials, 1);
            pos = (pA >= randRoll);
            [classResp{pos}] = deal('A');
            [classResp{~pos}] = deal('B');
        end
        
        function pA = pRespAHelper(self, s_hat, sigma)
            k1 = 1 / 2 * log((sigma.^2 + self.sigmaB.^2) ./ (sigma.^2 + self.sigmaA.^2)) + ...
                log(self.priorA ./ (1 - self.priorA));
            k2 = (self.sigmaB.^2 - self.sigmaA.^2) ./ (2 * (sigma.^2 + self.sigmaA.^2) .* (sigma.^2 + self.sigmaB.^2));
            k = sqrt(k1 ./ k2); % calculate the decision boundary
            if(~isreal(k))
                expRespA = zeros(size(s_hat));
            else
                expRespA = (abs(s_hat - self.stimCenter) < k); % trials for which response 'A' is expected
            end
            pA = expRespA .* (1 - self.lapseRate) + self.lapseRate * 0.5;
        end
        
        function [muLL, logLList] = getLogLikelihoodHelper(self, s_hat, sigma, classResp)
            % GETLOGLIKELIHOOD Returns the log-liklihood of generating
            % response vector classResp given the likilihood functions over
            % orientation for each trial.
            s_hat = s_hat(:);
            sigma = sigma(:);
            classResp = classResp(:);
            
            respA = strcmp(classResp, 'A'); % trials for which subject responded 'A'
            respB = strcmp(classResp, 'B'); % trials for which subject responded 'B'
            
            pRespA = self.pRespAHelper(s_hat, sigma);
            
            pRespTotal = respA .* pRespA + respB .* (1-pRespA);
           
            logLList = log(pRespTotal);
            muLL = mean(logLList);
        end
        
        
        function pA = pRespA(self, decodeOri, likelihood)
            % PRESPA Returns the probability of the classifier responding 
            % class 'A' given the likelihood function over orientation
            [s_hat, sigma] = self.cwExtractor(decodeOri, likelihood); % extract center and width of the likelihood function
            pA = self.pRespAHelper(s_hat, sigma);
        end
        
        function [muLL, logLList] = getLogLikelihood(self, decodeOri, likelihood, classResp)
            % GETLOGLIKELIHOOD Returns the log-liklihood of generating
            % response vector classResp given the likilihood functions over
            % orientation for each trial.
            [s_hat, sigma] = self.cwExtractor(decodeOri, likelihood); % extract center and width of the likelihood function
            [muLL, logLList] = self.getLogLikelihoodHelper(s_hat, sigma, classResp);
        end
        
        function muLL = train(self, decodeOri, likelihood, classResp, nReps)
            % TRAIN Trains the likelihood classifier to learn the model
            if nargin < 5
                nReps = 10;
            end
            [s_hat, sigma] = self.cwExtractor(decodeOri, likelihood);
            function cost = cf(param)
                self.setModelParameters(param); % update parameter values
                cost = -self.getLogLikelihoodHelper(s_hat, sigma, classResp);
            end
            
            paramSet = self.getModelParameters;
            minX = paramSet.values;
            minCost = cf(minX);
            
            for i = 1 : nReps
                x0(1) = rand;
                x0(2) = rand;
                [x, cost] = fmincon(@cf, x0, [], [], [], [], paramSet.lowerBounds, paramSet.upperBounds);
                if (cost < minCost)
                    minCost = cost;
                    minX = x;
                end
            end
            self.setModelParameters(minX);
            muLL = -minCost;
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