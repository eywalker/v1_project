%{
-> cd_decoder.TrainedDecoder
-> cd_dlset.ShuffleParam
%}

classdef DLSet < dj.Computed
    properties
        popRel = cd_decoder.TrainedDecoder * cd_dlset.ShuffleParam & 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"'
    end

	methods(Access=protected)
		function makeTuples(self, key)
			 self.insert(key)
		end
    end
    
    methods
    
        function [dataSet, decoder] = getDataSet(self, key, nori)
            if nargin < 3
                nori = [];
            end
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getAll(cd_decoder.TrainedDecoder & key);
            dataSet = prepareDataSet(dataSet, decoder, key, nori);
            dataSet = shuffleDataSet(cd_dlset.ShuffleParam & key, dataSet);
        end
    end

end