%{
cd_analysis.BinaryReadout (computed) # analysis of binary classification
-> cd_lc.TrainedLC
-----
model_choice: longblob           # binary readout of a trial from the model
model_correct: longblob          # indicates whether model choice was correct
prop_correct: float              # proportion of correct trials
%}

classdef BinaryReadout < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(cd_lc.TrainedLC)
	end

	methods(Access=protected)

		function makeTuples(self, key)
            dataSet = getDataSet(cd_lc.TrainedLC & key);
            model = getLC(cd_lc.TrainedLC & key);
            modelChoice = model.pRespA(dataSet) > 0.5;
            actualChoice = strcmp(dataSet.selected_class, 'A');
            correctChoice = modelChoice == actualChoice';
            pCorrect = mean(correctChoice);
            
            key.model_choice = modelChoice;
            key.model_correct = correctChoice;
            key.prop_correct = pCorrect;
			self.insert(key)
		end
	end

end