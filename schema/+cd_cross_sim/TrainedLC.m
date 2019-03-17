%{
# all trained likelihood classifiers
-> cd_cross_sim.SimulationSeed
-> cd_lc.LCModels
-> cd_dlset.DLSet
-> cd_dlset.CVSetMember
(source_lc_id, source_shuffle_id, source_dec_id) -> cd_dlset.TrainedLC(lc_id, lc_shuffle_id, decoder_id)
-----
lc_trained_config   : longblob       # structure for configuring the model
lc_train_mu_logl    : double         # mean log likelihood
lc_train_logl       : longblob       # logl value for all trials
lc_trainset_size : int               # size of the trainset
src_train_mu_logl   : double         # mean log likelihood from the generaing model
src_train_logl      : longblob       # logl value for all trials
%}

classdef TrainedLC < dj.Computed

	properties
		popRel = cd_sim.SimulationSeed * cd_lc.LCModels * cd_dlset.DLSet * cd_dlset.CVSetMember ...
            * pro(cd_dlset.TrainedLC, 'lc_id -> source_lc_id', 'decoder_id -> source_dec_id', 'lc_shuffle_id -> source_shuffle_id') ...
            & 'lc_id in (32)' & 'decoder_id in (13, 15)' & 'source_lc_id = 32' & 'source_shuffle_id = 0' & 'source_dec_id = 13';
	end

	methods(Access=protected)

		function makeTuples(self, key)
            
            tuple = key;
            lc_model = getLC(cd_lc.LCModels & key);

            [muLL, logl, dataSet] = self.train(lc_model, key, 30, 2);
            tuple.lc_trainset_size = length(logl);
            tuple.lc_train_mu_logl = muLL;
            tuple.lc_train_logl = logl;
            tuple.src_train_mu_logl = dataSet.src_mu_logl;
            tuple.src_train_logl = dataSet.src_logl;
            tuple.lc_trained_config = lc_model.getModelConfigs();
			self.insert(tuple)
		end
    end
    
    methods
        function model=getLC(self)
            assert(count(self)==1, 'You can only retrieve one model at a time');
            info = fetch(self, '*');
            model = getLC(cd_lc.LCModels & self);
            model.setModelConfigs(info.lc_trained_config);
        end
        
        function [dataset, decoder, model]=getAll(self)
            [dataset, decoder] = getDataSet(self);
            model = getLC(self);
        end
        
        function simDS = simulateResponses(self, model, dataSet)
            simDS = model.simulateDataset(dataSet);
        end
        
        function [dataSet, muLL, logl] = getSimulatedDataSet(self, key)
            srcKey = key;
            srcKey.lc_id = key.source_lc_id;
            srcKey.lc_shuffle_id = key.source_shuffle_id;
            srcKey.decoder_id = key.source_dec_id;
            % get original dataset
            dataSet = getDataSet(cd_dlset.DLSet & srcKey);
            model = getLC(cd_dlset.TrainedLC & srcKey);
            rng(srcKey.sim_seed, 'twister');
            dataSet = model.simulateDataset(dataSet);
            [muLL, logl] = model.getLogLikelihood(dataSet);
        end
        
        function [dataSet, decoder] = getDataSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getDataSet(cd_dlset.DLSet & key);
            [simDataSet, ~, logl] = getSimulatedDataSet(self, key);
            
            % transfer over simulated responses
            dataSet.selected_class = simDataSet.selected_class;
            dataSet.correct_response = simDataSet.correct_response;
            dataSet.selected_direction = simDataSet.selected_direction;
            dataSet.src_logl = logl(:)';
            
            train_indices = fetch1(cd_dlset.CVSetMember & key, 'train_indices');
            dataSet = selectData(dataSet, train_indices, {'decoder', 'goodUnits', 'decodeOri', 'key'});
            dataSet.src_mu_logl = mean(dataSet.src_logl);
        end

        
        function [muLL, logl, dataSet] = train(self, lc_model, key, n, m)
            if nargin < 5
                m = 0;
            end
            dataSet = self.getDataSet(key);
            if n > 0
                lc_model.train(dataSet, n, 'fmincon');
            end
            if m > 0
                lc_model.train(dataSet, m, 'bads');
            end
            [muLL, logl] = lc_model.getLogLikelihood(dataSet);
        end
        
      
        
        function retrain(self, keys, N, M)
            if nargin < 4
                M = 2;
            end
            if nargin < 3
                N = 30;
            end
            if nargin < 2
                keys = [];
            end
            keys = fetch(self & keys);
            for i = 1:length(keys)
                key = keys(i);
                lc_model = getLC(self & key);
                lc_train_mu_logl = self.train(lc_model, key, N, M);
                lc_trained_config = lc_model.getModelConfigs();
                update(self & key, 'lc_train_mu_logl', lc_train_mu_logl);
                update(self & key, 'lc_trained_config', lc_trained_config);
            end 
        end
    end

end
