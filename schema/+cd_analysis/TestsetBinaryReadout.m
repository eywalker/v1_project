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
		popRel = cd_lc.LCModelFits  % !!! update the populate relation
	end

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			self.insert(key)
		end
	end

end