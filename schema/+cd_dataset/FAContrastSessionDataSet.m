%{
cd_dataset.FAContrastSessionDataSet (computed) # data grouped by session and contrast
-> class_discrimination.FASpikeCountSet
dataset_contrast    : varchar(128)           # contrast of the stimulus
-----
-> cd_dataset.DataSets
%}

classdef FAContrastSessionDataSet < dj.Relvar & dj.AutoPopulate

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
                tuple = registerDataSet(cd_dataset.DataSets, self, tuple, c);
                insert(self, tuple);
            end
        end
    end 
    
    methods
        function self = FAContrastSessionDataSet(varargin)
            self.restrict(varargin{:});
        end
        
        function dataSet = fetchDataSet(self, pack)
            if nargin < 2
                pack = true;
            end
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            data = fetch(class_discrimination.ClassDiscriminationTrial * class_discrimination.FASpikeCountTrials & self, '*');
            data = dj.struct.sort(data, 'trial_num');
            contrast = fetchn(self, 'dataset_contrast');
            all_contrast = arrayfun(@num2str, [data.contrast], 'UniformOutput', false);
            pos = strcmp(all_contrast, contrast);
            dataSet = data(pos);
            if pack
                dataSet = packData(dataSet);
            end
        end
	end

end