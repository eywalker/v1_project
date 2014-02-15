classdef PSLLC < handle
% Posterior-Sampling with Lapse rate based Likelihood Classifier
% 
% Represents a likelihood classifier model, where the input likelihood
% over stimulus orientation is processed to formulate likelihood ratio
% over two classes, and then decision is made by sampling from the
% powered ratio with lapse rate. In overall scheme of things, this
% corresponds to the s_hat extraction as well as C_hat extraction step.
% 
% Note that this class is an abstract class and requires subclass
% (specific model implementations) to provide with a method of actually
% calculating the log likelihood ratio over two classes given the input
% likelihood distribution over the stimulus orientation.
%
% Furthermore, when providing a specific implementation, be sure to
% assign meaningful name to the modelName property to ease later
% analysis and usage.
% 
% Author: Edgar Y. Walker
% e-mail: edgar.walker@gmail.com
% Last modified: Feb 14, 2014
%
    properties
        sigmaA; % standard deviation of class 'A'
        sigmaB; % standard deviation of class 'B'
        stimCenter; % center of class distributions
        priorA = 0.5; % prior for class 'A'
        alpha = 1; % posterior ratio power
        lapseRate = 0;
        modelName = ''; 
    end
    
    methods (Abstract, Access = protected)
        
        getLogLRatio(obj, dataStruct);
        % As explained in the class documentation, this method has to be
        % implemented by subclass. It is at this step where you can set the
        % rest of the behavior to depend on only certain aspect of the
        % decoded likelihood distribution over stimulus orientation (such
        % as peak-only or peak + width)
        
    end
    
    
    methods
        function obj = PSLLC(sigmaA, sigmaB, stimCenter, modelName)
        % constructor Initializes the object with experiment settings
        % about standard deviation (sigmaA and sigmaB) and the center
        % of the two stimulus distributions
            if nargin < 4
                modelName = 'PSLLC';
            end
            obj.sigmaA = sigmaA;
            obj.sigmaB = sigmaB;
            obj.stimCenter = stimCenter;
            obj.modelName = modelName;
        end
        
        function pA = pRespA(self, dataStruct)
        % pRespA Returns the probability of the classifier responding 
        % class 'A' given the likelihood function over the orientation
        % decodeOri. Likelhood must have the dimension of D x T where D
        % is the size of decodeOri and T is number of trials
            logLRatio = self.getLogLRatio(dataStruct);
            pA = self.pRespAHelper(logLRatio);
        end
        
        function classResp = classifyLikelihood(self, dataStruct)
        % classifyLikelihood Classifies the given likelihood
        % distribution over decodeOri as arising from either class A or
        % class B. Note that this is a stochastic classifier and thus
        % its response varies from run to run.
            pA = self.pRespA(dataStruct);
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
        
        function [muLL, logLList] = getLogLikelihood(self, dataStruct)
        % getLogLikelihood Returns the log-liklihood of generating
        % response vector classResp given the likilihood functions over
        % orientation for each trial.
            logLRatio = self.getLogLRatio(dataStruct);
            [muLL, logLList] = self.getLogLikelihoodHelper(logLRatio, dataStruct.classResp);
        end
        
        function muLL = train(self, trainSet, nReps)%decodeOri, likelihood, classResp, nReps)
        % train Trains the model using the training dataset.
        % 
        % Note that this train method will only train three parameters
        % of priorA, alpha and lapseRate. If your specific model
        % requires additional parameters whose value has to be
        % optimized based on the dataset, then the model specific train
        % method must be prepared and utilized.
        %
            fprintf('Training %s', self.modelName);
            % TRAIN Trains the likelihood classifier to learn the model
            if nargin < 3
                nReps = 10; % defaults to 10 repetitions of training
            end
            
            logLRatio = self.getLogLRatio(trainSet); % precompute the log-likelihood ratio
            
            function cost = cf(param)
            % cost function for optimization - defined as the negative log
            % likelihood.
                self.setModelParameters(param); % update parameter values
                cost = -self.getLogLikelihoodHelper(logLRatio, trainSet.classResp);
                if(isnan(cost) || ~isreal(cost))
                    cost = Inf;
                end
            end
            
            paramSet = self.getModelParameters;
            minX = paramSet.values;
            minCost = min(cf(minX), Inf); % this step necessary in case cf evalutes to NaN
            
            options=optimset('Display','off','Algorithm','interior-point');%'MaxFunEvals',500,'FunValCheck','on');
            
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
            muLL = -minCost;
            fprintf('%2.3f\n',muLL);
        end
        
         
        function setModelParameters(self, paramValues)
            % setModelParameters Immediately sets the model parameters to
            % the specified values.
            %
            %   WARNING: You have to know the correct number and condition
            %   of the parameters before setting them. When using this
            %   method to assign parameter values, no check is performed!
            %   the parameters before setting them.
            self.priorA = paramValues(1);
            self.alpha = paramValues(2);
            self.lapseRate = paramValues(3);
        end
        
        function paramSet = getModelParameters(self)
            % getModelParameters Returns a structure containing information
            % about model parameters needed for optimization/training.
            %
            % Returned structure contains following fields (and any
            % additional fields as deemed necessary by implementer):
            %     numParameters - total number of parameters
            %     values - current values of parameters
            %     lowerBounds - lower bound values of parameters
            %     upperBounds - upper bound values of parameters
            %
            % NOTE: The parameter identity is established by the order in
            % the list. 
            paramSet.numParameters = 3;
            paramSet.values = [self.priorA, self.alpha, self.lapseRate];
            paramSet.lowerBounds = [0, 0, 0];
            paramSet.upperBounds = [1, Inf, 1];
        end
    end
    
    %% Helper functions
    methods (Access = protected)
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