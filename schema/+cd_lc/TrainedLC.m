%{
cd_lc.TrainedLC (computed) # all trained likelihood classifiers
->cd_decoder.TrainedDecoder
->cd_lc.LCModels
->cd_lc.LCTrainSetPairs
-----
lc_class    : varchar(255)   # class name for the likelihood classifier
lc_label='' : varchar(255)   # descriptor for the model
lc_trained_config   : longblob       # structure for configuring the model
lc_train_mu_logl   : double          # mean log likelihood
lc_trainset_size : int                  # size of the trainset
%}

classdef TrainedLC < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_decoder.TrainedDecoder * cd_lc.LCModels * cd_lc.LCTrainSetPairs;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            
            tuple = key;
            lc_info = fetch(cd_lc.LCModels & key ,'*');
            tuple.lc_class = lc_info.lc_class;
            tuple.lc_label = lc_info.lc_label;
            
            if count(cd_lc.PrevFitLC & key) == 1
                lc_model = getLC(cd_lc.PrevFitLC & key);
            else
                lc_model = getLC(cd_lc.LCModels & key);
            end
            [muLL, logl] = self.train(lc_model, key, 25);
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
            decoder = getDecoder(cd_decoder.TrainedDecoder & key);
            dataSet = fetchDataSet(cd_lc.LCTrainSets & key);
            dataSet.goodUnits = decoder.unitFilter(:);
            dataSet.toalCounts = sum(dataSet.counts, 1);
            dataSet.goodTotalCounts = dataSet.goodUnits' * dataSet.counts;
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            dataSet.decodeOri = decodeOri;
            dataSet.likelihood = L;
            lc_model.train(dataSet, n);
            [muLL, logl] = lc_model.getLogLikelihood(dataSet);
        end
        
        function [dataSet, decoder] = getDataSet(self)
            decoder = getDecoder(cd_decoder.TrainedDecoder & self);
            dataSet = fetchDataSet(cd_lc.LCTrainSets & self);
            dataSet.goodUnits = decoder.unitFilter(:);
            dataSet.totalCounts = sum(dataSet.counts, 1);
            dataSet.goodTotalCounts = dataSet.goodUnits' * dataSet.counts;
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            dataSet.decodeOri = decodeOri;
            dataSet.likelihood = L;
        end
        
        function retrain(self, keys, N)
            if nargin < 3
                N = 50;
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
