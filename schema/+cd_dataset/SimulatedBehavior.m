%{
cd_dataset.SimulatedBehavior (computed) # simulated behavioral responses
->cd_dataset.SimulationParams
->cd_lc.TrainedLC
-----
->cd_dataset.DataSets
%}

classdef SimulatedBehavior < dj.Relvar & dj.AutoPopulate
    % Represents dataset generated by using a trained model to simulated the
    % full experiment, including neuroanl responses and outputs
    properties
		popRel = pro(cd_dataset.SimulationParams * cd_lc.TrainedLC) & 'lc_trainset_owner like "cd_dataset.ContrastSession%"' & 'lc_id = 7'
	end

	
    methods
        function self = SimulatedBehavior(varargin)
            self.restrict(varargin{:});
        end
        
        function dataset = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            tuple = fetch(self);
            [dataset, decoder, model] = getAll(cd_lc.TrainedLC & self);
            
            rng(tuple.simulation_seed, 'twister');
            resp=model.classifyLikelihood(dataset);
            dataset.selected_class = resp';
            dataset.correct_response=strcmp(dataset.selected_class, dataset.stimulus_class);
            isLeft = strcmp(dataset.correct_direction, 'Left');
            choseLeft = dataset.correct_response == isLeft; % using notXOR trick to flip boolean if correct_response is false
            [dataset.selected_direction{choseLeft}] = deal('Left');
            [dataset.selected_direction{~choseLeft}] = deal('Right');
        end
    end
    
	methods(Access=protected)
        
		function makeTuples(self, key)
            tuple = key;
            model_label = fetch1(cd_lc.LCModels & key, 'lc_label');
            tuple = registerDataSet(cd_dataset.DataSets, self, tuple, ...
                ['Simulated behavior for: ',  model_label]);
            insert(self, tuple);
		end
    end

end