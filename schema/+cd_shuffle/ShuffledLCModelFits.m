%{
cd_shuffle.ShuffledLCModelFits (computed) # Test set eval on shuffled
-> cd_shuffle.ShuffledTrainedLC
-> cd_lc.LCTrainTestPairs
-----
lc_class : varchar(255)    # class name for the likelihood classifier
lc_label='' : varchar(255) # descriptor for the model
lc_test_mu_logl  : float  # mean loglikelihood
lc_testset_size  : int    # size of the testset
%}

classdef ShuffledLCModelFits < dj.Relvar & dj.AutoPopulate

	properties
		popRel  = cd_shuffle.ShuffledTrainedLC * cd_lc.LCTrainTestPairs
    end
    
    methods
        function self = ShuffledLCModelFits(varargin)
            self.restrict(varargin{:});
        end
        
        function [dataSet, decoder] = getTrainSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getDataSet(cd_shuffle.ShuffledTrainedLC & key);
        end
        
        function [dataSet, decoder] = getTestSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            decoder = getDecoder(cd_decoder.TrainedDecoder & key);
            dataSet = fetchDataSet(cd_lc.LCTestSets & key);
            dataSet = prepareDataSet(dataSet, decoder, key);
            dataSet = shuffleDataSet(cd_shuffle.ShuffleParam & key, dataSet);
        end
        
        function [trainset, testset, decoder, model]=getAll(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [trainset, decoder] = getTrainSet(self, key);
            [testset, ~] = getTestSet(self, key);
            model = getLC(cd_shuffle.ShuffledTrainedLC & key);
        end
            
    end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            lc_info = fetch(cd_shuffle.ShuffledTrainedLC & key ,'*');
            tuple.lc_class = lc_info.lc_class;
            tuple.lc_label = lc_info.lc_label;
            
            
            lc_model = getLC(cd_shuffle.ShuffledTrainedLC & key);
            dataSet = self.getTestSet(key);
            
            [muLL, logLList] = lc_model.getLogLikelihood(dataSet);
            fprintf('%s model fit mu_logl = %.3f\n', lc_model.modelName, muLL);
            tuple.lc_test_mu_logl = muLL;
            tuple.lc_testset_size = length(logLList);
            
			self.insert(tuple)
		end
	end

end