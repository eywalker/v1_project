function shuffledPLSet = shuffleLikelihoodWidthsAroundActualStims(plSet, binWidth, seed, binCenter)
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
    binnedOri = round((plSet.orientation-binCenter) / binWidth) * binWidth + binCenter;
    ori = sort(unique(binnedOri));
    likelihoodWidths = plSet.likelihood_width;
    shuffledWidths = likelihoodWidths;
    
    for i = 1:length(ori)
        pos = find(binnedOri == ori(i));
        randpos = pos(randperm(length(pos)));
        shuffledWidths(pos) = likelihoodWidths(randpos);
    end
    %fprintf('\n');
    
    shuffledPLSet = struct(plSet); % make explicit copy
    shuffledPLSet.likelihood_width = shuffledWidths;
end