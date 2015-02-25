%{
class_discrimination.SpikeCountSet (computed) # my newest table
-> class_discrimination.ClassDiscriminationExperiment
-> ephys.SpikesAlignedSet
-> class_discrimination.SpikeCountParams
---
spikecountset_ts=CURRENT_TIMESTAMP: timestamp# automatic timestamp. Do not edit
%}

classdef SpikeCountSet < dj.Relvar & dj.AutoPopulate

	properties
		popRel = (ephys.SpikesAlignedSet & class_discrimination.ClassDiscriminationExperiment) * class_discrimination.SpikeCountParams;
	end

	methods(Access=protected)

		function makeTuples(self, key)
			self.insert(key);
			makeTuples(class_discrimination.SpikeCountTrials, key);
		end
			
	end

end
