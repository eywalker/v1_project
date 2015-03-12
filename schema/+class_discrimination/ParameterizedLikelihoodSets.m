%{
class_discrimination.ParameterizedLikelihoodSets (manual) # my newest table
plset_id  : int        # unique identifier for the parameterized likelihood set
-----
plset_owner : varchar(255) # name of the table that owns this dataset
plset_label=''  : varchar(255)  # labvel for this pl set
%}

classdef ParameterizedLikelihoodSets < dj.Relvar
    methods
        function self = ParameterizedLikelihoodSets(varargin)
            self.restrict(varargin{:});
        end
        
        function new_id = registerPLSet(self, owner, label)
            if nargin < 3
                label = '';
            end
            last_id = max(fetchn(class_discrimination.ParameterizedLikelihoodSets, 'plset_id'));
            if isempty(last_id)
                last_id = 0;
            end
            new_id = last_id + 1;
            if ~ischar(owner) % if owner gien as an object
                owner = class(owner);
            end
            
            assert(ismember('dj.Table', superclasses(owner)), 'Owner of the table must be a valid dj.Table derivative');
            
            tuple.plset_id = new_id;
            tuple.plset_owner = owner;
            tuple.plset_label = label;
            insert(self, tuple);
        end
        
        function plSet = fetchPLSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            info = fetch(self, '*');
            table = eval(info.plset_owner);
            plSet = fetchPLSet(table & sprintf('plset_id = %d', info.plset_id));
            plSet = packData(plSet);
        end
    end
    
end