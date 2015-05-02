%{
cd_lc.LCModelFits (computed) # my newest table
-> cd_lc.TrainedLC
-> cd_lc.LCTrainTestPairs
-----
lc_class : varchar(255)    # class name for the likelihood classifier
lc_label='' : varchar(255) # descriptor for the model
lc_test_mu_logl  : float  # mean loglikelihood
lc_testset_size  : int    # size of the testset
%}

classdef LCModelFits < dj.Relvar & dj.AutoPopulate

	properties
		popRel  = cd_lc.TrainedLC * cd_lc.LCTrainTestPairs
    end
    
    methods
        function self = LCModelFits(varargin)
            self.restrict(varargin{:});
        end
    end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            lc_info = fetch(cd_lc.TrainedLC & key ,'*');
            tuple.lc_class = lc_info.lc_class;
            tuple.lc_label = lc_info.lc_label;
            
            
            lc_model = getLC(cd_lc.TrainedLC & key);
            
            decoder = getDecoder(cd_decoder.TrainedDecoder & key);
            % fetch the test dataset
            dataSet = fetchDataSet(cd_lc.LCTestSets & key);
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            dataSet.decodeOri = decodeOri;
            dataSet.likelihood = L;
            [muLL, logLList] = lc_model.getLogLikelihood(dataSet);
            fprintf('%s model fit mu_logl = %.3f\n', lc_model.modelName, muLL);
            tuple.lc_test_mu_logl = muLL;
            tuple.lc_testset_size = length(logLList);
            
			self.insert(tuple)
		end
	end

end