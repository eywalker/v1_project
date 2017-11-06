%{
cd_dataset.SimBehCVSets (computed) # CV sets for simulated behavior
-> cd_dataset.CVParams
-> cd_dataset.SimulatedBehavior
cv_contrast: varchar(128)       # stimulus contrast
%}

classdef SimBehCVSets < dj.Relvar & dj.AutoPopulate
    % CV sets for simulated behavior datasets

	properties
		popRel = cd_dataset.CVParams * pro(cd_dataset.SimulatedBehavior)
	end

	methods(Access=protected)

		function makeTuples(self, key)
            data  = fetchDataSet(cd_dataset.SimulatedBehavior & key);
            all_contrast = data.contrast;
            unique_contrast = unique(all_contrast);
            seed = key.cv_seed;
            rng(seed, 'twister');
            for i = 1:length(unique_contrast)
                c = unique_contrast{i};
                fprintf('Building CV set for contrast %s...\n', c);
                tuple = key;
                tuple.cv_contrast = c;
                insert(self, tuple);
                N = tuple.cv_n;
                pos = find(all_contrast, c);
                trialInd = pos(randperm(length(pos)));
                splits = round(linspace(0,length(pos),N+1));
                fprintf('%d-way cross validation\n', N);
                for ind = 1:N
                    testInd = trialInd(splits(ind)+1:splits(ind+1)); % pick test sets
                    trainInd = trialInd([1:splits(ind), splits(ind+1)+1:end]); % pick training sets
                    makeTuples(cd_dataset.SimBehCVTestSets, tuple, ind, testInd);
                    makeTuples(cd_dataset.SimBehCVTrainSets, tuple, ind, trainInd);
                end  
            end         
		end
	end

end