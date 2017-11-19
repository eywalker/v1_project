%{
# Clean contrast set with decoded point peak estimate
-> cd_dataset.CleanContrastSessionDataSet
-> cd_decoder.TrainedDecoder
-> cd_plset.LikelihoodPeakWidthExtractors
-> cd_point.TrainedPointDecoder
-----
-> cd_plset.PLSets
plset_likelihood_peak   : longblob             # extracted peak of the likelihood
plset_likelihood_width  : longblob             # extracted width of the likelihood
%}

classdef PointDecodedCCSPLSet < dj.Computed
	properties
        % select out all possible combination of the keys (all contrast
        % sessions by decoder models by pw_extractors) for which there
        % already exists a trained decoder based on the dataset and model
		popRel = cd_decoder.TrainedDecoder * cd_dataset.CleanContrastSessionDataSet * cd_plset.LikelihoodPeakWidthExtractors * cd_point.TrainedPointDecoder & (cd_decoder.DecoderTrainSets * cd_dataset.DataSets);
    end

    methods
        function self=PointDecodedCCSPLSet(varargin)
            self.restrict(varargin{:});
        end
        
        function plSet = fetchPLSet(self)
            assert(count(self)==1, 'Only can fetch one plset at a time!');
            plSet = fetchDataSet(cd_dataset.CleanContrastSessionDataSet & self);
            info = fetch(self, '*');
            plSet.likelihood_peak = info.plset_likelihood_peak;
            plSet.likelihood_width = info.plset_likelihood_width;
            
        end
    end
    
	methods(Access=protected)
		function makeTuples(self, key)
            tuple = key;
            decoder = getDecoder(cd_decoder.TrainedDecoder & key);
            ptdec = getPointDecoder(cd_point.PointDecoderModels & key);
            dataSet = fetchDataSet(cd_dataset.CleanContrastSessionDataSet & key);
            pwextractor = getPWExtractor(cd_plset.LikelihoodPeakWidthExtractors & key);
            decodeOri = linspace(220, 320, 1000);
            L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
            [~, width]=pwextractor(decodeOri, L);
            peak = ptdec.decode(dataSet);
            tuple.plset_likelihood_peak = peak(:)';
            tuple.plset_likelihood_width = width(:)';
            tuple = registerPLSet(cd_plset.PLSets, self, tuple, tuple.dataset_contrast);
            insert(self, tuple);
		end
	end

end