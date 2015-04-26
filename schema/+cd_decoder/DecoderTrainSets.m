%{
cd_decoder.DecoderTrainSets (computed) # trainset for decoder
dec_trainset_owner      : varchar(255)       # name of the table that owns this dataset
dec_trainset_hash       : varchar(255)       # SHA-1 hash for the primary key of the target data entry
-----
-> cd_dataset.DataSets
%}

classdef DecoderTrainSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(cd_dataset.DataSets, ...
            'dataset_owner -> dec_trainset_owner', ...
            'dataset_hash -> dec_trainset_hash');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.dataset_owner = tuple.dec_trainset_owner;
            tuple.dataset_hash = tuple.dec_trainset_hash;
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