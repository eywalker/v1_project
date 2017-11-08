%{
cd_plset.ShuffledPLSets (computed) # shuffled PL sets
-> cd_plset.PLShuffleParams
source_plset_owner    : varchar(255)       # name of the table that owns the source plset
source_plset_hash     : varchar(255)       # SHA-1 hash for the primary key of the source entry in its table
-----
-> cd_plset.PLSets
%}

classdef ShuffledPLSets < dj.Relvar & dj.AutoPopulate

	properties
        popRel = pro(cd_plset.PLSets & cd_plset.CleanContrastSessionPLSet, 'plset_owner -> source_plset_owner', 'plset_hash -> source_plset_hash') * cd_plset.PLShuffleParams;
    end
    
    methods
        function self=ShuffledPLSets(varargin)
            self.restrict(varargin{:});
        end
        
        function shuffledPLSet = fetchPLSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            rel = pro(pro(self), 'source_plset_owner -> plset_owner', 'source_plset_hash -> plset_hash');
            plSet = fetchPLSet(cd_plset.PLSets & rel);
            params = fetch(cd_plset.PLShuffleParams & self, '*');
            shuffle_func = eval(['@', params.plshuffle_method]);
            shuffledPLSet = shuffle_func(plSet, params.plshuffle_binwidth, params.plshuffle_seed);
        end
    end

	methods(Access=protected)
        
		function makeTuples(self, key)
            tuple = key;
            shuffle_method = fetch1(cd_plset.PLShuffleParams & key, 'plshuffle_method');
            tuple = registerPLSet(cd_plset.PLSets, self, tuple, shuffle_method);
            insert(self, tuple);
		end
    end
    
    

end