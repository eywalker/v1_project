% Verifies that the shuffleSpikes based shuffling of spike data works by
% fetching shuffled dataset and checking them against the original
% (unshuffled) dataset.

keys = fetch(cd_dataset.SCGroupedShuffledDataSets & 'shuffle_method = "shuffleSpikes"');

for j=1:length(keys)
    fprintf('Working on %d / %d...\n', j, length(keys));
    key = keys(j);
    %key = keys(34);
    param = fetch(cd_dataset.ShuffleParams & key);
    binwidth = param.shuffle_binwidth;
    bincenter = 0;
    original = fetchDataSet(cd_dataset.ContrastSessionDataSet & key);
    shuffled = fetchDataSet(cd_dataset.SCGroupedShuffledDataSets & key);

    original_counts = original.counts;
    shuffled_counts = shuffled.counts;

    orientation = [original.orientation];
    orid = round((orientation - bincenter) / binwidth) * binwidth + bincenter;

    unique_ori = unique(orid);
    assert(~all(original_counts(:) == shuffled_counts(:)), 'Should be true...');

    for i = 1:length(unique_ori)
        ori_value = unique_ori(i);
        fprintf('Checking ori=%d...\n', ori_value);
        pos = orid == ori_value;
        assert(all(mean(original_counts(:, pos), 2) == mean(shuffled_counts(:, pos), 2)), 'Should be true...')
    end
fprintf('All passed...!\n');
end