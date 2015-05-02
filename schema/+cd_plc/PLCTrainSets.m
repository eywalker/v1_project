%{
cd_plc.PLCTrainSets (computed)          # trainset for PLC
plc_trainset_owner      : varchar(255)       # name of the table that owns this dataset
plc_trainset_hash       : varchar(255)       # SHA-1 hash for the primary key of the target data entry
-----
-> cd_plset.PLSets
%}

classdef PLCTrainSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(cd_plset.PLSets, ...
            'plset_owner -> plc_trainset_owner', ...
            'plset_hash -> plc_trainset_hash');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.plset_owner = tuple.plc_trainset_owner;
            tuple.plset_hash = tuple.plc_trainset_hash;
            self.insert(tuple);
		end
    end
    
    methods
        function plSet = fetchPLSet(self)
                assert(count(self)==1, 'Only can fetch one dataset at a time!');
                plSet = fetchPLSet(cd_plset.PLSets & self);
        end
    end
end