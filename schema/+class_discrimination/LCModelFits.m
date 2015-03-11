%{
class_discrimination.LCModelFits (computed) # my newest table
-> class_discrimination.TrainedLikelihoodClassifiers
-> class_discrimination.LCTestSets
-----
lc_class : varchar(255)    # class name for the likelihood classifier
lc_label='' : varchar(255) # descriptor for the model
mu_logl  : float  # mean loglikelihood
logl  :  float  # total log likelihood
n_trials     : int # number of trials
%}

classdef LCModelFits < dj.Relvar & dj.AutoPopulate

	properties
		popRel  = class_discrimination.TrainedLikelihoodClassifiers * class_discrimination.LCTestSets
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
            tuple.mu_logl = muLL;
            tuple.logl = sum(logLList);
            tuple.n_trials = length(logLList);
            
			self.insert(tuple)
		end
	end

end