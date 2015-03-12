%{
class_discrimination.ContrastSessionParameterizedLikelihoods (computed) # my newest table
-> class_discrimination.ContrastSessionDataSet
-> class_discrimination.LikelihoodPeakWidthExtractors
-----
-> class_discrimination.ParameterizedLikelihoodSets
likelihood_peak   : longblob             # extracted peak of the likelihood
likelihood_width  : longblob            # extracted width of the likelihood
%}

classdef ContrastSessionParameterizedLikelihoods < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.ContrastSessionDataSet * class_discrimination.LikelihoodPeakWidthExtractors
    end

    methods
        function self=ContrastSessionParameterizedLikelihoods(varargin)
            self.restrict(varargin{:});
        end
        
        function plSet = fetchPLSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            plSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & self);
            info = fetch(self, '*');
            plSet.likelihood_peak = info.likelihood_peak;
            plSet.likelihood_width = info.likelihood_width;
            
        end
    end
    
	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            rel = pro(class_discrimination.ContrastSessionDataSet & key, 'dataset_id -> decoder_trainset_id');
            decoder = getDecoder(class_discrimination.TrainedDecoder & rel);
            dataSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & key);
            pwextractor = getPWExtractor(class_discrimination.LikelihoodPeakWidthExtractors & key);
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            [peak, width]=pwextractor(decodeOri, L);
            tuple.likelihood_peak = peak(:)';
            tuple.likelihood_width = width(:)';
            id = registerPLSet(class_discrimination.ParameterizedLikelihoodSets, self, tuple.dataset_contrast);
            tuple.plset_id = id;
            insert(self, tuple);
		end
	end

end