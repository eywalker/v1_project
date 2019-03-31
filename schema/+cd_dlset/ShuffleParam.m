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
            [shuffleID, fName, bin_width, shuffle_seed, bin_center] = fetch1(self, 'lc_shuffle_id', 'peak_extractor', 'bin_width', 'shuffle_seed', 'bin_center');
            
            x = dataSet.decodeOri;
            L = dataSet.likelihood;
            
            peakExtractor = eval(['@' fName]);
            peak = peakExtractor(x, L);

            
            if bin_width == 0 % no shuffling
                shuffledSet = dataSet;
                [~, pos] = sort(dataSet.orientation);
                [~, ranking] = sort(pos);
                shuffledSet.orientationBin = ranking;
                shuffledSet.originalPeaks = peak;
                shuffledSet.shiftedPeaks = peak;
                shuffledSet.oldLikelihood = dataSet.likelihood;
                return;
            end


            [v, oriBin] = shufflePositionWithinBin(dataSet.orientation, bin_width, shuffle_seed, bin_center);

            Lshuffled = L(:, v);
            pmoved = peak(v);

            shift = peak - pmoved;

            if shuffleID >= 0
                Lshifted = shiftFunction(x, Lshuffled, shift);
            else
                % handle -1 case specially - shuffling the posterior
                Lshifted = shiftUntilTarget(x, Lshuffled, shift);
            end
            
            shiftedPeaks = peakExtractor(x, Lshifted);

            shuffledSet = dataSet;
            shuffledSet.likelihood = Lshifted;
            shuffledSet.orientationBin = oriBin;
            shuffledSet.originalPeaks = peak;
            shuffledSet.shiftedPeaks = shiftedPeaks;
            shuffledSet.oldLikelihood = L; % keep original likelihood for later evaluation
        end
    end
end