%{
cd_plc.PLCTestFits (computed) # my newest table
-> cd_plc.TrainedPLC
-> cd_plc.PLCTrainTestPairs
-----
plc_class    : varchar(255)     # class name for the likelihood classifier
plc_label='' : varchar(255)     # descriptor for the model
plc_test_mu_logl   : double           # mean log likelihood on test set
plc_testset_size  : int          # size of the testset
%}

classdef PLCTestFits < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_plc.TrainedPLC * cd_plc.PLCTrainTestPairs
    end
    
    methods
        function self = PLCTestFits(varargin)
            self.restrict(varargin{:});
        end
    end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            plc_info = fetch(cd_plc.TrainedPLC & key, '*');
            tuple.plc_class = plc_info.plc_class;
            tuple.plc_label = plc_info.plc_label;
            
            plc_model = getPLC(cd_plc.TrainedPLC & key);
            
            plSet = fetchPLSet(cd_plc.PLCTestSets & key);
            [muLL, logLList] = plc_model.getLogLikelihood(plSet);
            fprintf('%s model fit mu_logl = %.3f\n', plc_model.modelName, muLL);
            tuple.plc_test_mu_logl = muLL;
            tuple.plc_testset_size = length(logLList);
            
            self.insert(tuple);
		end
	end

end