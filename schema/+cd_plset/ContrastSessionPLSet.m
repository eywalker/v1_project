%{
cd_plset.ContrastSessionPLSet (computed) # PL set grouped by session and contrast
-> cd_dataset.ContrastSessionDataSet
-> cd_decoder.DecoderModels
-> cd_plset.LikelihoodPeakWidthExtractors
-----
-> cd_plset.PLSets
plset_likelihood_peak   : longblob             # extracted peak of the likelihood
plset_likelihood_width  : longblob             # extracted width of the likelihood
%}

classdef ContrastSessionPLSet < dj.Relvar & dj.AutoPopulate

	properties
        % select out all possible combination of the keys (all contrast
        % sessions by decoder models by pw_extractors) for which there
        % already exists a trained decoder based on the dataset and model
		popRel = (cd_dataset.ContrastSessionDataSet * cd_decoder.DecoderModels * cd_plset.LikelihoodPeakWidthExtractors) & (cd_decoder.TrainedDecoder * cd_decoder.DecoderTrainSets);
    end

    methods
        function self=ContrastSessionPLSet(varargin)
            self.restrict(varargin{:});
        end
        
        function plSet = fetchPLSet(self)
            assert(count(self)==1, 'Only can fetch one plset at a time!');
            plSet = fetchDataSet(cd_dataset.ContrastSessionDataSet & self);
            info = fetch(self, '*');
            plSet.likelihood_peak = info.plset_likelihood_peak;
            plSet.likelihood_width = info.plset_likelihood_width;
            
        end
    end
    
	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            rel = pro(cd_dataset.ContrastSessionDataSet * cd_decoder.DecoderTrainSets * cd_decoder.DecoderModels & key);
            decoder = getDecoder(cd_decoder.TrainedDecoder & rel);
            dataSet = fetchDataSet(cd_dataset.ContrastSessionDataSet & key);
            pwextractor = getPWExtractor(cd_plset.LikelihoodPeakWidthExtractors & key);
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            [peak, width]=pwextractor(decodeOri, L);
            tuple.plset_likelihood_peak = peak(:)';
            tuple.plset_likelihood_width = width(:)';
            tuple = registerPLSet(cd_plset.PLSets, self, tuple, tuple.dataset_contrast);
            insert(self, tuple);
		end
	end

end