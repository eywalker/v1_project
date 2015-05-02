%{
cd_dataset.CVTestSets (computed) # CV test sets
-> cd_dataset.CrossValidationSets
cv_index    : int       # index into the N-way CV
---
test_indices: longblob  # trial indices for the test set
-> cd_dataset.DataSets
%}

classdef CVTestSets < dj.Relvar
	methods

		function makeTuples(self, key, idx, testInd)
            fprintf('Registering test set %d...\n', idx);
            tuple = key;
            tuple.cv_index = idx; 
			tuple = registerDataSet(cd_dataset.DataSets, self, tuple, 'CV test set');
            tuple.test_indices = testInd;
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
            data = fetch(self * class_discrimination.ClassDiscriminationTrial * class_discrimination.SpikeCountTrials, '*');
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