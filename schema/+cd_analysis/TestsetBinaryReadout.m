%{
cd_analysis.TestsetBinaryReadout (computed) # analysis of binary classification on a testset
-> cd_lc.LCModelFits
---
model_choice                : longblob                      # binary readout of a trial from the model
model_correct               : longblob                      # indicates whether model choice was correct
num_trials                  : int                           # number of trials
prop_correct                : float                         # proportion of correct trials
%}


classdef TestsetBinaryReadout < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(cd_lc.LCModelFits)  % !!! update the populate relation
	end

	methods(Access=protected)

		function makeTuples(self, key)
            [trainset, testset, decoder, model] = getAll(cd_lc.LCModelFits & key);
            modelChoice = model.pRespA(testset) > 0.5;
            actualChoice = strcmp(dataSet.selected_class, 'A');
            correctChoice = modelChoice == actualChoice';
            pCorrect = mean(correctChoice);
            
            key.model_choice = modelChoice;
            key.model_correct = correctChoice;
            key.prop_correct = pCorrect;
            key.num_trials = length(correctChoice);
			self.insert(key)
		end
	end

end