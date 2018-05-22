%{
# 
-> cd_ml.CVSet
-> cd_ml.BinConfig
-> cd_ml.ModelDesign
-> cd_ml.TrainParam
-> cd_ml.TrainSeed
---
cnn_train_score             : float                         # score on train set
cnn_valid_score             : float                         # score on test set
avg_sigma                   : float                         # average width of the likelihood functions
model                       : longblob                      # trained model
%}


classdef BestModelByBin < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			 self.insert(key)
		end
	end

end