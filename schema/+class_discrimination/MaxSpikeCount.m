%{
class_discrimination.MaxSpikeCount (computed) # Maximum spike counts observed in a trial
-> class_discrimination.SpikeCountTrials
-----
max_count          :int               # maximum observed spikes counts
total_count        :int               # total spike counts
mean_count         :float             # mean spike count
%}

classdef MaxSpikeCount < dj.Relvar 

	methods

		function makeTuples(self, key)
            data = fetch1(class_discrimination.SpikeCountTrials & key, '*');
            key.max_count = max(data.counts);
            key.total_count = sum(data.counts);
            key.mean_count = mean(data.counts);
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
