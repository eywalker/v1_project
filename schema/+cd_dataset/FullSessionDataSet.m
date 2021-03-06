%{
cd_dataset.FullSessionDataSet (computed) # my newest table
-> class_discrimination.SpikeCountSet
-----
-> cd_dataset.DataSets
%}

classdef FullSessionDataSet < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.SpikeCountSet;
	end

	methods(Access=protected)
		function makeTuples(self, key)
            tuple = key;
            tuple= registerDataSet(cd_dataset.DataSets, self, tuple, 'whole session');
			self.insert(tuple);
        end
    end
    methods
        function dataSet = fetchDataSet(self, pack)
            if nargin < 2
                pack = true;
            end
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            dataSet = fetch(class_discrimination.ClassDiscriminationTrial * class_discrimination.SpikeCountTrials & self, '*');
            if pack
                dataSet = packData(dataSet);
            end
        end
	end

end