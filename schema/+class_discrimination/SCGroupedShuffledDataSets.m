%{
class_discrimination.SCGroupedShuffledDataSets (computed) # shuffled dataset grouped by stimulus and contrast
->class_discrimination.ContrastSessionDataSet
->class_discrimination.ShuffleParams
-----
->class_discrimination.DataSets
%}

classdef SCGroupedShuffledDataSets < dj.Relvar & dj.AutoPopulate
    properties
		popRel = pro(class_discrimination.ContrastSessionDataSet * class_discrimination.ShuffleParams);
	end

	
    methods
        function self = SCGroupedShuffledDataSets(varargin)
            self.restrict(varargin{:});
        end
        
        function shuffledDataSet = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            dataSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & pro(self));
            params = fetch(class_discrimination.ShuffleParams & self, '*');
            shuffle_func = eval(['@', params.shuffle_method]);
            shuffledDataSet = shuffle_func(dataSet, params.shuffle_binwidth, params.shuffle_seed);
        end
    end
    
	methods(Access=protected)
        
		function makeTuples(self, key)
            tuple = key;
            shuffle_method = fetch1(class_discrimination.ShuffleParams & key, 'shuffle_method')
            tuple.dataset_id = registerDataSet(class_discrimination.DataSets, self, ...
                ['Shuffled spike counts: ', shuffle_method]);
            insert(self, tuple);
		end
    end

end