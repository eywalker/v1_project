function shuffledIdx = shufflePositionWithinBin(x, binWidth, seed, binCenter)
%SHUFFLELIKELIHOODWIDTHSAROUNDACTUALSTIMS Shuffle likelihood widths within
%the binned stimulus orientation

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
    binnedX = round((x-binCenter) / binWidth) * binWidth + binCenter;
    xc = sort(unique(binnedX));
    idx = 1:length(x);
    shuffledIdx = idx;
    
    for i = 1:length(xc)
        pos = find(binnedX == xc(i));
        randpos = pos(randperm(length(pos)));
        shuffledIdx(pos) = idx(randpos);
    end
    %fprintf('\n');
end