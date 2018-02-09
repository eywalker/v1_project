%{
-> cd_decoder.DecoderTrainSets
-> cd_dataset.CVParams
%}

classdef CVSet < dj.Computed
	methods(Access=protected)
        function makeTuples(self, key)
            data  = fetchDataSet(cd_decoder.DecoderTrainSets & key, '*');
            seed = key.cv_seed;
            rng(seed, 'twister');
            fprintf('Building CV set...\n');
            insert(self, key);
            N = key.cv_n;
            nTrials = size(data.counts, 2);
            trialInd = randperm(nTrials);
            splits = round(linspace(0,nTrials,N+1));
            fprintf('%d-way cross validation\n', N);
            for ind = 1:N
                tuple = key;
                testInd = trialInd(splits(ind)+1:splits(ind+1)); % pick test sets
                trainInd = trialInd([1:splits(ind), splits(ind+1)+1:end]); % pick training sets
                tuple.cv_index = ind;
                tuple.train_indices = trainInd;
                tuple.test_indices = testInd;
                insert(cd_dlset.CVSetMember, tuple);
            end        
		end

		
	end

end