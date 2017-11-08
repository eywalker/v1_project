%{
cd_plset.PLSets (manual)             # my newest table
plset_owner  : varchar(255)        # name of the table that owns this dataset
plset_hash   : varchar(255)        # SHA-1 hash for the primary key of the target data entry
-----
plset_label=''  : varchar(255)  # labvel for this pl set
%}

classdef PLSets < dj.Relvar
    methods
        function self = PLSets(varargin)
            self.restrict(varargin{:});
        end
        
        function key = registerPLSet(self, owner, key, label)
            if nargin < 4
                label = '';
            end
            if ~ischar(owner) % if owner given as an object
                owner = class(owner);
            end
            assert(ismember('dj.Table', superclasses(owner)) | ismember('dj.internal.Table', superclasses(owner)),...
                'Owner of the table must be a valid dj.Table derivative');
            hash = gethash(key);
            
            key.plset_owner = owner;
            key.plset_hash = hash;
            
            tuple.plset_owner = owner;
            tuple.plset_hash = hash;
            tuple.plset_label = label;
            insert(self, tuple);
        end
        
        function plSet = fetchPLSet(self, pack)
            if nargin < 2
                pack = true;
            end
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            info = fetch(self, '*');
            table = eval(info.plset_owner);
            plSet = fetchPLSet(table & self);
            if pack
                plSet = packData(plSet);
            end
        end
    end
    
end