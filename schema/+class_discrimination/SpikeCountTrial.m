%{
class_discrimination.SpikeCountTrial (computed) # my newest table
-> class_discrimination.ClassDiscriminationTrial
-> class_discrimination.SpikeCounts
-> ephys.SpikesAlignedTrial
-----
counts 	: int		# spikes counts in a trial
rate 	: float		# spike rate in Hz
%}

classdef SpikeCountTrial < dj.Relvar
	methods
		function makeTuples(self, key)
			keys = fetch(ephys.SpikesAlignedTrial * class_discrimination.SpikeCounts & class_discrimination.ClassDiscriminationTrial & key);
			fprintf('%d trials for unit %d', length(keys), key.unit_id);
			for k = keys'
				fprintf('.');
				tuple = k;
				data = fetch(ephys.SpikesAlignedTrial & k, 'spikes_aligned');
				tuple.counts = sum(data.spikes_aligned > 0 & data.spikes_aligned < 500);
				tuple.rate = tuple.counts / (500/1000);
				self.insert(tuple);
			end
		end
	end

end
