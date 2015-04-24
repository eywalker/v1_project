%{
class_discrimination.SCGroupedShuffledDataSets (computed) # shuffled dataset grouped by stimulus and contrast
->class_discrimination.ContrastSessionDataSet
->class_discrimination.ShuffleParams
-----
shuffled_counts: longblob     # shuffled spike count set
->class_discrimination.DataSets
%}

classdef SCGroupedShuffledDataSets < dj.Relvar & dj.AutoPopulate
    properties
		popRel = pro(class_discrimination.ContrastSessionDataSet * class_discrimination.ShuffleParams);
	end

	
    methods
        function self = SCGroupedShuffledDataSets(varargin)
            self.restrict(varargin{:});
        end
        
        function dataSet = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            dataSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & pro(self));
            info = fetch(self, '*');
            dataSet.counts = info.shuffled_counts;
        end
    end
    
	methods(Access=protected)
        
		function makeTuples(self, key)
            tuple = key;
            params = fetch(class_discrimination.ShuffleParams & key, '*');
            dataSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & key);
            rng(params.shuffle_seed, 'twister');
            binWidth = params.shuffle_binwidth;
            
            binnedOri = round(dataSet.orientation / binWidth) * binWidth;
            ori = sort(unique(binnedOri));
            counts = dataSet.counts;
            shuffledCounts = counts;
            N = size(counts, 1);
            %indices = repmat(1:length(dataSet.orientation), [size(counts, 1), 1]);
            for i = 1:length(ori)
                pos = find(binnedOri == ori(i));
                for j=1:N
                    randpos = pos(randperm(length(pos)));
                    shuffledCounts(j, pos) = counts(j, randpos);
                end
            end
            %assert(all(binnedOri(indices) == binnedOri), 'Something went wrong with shuffling...');
            
            tuple.shuffled_counts = shuffledCounts;
            tuple.dataset_id = registerDataSet(class_discrimination.DataSets, self, 'Spike counts shuffled within stimulus');
            insert(self, tuple);
		end
    end

end