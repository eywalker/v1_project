%{
class_discrimination.ContrastSessionDataSet (computed) # data grouped by session and contrast
-> class_discrimination.SpikeCountSet
dataset_contrast    : varchar(128)           # contrast of the stimulus
-----
-> class_discrimination.DataSets
%}

classdef ContrastSessionDataSet < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.SpikeCountSet;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            data  = fetch(class_discrimination.ClassDiscriminationTrial & key, '*');
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
        function self = ContrastSessionDataSet(varargin)
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