%{
class_discrimination.TrainedLikelihoodClassifiers (computed) # all trained likelihood classifiers
->class_discrimination.TrainedDecoder
->class_discrimination.LikelihoodClassifierModels
->class_discrimination.LCTrainSetPairs
-----
lc_class    : varchar(255)   # class name for the likelihood classifier
lc_label='' : varchar(255)   # descriptor for the model
lc_config   : longblob       # structure for configuring the model
mu_logl   : double          # mean log likelihood 
%}

classdef TrainedLikelihoodClassifiers < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.TrainedDecoder * class_discrimination.LikelihoodClassifierModels * class_discrimination.LCTrainSetPairs;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            lc_info = fetch(class_discrimination.LikelihoodClassifierModels & key ,'*');
            tuple.lc_class = lc_info.lc_class;
            tuple.lc_label = lc_info.lc_label;
            
            
            lc_model = getLC(class_discrimination.LikelihoodClassifierModels & key);
            
            muLL = self.train(lc_model, key, 50);
            
            tuple.mu_logl = muLL;
            tuple.lc_config = lc_model.getModelConfigs();
			self.insert(tuple)
		end
    end
    
    methods
        function model=getLC(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.lc_class);
            model.setModelConfigs(info.lc_config);
        end
        
        function muLL = train(self, lc_model, key, n)
            decoder = getDecoder(class_discrimination.TrainedDecoder & key);
            dataSet = fetchDataSet(class_discrimination.LCTrainSets & key);
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            dataSet.decodeOri = decodeOri;
            dataSet.likelihood = L;
            muLL = lc_model.train(dataSet, n);
        end
        
        function retrain(self, keys)
            if nargin < 2
                keys = [];
            end
            keys = fetch(self & keys);
            for i = 1:length(keys)
                key = keys(i);
                lc_model = getLC(self & key);
                mu_logl = self.train(lc_model, key, 50);
                lc_config = lc_model.getModelConfigs();
                update(self & key, 'mu_logl', mu_logl);
                update(self & key, 'lc_config', lc_config);
            end 
        end
    end

end