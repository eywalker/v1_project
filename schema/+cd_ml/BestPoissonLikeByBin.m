%{
# 
-> cd_ml.CVSet
-> cd_ml.BinConfig
---
-> cd_ml.PoissonLikeModelDesign
-> cd_ml.PoissonLikeTrainParam
-> cd_ml.TrainSeed
cnn_train_score             : float                         # score on train set
cnn_valid_score             : float                         # score on test set
avg_sigma                   : float                         # average width of the likelihood functions
model_saved                 : tinyint                       # whether model was saved
model                       : longblob                      # saved model
%}


classdef BestPoissonLikeByBin < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			 self.insert(key)
		end
	end

end