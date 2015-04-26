function shuffledDataSet = randomIndexWalkShuffle(dataSet, sigma, seed)
    if nargin < 3
        seed = 'shuffle';
    end
    if nargin < 2
        binWidth = 0.5;
    end
    
    rng(seed, 'twister');
    ori = dataSet.orientation;
    [~, pos] = sort(ori);
    [~, rank] = sort(pos);
    counts = dataSet.counts;
    walk = randn(size(counts)) * sigma;
    rank_jittered = bsxfun(@plus, rank, walk);
    [~, jpos] = sort(rank_jittered, 2);
    shuffledCounts = zeros(size(counts));
    for i = 1:size(counts,1)
        shuffledCounts(i, pos) = counts(i, jpos(i, :));
    end

    shuffledDataSet = struct(dataSet); % make explicit copy
    shuffledDataSet.counts = shuffledCounts;
%     figure;
%     subplot(211);
%     plot(rank(pos), rank(jpos(1,:)), 'ro');
%     subplot(212);
%     plot(ori(pos), ori(jpos(1,:)), 'ro');
end