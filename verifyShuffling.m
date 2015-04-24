keys = fetch(class_discrimination.ContrastSessionDataSet);
for j=1:length(keys)
    key = keys(j);
%key = keys(34);
params = fetch(class_discrimination.ShuffleParams);
param = params(2);
binwidth = param.shuffle_binwidth;
original = fetchDataSet(class_discrimination.ContrastSessionDataSet & key);
shuffled = fetchDataSet(class_discrimination.SCGroupedShuffledDataSets & key & param);

original_counts = original.counts;
shuffled_counts = shuffled.counts;

orientation = [original.orientation];
orid = round(orientation / binwidth) * binwidth;

unique_ori = unique(orid);
assert(~all(original_counts(:) == shuffled_counts(:)), 'Should be true...');

for i = 1:length(unique_ori)
    ori_value = unique_ori(i);
    pos = orid == ori_value;
    assert(all(mean(original_counts(:, pos), 2) == mean(shuffled_counts(:, pos), 2)), 'Should be true...')
end
fprintf('All passed...!\n');
end