classdef FixedCriterionClassifier < handle
    % BPLCLASSIFIER Full Bayesian Classifier with free prior
    % and lapse rate (BP-L model)
    %   This class represents Bayesian behavioral orientation stimulus
    %   classifier with free prior over stimulus category and lapse rate.
    properties
        priorA = 0.5; % prior over category 'A'
        sigmaA; % standard devation of category 'A'
        sigmaB; % standard deviation of category 'B'
        modelName; % name of the model
        stimCenter = 0; % center of stimulus distribution for both category
       
        lapseRate = 0; % lapse rate for stimulus category classification
        a = 1; % parameters for logistic fit to sigma = exp(beta0 + beta1 * contrast)/(1 + exp(beta0 + beta1 * contrast)
        beta = 1;
        gamma = 0;
        k = 1;
        
        params = {'priorA', 'lapseRate', 'a', 'beta', 'gamma', 'k'};
        fixedParams = false(1, 6);
        p_lb = [0.25, 0, 0, 0, 0, 0,]; % lower bound for parameters
        p_ub = [0.75, 0.5, 50, 8, 30, 200]; % upper bound for parameters
        precompLogLRatio = false;
    end
    
   
    methods
        
        
        
        function obj = FixedCriterionClassifier(sigmaA, sigmaB, stimCenter, modelName)
            % BAYESIANBEHAVIORALCLASSIFIER Constructer that takes in sigmaA,
            % sigmaB and stimCenter describing the experiment
            if nargin < 4
                modelName = 'Fixed criterion';
            end
            if nargin < 1
                sigmaA = 3;
                sigmaB = 15;
                stimCenter = 270;
            end
            
            obj.sigmaA = sigmaA;
            obj.sigmaB = sigmaB;
            obj.stimCenter = stimCenter;
            obj.modelName = modelName;
        end
        
        function sigma = mapContrast(self, contrast)
            sigma = (contrast * self.a).^-self.beta + self.gamma;
            sigma(isinf(sigma)) = 100; % deal with contrast of 0...wtf
            %sigma = self.sigma * exp(self.beta0 + self.beta1 * contrast)./(1 + exp(self.beta0 + self.beta1 * contrast)) + self.base;
        end
        
        
        function pA = pRespA(self, dataStruct)
            % PRESPAGIVENS Returns the probability of responding class 'A'
            % given the stimulus
            
            stimulus = dataStruct.orientation;
            contrast = dataStruct.contrast;
            contrast = contrast(:);
            s_hat = stimulus(:) - self.stimCenter;
            sigma_actual = self.mapContrast(contrast);
%             sigma = self.sigma;
%             k1 = 1/2*log((sigma.^2 + self.sigmaB.^2)./(sigma.^2 + self.sigmaA.^2)) + log(self.priorA./(1-self.priorA));
%             k2 = 1/2*(self.sigmaB.^2 - self.sigmaA.^2) ./ ((sigma.^2 + self.sigmaA.^2) .* (sigma.^2 + self.sigmaB.^2));
%             k = sqrt(k1./k2);
%             
%             unreal_k = ~arrayfun(@isreal, k);
%             k(unreal_k) = 0; % give 0 to pass by erf function
            k = self.k;
            LCA = ((1/2)*(erf((s_hat+k)./sigma_actual./sqrt(2)) - erf((s_hat-k)./sigma_actual./sqrt(2)))); % p(C='A'|s)
            %LCA(unreal_k) = 0;
            pA = LCA * (1-self.lapseRate) + self.lapseRate * 0.5;

        end
        
        function [muLL, logLList] = getLogLikelihood(self, dataStruct)
            classResp = dataStruct.selected_class;
            classResp = classResp(:);
            respA = strcmp(classResp, 'A');
            respB = ~respA;
            
            pRespA = self.pRespA(dataStruct);
            pRespA = pRespA(:);
            pRespTotal = respA .* pRespA + respB .* (1-pRespA);
            logLList = log(pRespTotal);
            muLL = mean(logLList);
        end
        
        function response = classify(self, dataStruct)
            % CLASSIFY Runs simulated classification of stimulus according to
            % the current model parameters
            pA = self.pRespA(dataStruct);
            stimulus = dataStruct.orientation;
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
            
            
            function cost = cf(param)
            % cost function for optimization - defined as the negative log
            % likelihood.
                
                self.setModelParameters(param); % update parameter values
                cost = -self.getLogLikelihood(trainSet);
                if(isnan(cost) || ~isreal(cost))
                    cost = Inf;
                end
            end
            
            paramSet = self.getModelParameters;
            minX = paramSet.values;
            minCost = min(cf(minX), Inf); % this step necessary in case cf evalutes to NaN
            
            options=optimset('Display','off','Algorithm','interior-point');%'MaxFunEvals',500,'FunValCheck','on');
            
            x0set = self.getInitialGuess(nReps);
            
            for i = 1 : nReps
                fprintf('.');
                x0 = x0set(:, i);
                
                [x, cost] = fmincon(@cf, x0, [], [], [], [], paramSet.lowerBounds, paramSet.upperBounds, [], options);
                %[x, cost] = ga(@cf, length(x0), [], [], [], [], paramSet.lowerBounds, paramSet.upperBounds);
                if (cost < minCost)
                    minCost = cost;
                    minX = x;
                end
            end
            self.setModelParameters(minX);
            muLL = -minCost;
            fprintf('%2.3f\n',muLL);
        end
        
        function fixParameterByName(self, field)
            pos = find(strcmp(field, self.params));
            if ~isempty(pos)
                self.fixedParams(pos) = true;
            end
        end
        
        function releaseParameterByName(self, field)
            pos = find(strcmp(field, self.params));
            if ~isempty(pos)
                self.fixedParams(pos) = false;
            end
        end
            
        function setParameterFixMap(self, fmap)
            assert(length(fmap) == length(self.params), 'Parameter fix map size must match the number of parameters!');
            self.fixedParams = logical(fmap);
        end
        
        function setModelParameters(self, paramValues)
            % SETMODELPARAMETERS Immeidately sets the model parameters to the
            % specified values.
            %   WARNING: You have to know the correct number and condition of
            %   the parameters before setting them.
            p_set = self.params(~self.fixedParams);
            for i = 1:length(p_set)
                self.(p_set{i}) = paramValues(i);
            end
        end
        
        function paramSet = getModelParameters(self)
            % GETMODELPARAMETERS Returns a structure containing information about
            % model parameters needed for optimization/training
            paramSet = [];
            p_set = self.params(~self.fixedParams);
            paramSet.numParameters = length(p_set);
            paramSet.values = cellfun(@(x) self.(x), p_set);
            paramSet.lowerBounds = self.p_lb(~self.fixedParams);
            paramSet.upperBounds = self.p_ub(~self.fixedParams);
        end
        
        function x0 = getInitialGuess(self, nreps)
            paramSet = self.getModelParameters();
            np = paramSet.numParameters;
            r = rand(np, nreps);
            lb = paramSet.lowerBounds(:);
            ub = paramSet.upperBounds(:);
            ub(isinf(ub))=100;
            lb(isinf(lb))=-100;

            x0 = bsxfun(@plus, bsxfun(@times,(ub-lb),r), lb);
        end
        

        function configSet = getModelConfigs(self)
            % Returns a structure with all configurable component for the
            % model. This includes ALL (fixed and non-fixed) parameters,
            % fix map, bounds, and model name
            
            configSet = [];
            configSet.sigmaA = self.sigmaA;
            configSet.sigmaB = self.sigmaB;
            configSet.stimCenter = self.stimCenter;
            configSet.paramNames = self.params;
            configSet.paramValues = cellfun(@(x) self.(x), self.params);
            configSet.fixedParams = self.fixedParams;
            configSet.modelName = self.modelName;
            configSet.lb = self.p_lb;
            configSet.ub = self.p_ub;
        end
        
        function setModelConfigs(self, configSet)
            % Load in the state of the model from a config set
            self.sigmaA = configSet.sigmaA;
            self.sigmaB = configSet.sigmaB;
            self.stimCenter = configSet.stimCenter;
            paramNames = configSet.paramNames;
            paramValues = configSet.paramValues;
            for i = 1:length(paramNames)
                self.(paramNames{i}) = paramValues(i);
            end
            self.fixedParams = configSet.fixedParams;
            self.modelName = configSet.modelName;
            self.p_lb = configSet.lb;
            self.p_ub = configSet.ub;
        end
        
        
        
        
        
        
    end
 
end

