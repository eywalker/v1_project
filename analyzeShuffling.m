keys = fetch(class_discrimination.ContrastSessionDataSet);

n = 9;
shuffle_condition = fetch(class_discrimination.ShuffleParams('shuffle_binwidth = 3'));
assert(length(key)==1, 'Should only look at one shuffling condition at a time')


dataSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & keys(n));
dataSet_shuffle = fetchDataSet(class_discrimination.SCGroupedShuffledDataSets & keys(n) & shuffle_condition);

decoder = getDecoder(class_discrimination.TrainedDecoder & pro(class_discrimination.ContrastSessionDataSet & keys(n), 'dataset_id -> decoder_trainset_id'));

s = dataSet.orientation;
assert(all(dataSet.orientation==dataSet_shuffle.orientation), 'Original and shuffled dataset are not in agreement!');
decodeOri = linspace(220, 320, 1000);

L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
L_shuffle = decoder.getLikelihoodDistr(decodeOri, dataSet_shuffle.contrast, dataSet_shuffle.counts);

[s_hat, width] = ClassifierModel.getMeanStd(decodeOri, L);
[s_hat_shuffle, width_shuffle] = ClassifierModel.getMeanStd(decodeOri, L_shuffle);

var_s = var(s_hat - s);
var_s_shuffle = var(s_hat_shuffle - s);
contrast = str2num(keys(n).dataset_contrast);
fprintf('Stimulus error: original=%f, shuffled=%f\n', var_s, var_s_shuffle);

dataSet.likelihood = L;
dataSet.decodeOri = decodeOri;

dataSet_shuffle.likelihood = L_shuffle;
dataSet_shuffle.decodeOri = decodeOri;

