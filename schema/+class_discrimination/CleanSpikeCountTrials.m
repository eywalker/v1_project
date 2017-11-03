%{
class_discrimination.CleanSpikeCountTrials (computed)  # Cleaned up spike counts trials
-> class_discrimination.CleanSpikeCountSet
-> class_discrimination.SpikeCountTrials
%}

classdef CleanSpikeCountTrials < dj.Relvar
    methods
        function makeTuples(self, keys)
            insert(self, keys);
        end
    end

end
