classdef ParameterizedModel < handle
    properties
        params = {};
        fixedParams = false(1, 5);
        p_lb = [0.25, 0, 0, 0, 0, ]; % lower bound for parameters
        p_ub = [0.75, 0.5, 50, 8, 30]; % upper bound for parameters
        precompLogLRatio = false;
    end
    
    methods
        function fixParameterByName(self, fields)
            if ischar(fields)
                fields = {fields};
            end
            for i = 1:length(fields)
                pos = find(strcmp(fields{i}, self.params));
                if ~isempty(pos)
                    self.fixedParams(pos) = true;
                end
            end
        end
        
        function releaseParameterByName(self, fields)
            if ischar(fields)
                fields = {fields};
            end
            for i = 1:length(fields)
                pos = find(strcmp(fields{i}, self.params));
                if ~isempty(pos)
                    self.fixedParams(pos) = false;
                end
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