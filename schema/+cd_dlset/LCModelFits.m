%{
# results on testset
-> cd_dlset.TrainedLC
-----
lc_test_mu_logl  : float  # mean loglikelihood
lc_test_logl     : longblob # logl values for all trials
lc_testset_size  : int    # size of the testset
%}

classdef LCModelFits < dj.Computed
    methods        
        function [dataSet, decoder] = getTrainSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getDataSet(cd_dlset.TrainedLC & key);
        end
        
        function [dataSet, decoder] = getTestSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getDataSet(cd_dlset.DLSet & key);
            test_indices = fetch1(cd_dlset.CVSetMember & key, 'test_indices');
            dataSet = selectData(dataSet, test_indices, {'decoder', 'goodUnits', 'decodeOri', 'key'});
        end
        
        function [trainset, testset, decoder, model]=getAll(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [trainset, decoder] = getTrainSet(self, key);
            [testset, ~] = getTestSet(self, key);
            model = getLC(cd_dlset.TrainedLC & key);
        end
            
    end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            
            lc_model = getLC(cd_dlset.TrainedLC & key);
            dataSet = self.getTestSet(key);
            
            [muLL, logl] = lc_model.getLogLikelihood(dataSet);
            fprintf('%s model fit mu_logl = %.3f\n', lc_model.modelName, muLL);
            tuple.lc_test_mu_logl = muLL;
            tuple.lc_test_logl = logl;
            tuple.lc_testset_size = length(logl);
            
			self.insert(tuple)
		end
	end

end