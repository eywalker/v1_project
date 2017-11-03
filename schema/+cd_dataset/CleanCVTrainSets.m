%{
cd_dataset.CleanCVTrainSets (computed) # CV train set
-> cd_dataset.CleanCrossValidationSets
cv_index    : int       # index into the N-way CV
---
train_indices: longblob  # trial indices for the test set
-> cd_dataset.DataSets
%}

classdef CleanCVTrainSets < dj.Relvar
	methods

		function makeTuples(self, key, idx, trainInd)
            fprintf('Registering train set %d...\n', idx);
            tuple = key;
            tuple.cv_index = idx;
			tuple = registerDataSet(cd_dataset.DataSets, self, tuple, 'CV train set');
            tuple.train_indices = trainInd;
            insert(self, tuple);
        end
        
        function self = CleanCVTrainSets(varargin)
            self.restrict(varargin{:});
        end
        
        function dataSet = fetchDataSet(self, pack)
            if nargin < 2
                pack = true;
            end
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            data = fetch(self * class_discrimination.CSCTLookup * class_discrimination.ClassDiscriminationTrial * class_discrimination.SpikeCountTrials & class_discrimination.CleanSpikeCountTrials, '*');
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