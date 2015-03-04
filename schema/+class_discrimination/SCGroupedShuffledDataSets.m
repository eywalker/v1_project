%{
class_discrimination.SCGroupedShuffledDataSets (computed) # shuffled dataset grouped by stimulus and contrast
->class_discrimination.ContrastSessionDataSet
->class_discrimination.ShuffleParams
-----
->class_discrimination.DataSets
%}

classdef SCGroupedShuffledDataSets < dj.Relvar & dj.AutoPopulate
    properties
		popRel = class_discrimination.ContrastSessionDataSet * class_discrimination.ShuffleParams;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            dataSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & key);
            all_contrast = arrayfun(@num2str, [data.contrast], 'UniformOutput', false);
            unique_contrast = unique(all_contrast);
            for i = 1:length(unique_contrast)
                c = unique_contrast{i};
                tuple = key;
                tuple.dataset_contrast = c;
                id = registerDataSet(class_discrimination.DataSets, self, c);
                tuple.dataset_id = id;
                insert(self, tuple);
            end
        end
    end 
    
    methods
        function self = SCGroupedShuffledDataSets(varargin)
            self.restrict(varargin{:});
        end
        
        function dataSet = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            data = fetch(class_discrimination.ClassDiscriminationTrial * class_discrimination.SpikeCountTrials & self, '*');
            contrast = fetchn(self, 'dataset_contrast');
            all_contrast = arrayfun(@num2str, [data.contrast], 'UniformOutput', false);
            pos = strcmp(all_contrast, contrast);
            dataSet = data(pos);
            dataSet = packData(dataSet);
        end
	end

end