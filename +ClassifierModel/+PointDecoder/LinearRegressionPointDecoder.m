classdef LinearRegressionPointDecoder < handle
    % POISSONNOISEPPCodec Takes the base DPCEncoder and "wraps" it with
    % Poisson noise based coder-decoder (codec).
    properties
        weights;
        NUM_UNITS;
    end
    
    methods
        function obj = LinearRegressionPointDecoder(NUM_UNITS)
            % Constructer for PoissonNoisePPCWrapper that takes base
            % DPC encoder
            if nargin < 1
                NUM_UNITS = 96;
            end
            
            obj.NUM_UNITS = NUM_UNITS;
            obj.weights(NUM_UNITS+1) = 0;
        end
        
        function shat = decode(self, dataSet)
            % Decode Takes in spikes counds and decode stimulus
            counts = [dataSet.counts];
            counts(end+1, :) = 1; % extend for bias
            shat = self.weights' * counts;
        end
        
        function mse = train(self, dataSet)
            counts = [dataSet.counts];
            counts(end+1, :) = 1; % extend for bias
            orientation = [dataSet.orientation];
            self.weights = counts' \ orientation';
            mse = mean((orientation - self.weights' * counts).^2);
        end
        
        function configSet = getModelConfigs(self)
            % Returns a structure with all configurable component for the
            % model. This includes ALL (fixed and non-fixed) parameters,
            % fix map, bounds, and model name
            
            configSet = [];
            configSet.weights = self.weights;
            configSet.NUM_UNITS = self.NUM_UNITS;
        end
        
        function setModelConfigs(self, configSet)
            self.weights = configSet.weights;
            self.NUM_UNITS = configSet.NUM_UNITS;
        end
    end
end