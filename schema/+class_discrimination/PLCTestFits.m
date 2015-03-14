%{
class_discrimination.PLCTestFits (computed) # my newest table
-> class_discrimination.TrainedPLC
-> class_discrimination.PLCTrainTestPairs
-----
plc_class    : varchar(255)     # class name for the likelihood classifier
plc_label='' : varchar(255)     # descriptor for the model
plc_test_mu_logl   : double           # mean log likelihood on test set
plc_test_logl  :  float  # total log likelihood on the test set
%}

classdef PLCTestFits < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.TrainedPLC * class_discrimination.PLCTrainTestPairs
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            plc_info = fetch(class_discrimination.TrainedPLC & key, '*');
            tuple.plc_class = plc_info.plc_class;
            tuple.plc_label = plc_info.plc_label;
            
            plc_model = getPLC(class_discrimination.TrainedPLC & key);
            plSet = fetchPLSet(class_discrimination.PLCTestSets & key);
            [muLL, logLList] = plc_model.getLogLikelihood(plSet);
            tuple.plc_test_mu_logl = muLL;
            tuple.plc_test_logl = sum(logLList);
            
            self.insert(tuple);
		end
	end

end