%{
class_discrimination.DataSets (manual) # a collection of datasets
dataset_id   : int             # unique identifier for the dataset
-----
dataset_owner      : varchar(255)             # name of the table that owns this dataset
dataset_label=''   : varchar(255)             # label for the dataset
%}

classdef DataSets < dj.Relvar
    methods
        function self = DataSets(varargin)
            self.restrict(varargin{:});
        end
        function new_id = registerDataSet(self, owner, label)
            if nargin < 3
                label = '';
            end
            last_id = max(fetchn(class_discrimination.DataSets, 'dataset_id'));
            if isempty(last_id)
                last_id = 0;
            end
            new_id = last_id + 1;
            if ~ischar(owner) % if owner given as an object
                owner = class(owner);
            end
            
            assert(ismember('dj.Table', superclasses(owner)), 'Owner of the table must be a valid dj.Table derivative');
            
            
            
            tuple.dataset_id = new_id;
            tuple.dataset_owner = owner;
            tuple.dataset_label = label;
            insert(self, tuple);
        end
        
        function dataSet = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            info = fetch(self, '*');
            table = eval(info.dataset_owner);
            dataSet = fetchDataSet(table & sprintf('dataset_id = %d', info.dataset_id));
        end
    end
end