%{
# all trained likelihood classifiers
-> cd_lc.LCModels
-> cd_dlset.DLSet
-> cd_dlset.CVSetMember
-----
lc_trained_config   : longblob       # structure for configuring the model
lc_train_mu_logl    : double         # mean log likelihood
lc_train_logl       : longblob       # logl value for all trials
lc_trainset_size : int               # size of the trainset
%}

classdef TrainedLC < dj.Computed

	properties
		popRel = cd_lc.LCModels * cd_dlset.DLSet * cd_dlset.CVSetMember & 'lc_id in (32, 38)';
	end

	methods(Access=protected)

		function makeTuples(self, key)
            
            tuple = key;
%             lc_info = fetch(cd_lc.LCModels & key ,'*');
%             tuple.lc_class = lc_info.lc_class;
%             tuple.lc_label = lc_info.lc_label;
%             
            % if previously trained model exist, start with that
            if count(cd_dlset.PrevFitLC & key) == 1
                fprintf('Loading an existing model as baseline...\n');
                lc_model = getLC(cd_dlset.PrevFitLC & key);
            else
                lc_model = getLC(cd_lc.LCModels & key);
            end

            [muLL, logl] = self.train(lc_model, key, 30, 2);
            tuple.lc_trainset_size = length(logl);
            tuple.lc_train_mu_logl = muLL;
            tuple.lc_train_logl = logl;
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
        
         function dataSet=getSimulatedDataSet(self, key, seed, dataSet)
            
            % get dataset
            key = 0;
            if nargin < 4
                dataSet = getDataSet(cd_dlset.DLSet & key);
            end
            model = getLC(self & key);
            if nargin >= 3
                rng(seed, 'twister');
            end
            resp = model.classifyLikelihood(dataSet);
            dataSet.selected_class = resp';
            dataSet.correct_response=strcmp(dataSet.selected_class, dataSet.stimulus_class);
            isLeft = strcmp(dataSet.correct_direction, 'Left');
            choseLeft = dataSet.correct_response == isLeft; % using notXOR trick to flip boolean if correct_response is false
            [dataSet.selected_direction{choseLeft}] = deal('Left');
            [dataSet.selected_direction{~choseLeft}] = deal('Right'); 
        end
        
        function [dataset, decoder, model]=getAll(self)
            [dataset, decoder] = getDataSet(self);
            model = getLC(self);
        end
        
        function [dataSet, decoder] = getDataSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            
            [dataSet, decoder] = getDataSet(cd_dlset.DLSet & key);
            train_indices = fetch1(cd_dlset.CVSetMember & key, 'train_indices');
            dataSet = selectData(dataSet, train_indices, {'decoder', 'goodUnits', 'decodeOri', 'key'});
        end

        
        function [muLL, logl] = train(self, lc_model, key, n, m)
            if nargin < 5
                m = 0;
            end
            % TODO: combine with getDataSet
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
