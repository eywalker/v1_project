%{
cd_dataset.SimBehCVTrainSets (computed) # CV train set
-> cd_dataset.SimBehCVSets
cv_index    : int       # index into the N-way CV
---
train_indices: longblob  # trial indices for the test set
-> cd_dataset.DataSets
%}

classdef SimBehCVTrainSets < dj.Relvar
	methods

		function makeTuples(self, key, idx, trainInd)
            fprintf('Registering train set %d...\n', idx);
            tuple = key;
            tuple.cv_index = idx;
			tuple = registerDataSet(cd_dataset.DataSets, self, tuple, 'CV train set');
            tuple.train_indices = trainInd;
            insert(self, tuple);
        end
        
        function self = SimBehCVTrainSets(varargin)
            self.restrict(varargin{:});
        end
        
        function dataSet = fetchDataSet(self, pack)
            if nargin < 2
                pack = true;
            end
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            data = fetchDataSet(cd_dataset.SimulatedBehavior & self);
            info = fetch(self, '*');
            train_indices = info.train_indices;
            dataSet = data(train_indices);
            if pack
                dataSet = packData(dataSet);
            end
        end
	end

end