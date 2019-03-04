%{
# 
-> cd_ml3.CVTrainedModel
---
train_loss                  : float                         # score on train set
valid_loss                  : float                         # score on test set
avg_sigma                   : float                         # average width of the likelihood functions
model                       : longblob                      # saved model state
%}


classdef BestNonlin < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			 self.insert(key)
		end
	end

end