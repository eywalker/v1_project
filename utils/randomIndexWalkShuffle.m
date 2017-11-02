function shuffledDataSet = randomIndexWalkShuffle(dataSet, sigma, seed)
    % For each electrode, let the spike counts randomly "walk" along the
    % "rank" of the orientation axis. As a result, nearby orientation
    % trials have higher chances of switching position with each other.
    % Because it is the "position" within the sorted orientation that's
    % getting shuffled, orientation with large number of repeats have less
    % chance of switching to a different orientation bins. This method of
    % shuffling effectively respects the density of data by "expanding"
    % dense regions when walking. sigma is the standard deviation in units
    % of rank.
    
    if nargin < 3
        seed = 'shuffle';
    end
    if nargin < 2
        sigma = 0.5;
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