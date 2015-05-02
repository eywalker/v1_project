function shuffledDataSet = shuffleLikelihoodWidthsAroundActualStim(dataSet, binWidth, seed, binCenter)
    if nargin < 4
        binCenter = 0;
    end
    if nargin < 3
        seed = 'shuffle';
    end
    if nargin < 2
        binWidth = 3;
    end
    
    rng(seed, 'twister');
    binnedOri = round((dataSet.orientation-binCenter) / binWidth) * binWidth + binCenter;
    ori = sort(unique(binnedOri));
    counts = dataSet.counts;
    shuffledCounts = counts;
    N = size(counts, 1); % number of neurons

    for i = 1:length(ori)
        pos = find(binnedOri == ori(i));
        %fprintf('%d,',length(pos));
        for j=1:N
            randpos = pos(randperm(length(pos)));
            shuffledCounts(j, pos) = counts(j, randpos);
        end
    end
    %fprintf('\n');
    
    shuffledDataSet = struct(dataSet); % make explicit copy
    shuffledDataSet.counts = shuffledCounts;
end