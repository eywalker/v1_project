%{
cd_dataset.SCGroupedShuffledDataSets (computed) # shuffled dataset grouped by stimulus and contrast
->cd_dataset.ContrastSessionDataSet
->cd_dataset.ShuffleParams
-----
->cd_dataset.DataSets
%}

classdef SCGroupedShuffledDataSets < dj.Relvar & dj.AutoPopulate
    properties
		popRel = pro(cd_dataset.ContrastSessionDataSet * cd_dataset.ShuffleParams);
	end

	
    methods
        function self = SCGroupedShuffledDataSets(varargin)
            self.restrict(varargin{:});
        end
        
        function shuffledDataSet = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            dataSet = fetchDataSet(cd_dataset.ContrastSessionDataSet & pro(self));
            params = fetch(cd_dataset.ShuffleParams & self, '*');
            shuffle_func = eval(['@', params.shuffle_method]);
            shuffledDataSet = shuffle_func(dataSet, params.shuffle_binwidth, params.shuffle_seed);
        end
    end
    
	methods(Access=protected)
        
		function makeTuples(self, key)
            tuple = key;
            shuffle_method = fetch1(cd_dataset.ShuffleParams & key, 'shuffle_method');
            tuple = registerDataSet(cd_dataset.DataSets, self, tuple, ...
                ['Shuffled spike counts: ', shuffle_method]);
            insert(self, tuple);
		end
    end

end