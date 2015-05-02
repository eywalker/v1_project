%{
cd_plc.PLCTestSets (computed)          # testset for PLC
plc_testset_owner      : varchar(255)       # name of the table that owns this dataset
plc_testset_hash       : varchar(255)       # SHA-1 hash for the primary key of the target data entry
-----
-> cd_plset.PLSets
%}

classdef PLCTestSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(cd_plset.PLSets, ...
            'plset_owner -> plc_testset_owner', ...
            'plset_hash -> plc_testset_hash');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.plset_owner = tuple.plc_testset_owner;
            tuple.plset_hash = tuple.plc_testset_hash;
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