%{
cd_dataset.DataSets (manual) # a collection of datasets
dataset_owner      : varchar(255)       # name of the table that owns this dataset
dataset_hash       : varchar(255)       # SHA-1 hash for the primary key of the target data entry
------
dataset_label=''   : varchar(255)       # label on the data
%}

classdef DataSets < dj.Relvar
    methods
        function self = DataSets(varargin)
            self.restrict(varargin{:});
        end
        function key = registerDataSet(self, owner, key, label)
            if nargin < 4
                label = '';
            end
            if ~ischar(owner) % if owner given as an object
                owner = class(owner);
            end
            assert(ismember('dj.Table', superclasses(owner)),...
                'Owner of the table must be a valid dj.Table derivative');
            hash = gethash(key);
            
            key.dataset_owner = owner;
            key.dataset_hash = hash;
            
            
            tuple.dataset_owner = owner;
            tuple.dataset_hash = hash;
            tuple.dataset_label = label;
            insert(self, tuple);
        end
        
        function dataSet = fetchDataSet(self, pack)
            if nargin < 2
                pack = true;
            end
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            info = fetch(self, '*');
            table = eval(info.dataset_owner);
            dataSet = fetchDataSet(table & self);
            if pack
                dataSet = packData(dataSet);
            end
        end
    end
end