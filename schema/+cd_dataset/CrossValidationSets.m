%{
cd_dataset.CrossValidationSets (computed) # my newest table
-> cd_dataset.CVParams
-> class_discrimination.SpikeCountSet
cv_contrast: varchar(128)       # stimulus contrast
%}

classdef CrossValidationSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_dataset.CVParams * class_discrimination.SpikeCountSet
	end

	methods(Access=protected)

		function makeTuples(self, key)
            data  = fetch(class_discrimination.ClassDiscriminationTrial & key, '*');
            data = dj.struct.sort(data, 'trial_num');
            all_contrast = arrayfun(@num2str, [data.contrast], 'UniformOutput', false);
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
                pos = find(strcmp(all_contrast, c));
                trialInd = pos(randperm(length(pos)));
                splits = round(linspace(0,length(pos),N+1));
                fprintf('%d-way cross validation\n', N);
                for ind = 1:N
                    testInd = trialInd(splits(ind)+1:splits(ind+1)); % pick test sets
                    trainInd = trialInd([1:splits(ind), splits(ind+1)+1:end]); % pick training sets
                    makeTuples(cd_dataset.CVTestSets, tuple, ind, testInd);
                    makeTuples(cd_dataset.CVTrainSets, tuple, ind, trainInd);
                end  
            end         
		end
	end

end