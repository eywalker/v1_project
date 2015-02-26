%{
class_discrimination.SpikeCountTrials (computed) # Spike counts grouped by units
-> class_discrimination.SpikeCountSet
-> class_discrimination.ClassDiscriminationTrial
-----
counts          :longblob               # population spikes counts
n               :int                    # size of the population
%}

classdef SpikeCountTrials < dj.Relvar 

	methods

		function makeTuples(self, key)
            keys = fetch(class_discrimination.ClassDiscriminationTrial * class_discrimination.SpikeCountSet & key);
			fprintf('%d trials to populate\n', length(keys));
            step = 0;
			for k = keys'
				tuple = k;
                data = fetch(ephys.SpikesAlignedTrial & k, 'spikes_aligned');
                data = dj.struct.sort(data, 'unit_id'); % sort by unit_id to be sure about the order
                tuple.counts = arrayfun(@(x) sum(x.spikes_aligned > k.count_start & x.spikes_aligned < k.count_stop), data);
                tuple.n = length(tuple.counts);
                insert(self, tuple);
                
                if mod(step, 10)==0
                    fprintf('.');
                end
                step = step + 1;
            end
            fprintf('\n');
				
		end
			
	end

end
