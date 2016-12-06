%{
class_discrimination.SpikeCountStats (computed) # Statistics on spike counts observed in a trial
-> class_discrimination.SpikeCountTrials
-----
max_count          :int               # maximum observed spike count
min_count          :int               # minimum observed spike count
total_count        :int               # total spike count
mean_count         :float             # mean spike count
median_count       :float             # median spike count
%}

classdef SpikeCountStats < dj.Relvar & dj.AutoPopulate
     methods
        function self = SpikeCountStats(varargin)
            self.restrict(varargin{:});
        end
     end
        

	methods(Access=protected)
		function makeTuples(self, key)
            data = fetch(class_discrimination.SpikeCountTrials & key, '*');
            key.max_count = max(data.counts);
            key.min_count = min(data.counts);
            key.total_count = sum(data.counts);
            key.mean_count = mean(data.counts);
            key.median_count = median(data.counts);
            insert(self, tuple);
        end
	end

end
