%{
class_discrimination.FASpikeCountSet (computed) # Spike counts with first FA removed
-> class_discrimination.SpikeCountSet
---
spikecountset_ts=CURRENT_TIMESTAMP: timestamp# automatic timestamp. Do not edit
%}

classdef FASpikeCountSet < dj.Relvar & dj.AutoPopulate

	properties
        popRel = class_discrimination.SpikeCountSet
	end

	methods(Access=protected)

		function makeTuples(self, key)
			self.insert(key);
			makeTuples(class_discrimination.FASpikeCountTrials, key);
		end
			
	end

end
