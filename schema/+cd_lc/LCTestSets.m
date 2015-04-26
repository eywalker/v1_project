%{
cd_lc.LCTestSets (computed) # lc test sets
lc_testset_owner      : varchar(255)       # name of the table that owns this dataset
lc_testset_hash       : varchar(255)       # SHA-1 hash for the primary key of the target data entry
-----
-> cd_dataset.DataSets
%}

classdef LCTestSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(cd_dataset.DataSets, ...
            'dataset_owner -> lc_testset_owner', ...
            'dataset_hash -> lc_testset_hash');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.dataset_owner = tuple.lc_testset_owner;
            tuple.dataset_hash = tuple.lc_testset_hash;
            self.insert(tuple)
		end
    end
    
    methods
        function dataSet = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            dataSet = fetchDataSet(cd_dataset.DataSets & self);
        end
    end
end