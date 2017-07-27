%{
class_discrimination.FASpikeCountTrials (computed) # Spike counts with first factor removed
-> class_discrimination.FASpikeCountSet
-> class_discrimination.SpikeCountTrials
-----
counts          :longblob               # population spikes counts
n               :int                    # size of the population
adjusted        :bool                   # whether any adjustment was required during FA
%}

classdef FASpikeCountTrials < dj.Relvar 

	methods

		function makeTuples(self, key)
            data = fetch(class_discrimination.SpikeCountTrials * class_discrimination.ClassDiscriminationTrial & key, '*');
            fprintf('Performing FA and removing first factor...\n');
            [adj_counts, corrected] = spikeFA(data);
            ns = [data.n];
            trials = [data.trial_num];
            for i=1:length(trials)
                tuple = key;
                tuple.trial_num = trials(i);
                tuple.n = ns(i);
                tuple.counts = adj_counts(:, i);
                tuple.adjusted = corrected(i);
                
                insert(self, tuple);
                
                if mod(i, 10)==0
                    fprintf('.')
                end
            end
            fprintf('\n');
		end
			
	end

end
