%{
class_discrimination.LCTrainSets (computed) # my newest table
lc_trainset_id       : int           # id for likelihood classifier trainset
-----
-> class_discrimination.DataSets
%}

classdef LCTrainSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(class_discrimination.DataSets, 'dataset_id -> lc_trainset_id');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.dataset_id = tuple.lc_trainset_id;
            self.insert(tuple)
		end
    end
    
    methods
        function dataSet = fetchDataSet(self)
                assert(count(self)==1, 'Only can fetch one dataset at a time!');
                dataSet = fetchDataSet(class_discrimination.DataSets & self);
        end
    end
end