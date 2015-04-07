%{
class_discrimination.CVTestSets (computed) # CV test sets
-> class_discrimination.CrossValidationSets
cv_index    : int       # index into the N-way CV
---
test_indices: longblob  # trial indices for the test set
-> class_discrimination.DataSets
%}

classdef CVTestSets < dj.Relvar
	methods

		function makeTuples(self, key, idx, testInd)
            fprintf('Registering test set %d...\n', idx);
            tuple = key;
            tuple.cv_index = idx;
            tuple.test_indices = testInd;
			id = registerDataSet(class_discrimination.DataSets, self, 'CV test set');
            tuple.dataset_id = id;
            insert(self, tuple);
        end
        
        function self = CVTestSets(varargin)
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
            test_indices = info.test_indices;
            dataSet = data(test_indices);
            if pack
                dataSet = packData(dataSet);
            end
        end
    end

end