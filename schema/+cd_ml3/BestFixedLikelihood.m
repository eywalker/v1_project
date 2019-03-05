%{
# 
-> cd_ml3.CVTrainedFixedLikelihood
 (selection_objective) -> cd_ml3.EvalObjective
---
selected_train_loss         : float                         # score on train set
selected_valid_loss         : float                         # score on test set
model                       : longblob                      # saved model state
%}


classdef BestFixedLikelihood < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			 self.insert(key)
		end
	end

end