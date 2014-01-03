classdef DiscreteMapEncoder < handle
    % DiscreteMapEncoder Given completely discretized stimulus space
    % (discretized orientation and contrast), it takes mean firing response
    % of each unit and store it as mapping that will serve as the tuning
    % functions. CAUTION!- currently it does not support obtaining firing
    % rate for stimulus that was not used to train the encoder.
    properties
        contSet;
        oriSet;
        fmap;
        threshold;
        NUM_UNITS; % number of recording units
    end
    
    methods
        function obj=DiscreteMapEncoder(NUM_UNITS, threshold)
            % Constructer that takes in number of units
            if nargin < 2
                threshold = 5
            end
            obj.NUM_UNITS=NUM_UNITS;
            obj.contSet = [];
            obj.oriSet = [];
            obj.threshold = threshold;
            obj.fmap = zeros(obj.NUM_UNITS,1);
            
        end
        
        function obj = restrict(self, units)
            numUnits = sum(units);
            obj = ClassifierModel.CoderDecoder.DiscreteMapEncoder(numUnits, self.threshold);
            obj.contSet = self.contSet;
            obj.oriSet = self.oriSet;
            obj.threshold = self.threshold;
            obj.fmap = self.fmap(units,:,:);
        end
        
        function train(self, stimulus, contrast, spikeCounts)
            self.contSet = sort(unique(contrast));
            discS = sort(unique(stimulus));
            histS = zeros(size(discS));
            for ind = 1:length(discS)
                histS(ind)=sum(stimulus==discS(ind));
            end
            % there must be at least 5 trials for each stimulus
            self.oriSet = discS(histS >=self.threshold);
            
            self.fmap = zeros(self.NUM_UNITS, length(self.oriSet), length(self.contSet));

            for indUnit = 1:self.NUM_UNITS
                for indS = 1:length(self.oriSet)
                    for indCont = 1:length(self.contSet)
                        s_val = self.oriSet(indS);
                        c_val = self.contSet(indCont);
                        self.fmap(indUnit, indS, indCont) = max(mean(spikeCounts(indUnit, (stimulus==s_val & contrast==c_val))), 0.01);
                    end
                end
            end
        end
        
        function spikeCounts = encode(self, orientation, contrast)
            % ENCODE Encode the given stimulus into spike counts
            s_ind = arrayfun(@(x)(find(abs(self.oriSet-x)<1e-5)), orientation);
            c_ind = arrayfun(@(x)(find(abs(self.contSet-x) < 1e-5)),contrast);
            if length(c_ind) ==1
                c_ind = c_ind * ones(size(s_ind));
            end
            
            stimInd = sub2ind([length(self.oriSet), length(self.contSet)],s_ind, c_ind);
            spikeCounts = self.fmap(:,stimInd);
        end
        
%         function plot(self)
%             
%         end
        
        function setModelParameters(self, paramValues)
            % SETPARAMETERS Immeidately sets the model parameters to the
            % specified values.
            %   WARNING: You have to know the correct number and condition of
            %   the parameters before setting them.

        end
        
        function paramSet = getModelParameters(self)
            % GETPARAMETERS Returns a structure containing information about
            % model parameters needed for optimization/training
            paramSet = [];
        end
        
    end
end