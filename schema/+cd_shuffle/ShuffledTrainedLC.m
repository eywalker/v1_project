%{
cd_shuffle.ShuffledTrainedLC (computed) # all trained likelihood classifiers
->cd_decoder.TrainedDecoder
->cd_lc.LCModels
->cd_lc.LCTrainSetPairs
->cd_shuffle.ShuffleParam
-----
lc_class    : varchar(255)   # class name for the likelihood classifier
lc_label='' : varchar(255)   # descriptor for the model
lc_trained_config   : longblob       # structure for configuring the model
lc_train_mu_logl   : double          # mean log likelihood
lc_trainset_size : int               # size of the trainset
%}

classdef ShuffledTrainedLC < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_decoder.TrainedDecoder * cd_lc.LCModels * cd_lc.LCTrainSetPairs * cd_shuffle.ShuffleParam;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            
            tuple = key;
            lc_info = fetch(cd_lc.LCModels & key ,'*');
            tuple.lc_class = lc_info.lc_class;
            tuple.lc_label = lc_info.lc_label;
            
            % if previously trained model exist, start with that
            if count(cd_shuffle.ShuffledPrevFitLC & key) == 1
                fprintf('Loading an existing model as baseline...\n');
                lc_model = getLC(cd_shuffle.ShuffledPrevFitLC & key);
                reps = 3;
            else
                lc_model = getLC(cd_lc.LCModels & key);
                reps = 5;
            end
            [muLL, logl] = self.train(lc_model, key, reps);
            tuple.lc_trainset_size = length(logl);
            tuple.lc_train_mu_logl = muLL;
            tuple.lc_trained_config = lc_model.getModelConfigs();
			self.insert(tuple)
		end
    end
    
    methods
        function model=getLC(self)
            assert(count(self)==1, 'You can only retrieve one model at a time');
            info = fetch(self, '*');
            model = eval(info.lc_class);
            model.setModelConfigs(info.lc_trained_config);
        end
        
        function [dataset, decoder, model]=getAll(self)
            [dataset, decoder] = getDataSet(self);
            model = getLC(self);
        end
            
        
        function [muLL, logl] = train(self, lc_model, key, n)
            % TODO: combine with getDataSet
            dataSet = self.getDataSet(key);
            lc_model.train(dataSet, n);
            [muLL, logl] = lc_model.getLogLikelihood(dataSet);
        end
        
        function [dataSet, decoder] = getDataSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            
            decoder = getDecoder(cd_decoder.TrainedDecoder & key);
            dataSet = fetchDataSet(cd_lc.LCTrainSets & key);
            dataSet = prepareDataSet(dataSet, decoder, key);
            
            % shuffle the dataset
            dataSet = shuffleDataSet(cd_shuffle.ShuffleParam & key, dataSet);
        end
        
        function retrain(self, keys, N)
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
                lc_train_mu_logl = self.train(lc_model, key, N);
                lc_trained_config = lc_model.getModelConfigs();
                update(self & key, 'lc_train_mu_logl', lc_train_mu_logl);
                update(self & key, 'lc_trained_config', lc_trained_config);
            end 
        end
    end

end
