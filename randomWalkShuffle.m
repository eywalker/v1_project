function shuffledDataSet = randomWalkShuffle(dataSet, sigma, seed)
    if nargin < 3
        seed = 'shuffle';
    end
    if nargin < 2
        binWidth = 0.5;
    end
    
    rng(seed, 'twister');
    ori = dataSet.orientation;
    [~, pos] = sort(ori);
    counts = dataSet.counts;
    walk = randn(size(counts)) * sigma;
    ori_jittered = bsxfun(@plus, ori, walk);
    [~, jpos] = sort(ori_jittered, 2);
    shuffledCounts = zeros(size(counts));
    for i = 1:size(counts,1)
        shuffledCounts(i, pos) = counts(i, jpos(i, :));
    end

    shuffledDataSet = struct(dataSet); % make explicit copy
    shuffledDataSet.counts = shuffledCounts;
end