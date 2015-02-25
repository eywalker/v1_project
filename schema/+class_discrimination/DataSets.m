%{
class_discrimination.DataSets (manual) # a collection of datasets
dataset_id   : int             # unique identifier for the dataset
-----
dataset_label=''   : varchar(255)             # label for the dataset
%}

classdef DataSets < dj.Relvar
    methods
        function self = DataSets(varargin)
            self.restrict(varargin{:});
        end
        function id = registerDataSet(self, dataSet, label)
            if nargin < 3
                label = ''
            end
            last_id = max(fetchn(class_discrimination.DataSets, 'dataset_id'));
            if isempty(last_id)
                last_id = 0;
            end
            tuple.dataset_id = last_id + 1;
            tuple.dataset_label = label;
            insert(self, tuple);
            makeTuples(class_discrimination.DataSetEntries, tuple, dataSet);
            id = tuple.dataset_id;
        end
    end
end