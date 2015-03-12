%{
class_discrimination.LCModelFits (computed) # my newest table
-> class_discrimination.TrainedLikelihoodClassifiers
-> class_discrimination.LCTrainTestPairs
-----
lc_class : varchar(255)    # class name for the likelihood classifier
lc_label='' : varchar(255) # descriptor for the model
fit_mu_logl  : float  # mean loglikelihood
fit_logl  :  float  # total log likelihood
%}

classdef LCModelFits < dj.Relvar & dj.AutoPopulate

	properties
		popRel  = class_discrimination.TrainedLikelihoodClassifiers * class_discrimination.LCTrainTestPairs
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            lc_info = fetch(class_discrimination.TrainedLikelihoodClassifiers & key ,'*');
            tuple.lc_class = lc_info.lc_class;
            tuple.lc_label = lc_info.lc_label;
            
            
            lc_model = getLC(class_discrimination.TrainedLikelihoodClassifiers & key);
            
            decoder = getDecoder(class_discrimination.TrainedDecoder & key);
            % fetch the test dataset
            dataSet = fetchDataSet(class_discrimination.LCTestSets & key);
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            dataSet.decodeOri = decodeOri;
            dataSet.likelihood = L;
            [muLL, logLList] = lc_model.getLogLikelihood(dataSet);
            tuple.fit_mu_logl = muLL;
            tuple.fit_logl = sum(logLList);
            
			self.insert(tuple)
		end
	end

end