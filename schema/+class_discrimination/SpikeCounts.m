%{
class_discrimination.SpikeCounts (computed) # Spike counts grouped by units
-> class_discrimination.SpikeCountSet
-> ephys.SpikesAligned
%}

classdef SpikeCounts < dj.Relvar 

	methods

		function makeTuples(self, key)
			keys = fetch(ephys.SpikesAligned * class_discrimination.SpikeCountSet & key);
			fprintf('%d units to populate...\n', length(keys));
			for k = keys'
				tuple = k;
				self.insert(tuple);
				makeTuples(class_discrimination.SpikeCountTrial, k);
			end
				
		end
			
	end

end
