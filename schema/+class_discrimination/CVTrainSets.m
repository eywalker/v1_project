%{
class_discrimination.CVTrainSets (computed) # CV train set
-> class_discrimination.CrossValidationSets
cv_index    : int       # index into the N-way CV
---
train_indices: longblob  # trial indices for the test set
-> class_discrimination.DataSets
%}

classdef CVTrainSets < dj.Relvar
	methods

		function makeTuples(self, key, idx, trainInd)
            fprintf('Registering train set %d...\n', idx);
            tuple = key;
            tuple.cv_index = idx;
            tuple.train_indices = trainInd;
			id = registerDataSet(class_discrimination.DataSets, self, 'CV train set');
            tuple.dataset_id = id;
            insert(self, tuple);
        end
        
        function self = CVTrainSets(varargin)
            self.restrict(varargin{:});
        end
        
        function dataSet = fetchDataSet(self, pack)
            if nargin < 2
                pack = true;
            end
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            data = fetch(class_discrimination.ClassDiscriminationTrial * class_discrimination.SpikeCountTrials & self, '*');
            data = dj.struct.sort(data, 'trial_num');
            info = fetch(self, '*');
            train_indices = info.train_indices;
            dataSet = data(train_indices);
            if pack
                dataSet = packData(dataSet);
            end
        end
	end

end