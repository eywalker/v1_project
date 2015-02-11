classdef OptimalWidth2 < ClassifierModel.LikelihoodClassifier.PSLLC
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
        modelName = '';
        
        params = {'priorA', 'lapseRate', 'alpha', 'sigma'}
        fixedParams = false(1, 4);
        p_lb = [0, 0, 0, 0];
        p_ub = [1, 1, Inf, Inf];
    end
    
    
    
    
    methods
        function obj = OptimalWidth2(sigmaA, sigmaB, stimCenter, modelName, pointExtractor)
            % CONSTRUCTOR Initializes the object with experiment settings about standard
            % deviation (sigmaA and sigmaB) and center (stimCenter) of two
            % distributions.
            if nargin < 4
                modelName = 'OptimizedWidthWithPeak';
            end
            if nargin < 5
                pointExtractor = @ClassifierModel.fitGaussToLikelihood;
            end
            obj = obj@ClassifierModel.LikelihoodClassifier.PSLLC(sigmaA, sigmaB, stimCenter, modelName);
            obj.pointExtractor = pointExtractor;
        end
        
        
        function muLL = train(self, trainSet, nReps)
            fprintf('Training %s', self.modelName);
            % TRAIN Trains the likelihood classifier to learn the model
            if nargin < 3
                nReps = 10; % defaults to 10 repetitions of training
            end
            
            % CANNOT precompute the log-likelihood ratio
            
            function cost = cf(param)
                self.setModelParameters(param); % update parameter values
                logLRatio = self.getLogLRatio(trainSet);
                cost = -self.getLogLikelihoodHelper(logLRatio, trainSet.classResp);
                if(isnan(cost) || ~isreal(cost))
                    cost = Inf;
                end
            end
            
            paramSet = self.getModelParameters;
            minX = paramSet.values;
            minCost = min(cf(minX), Inf);
            options=optimset('Display','off','Algorithm','interior-point');%'MaxFunEvals',500,'FunValCheck','on');
            
            x0set = self.getInitialGuess(nReps);
            
            for i = 1 : nReps
                fprintf('.');
                x0 = x0set(:, i);
                
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
        
    end
    
    methods (Access = protected)
        function logLRatio = getLogLRatio(self, dataStruct)
            decodeOri = dataStruct.decodeOri(:);
            likelihood = dataStruct.likelihood;
            s_hat = self.pointExtractor(decodeOri, likelihood); % extract center of the likelihood function
            logPrA = -1/2 * log(2*pi) - 1 / 2 * log(self.sigma.^2 + self.sigmaA^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (self.sigma.^2 + self.sigmaA^2);
            logPrB = -1/2 * log(2*pi) - 1 / 2 * log(self.sigma.^2 + self.sigmaB^2) - (s_hat-self.stimCenter).^2 ./ 2 ./ (self.sigma.^2 + self.sigmaB^2);
            logLRatio = logPrA - logPrB;
        end
    end
end