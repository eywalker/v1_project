%{
-> cd_decoder.TrainedDecoder
-> cd_shuffle.ShuffleParam
%}

classdef DLSet < dj.Computed

	methods(Access=protected)
		function makeTuples(self, key)
			 self.insert(key)
		end
    end
    
    methods
    
        function [dataSet, decoder] = getDataSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getAll(cd_decoder.TrainedDecoder & key);
            dataSet = prepareDataSet(dataSet, decoder, key);
            dataSet = shuffleDataSet(cd_shuffle.ShuffleParam & key, dataSet);
        end
    end

end