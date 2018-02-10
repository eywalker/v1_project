%{
# Shuffle configuration
lc_shuffle_id :  smallint   # unique id for shuffle param
-----
peak_extractor : varchar(255)   # name of peak extraction function
bin_width:  int     # width of bin
shuffle_seed:  int   # seed for shuffling
bin_center:  int    # center for defining bins
%}

classdef ShuffleParam < dj.Lookup
    methods
        function shuffledSet = shuffleDataSet(self, dataSet)
            assert(length(self)==1, 'Can only shuffle using one parameter at a time');
            [fName, bin_width, shuffle_seed, bin_center] = fetch1(self, 'peak_extractor', 'bin_width', 'shuffle_seed', 'bin_center');
            
            x = dataSet.decodeOri;
            L = dataSet.likelihood;
            
            if bin_width == 0 % no shuffling
                shuffledSet = dataSet;
                shuffledSet.oldLikelihood = dataSet.likelihood;
                return;
            end

            peakExtractor = eval(['@' fName]);

            v = shufflePositionWithinBin(dataSet.orientation, bin_width, shuffle_seed, bin_center);
            peak = peakExtractor(x, L);

            Lshuffled = L(:, v);
            pmoved = peak(v);

            shift = peak - pmoved;

            Lshifted = shiftFunction(x, Lshuffled, shift);
            
            shuffledSet = dataSet;
            shuffledSet.likelihood = Lshifted;
            shuffledSet.oldLikelihood = L; % keep original likelihood for later evaluation
        end
    end
end