keys = fetch(class_discrimination.ContrastSessionDataSet);

n = 4;
shuffle_condition = fetch(class_discrimination.ShuffleParams('shuffle_binwidth = 3'));
assert(length(key)==1, 'Should only look at one shuffling condition at a time')


dataSet = fetchDataSet(class_discrimination.ContrastSessionDataSet & keys(n));
dataSet_shuffle = shuffleSpikes(dataSet, 3);
%dataSet_shuffle = randomWalkShuffle(dataSet, 5, 319);
%dataSet_shuffle = randomIndexWalkShuffle(dataSet, 3);
decoder = getDecoder(class_discrimination.TrainedDecoder & pro(class_discrimination.ContrastSessionDataSet & keys(n), 'dataset_id -> decoder_trainset_id'));
decoder.train(dataSet);

s = dataSet.orientation;
assert(all(dataSet.orientation==dataSet_shuffle.orientation), 'Original and shuffled dataset are not in agreement!');
decodeOri = linspace(220, 320, 1000);

L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);

%decoder.train(dataSet_shuffle);
L_shuffle = decoder.getLikelihoodDistr(decodeOri, dataSet_shuffle.contrast, dataSet_shuffle.counts);

[s_hat, width] = ClassifierModel.getMeanStd(decodeOri, L);
[s_hat_shuffle, width_shuffle] = ClassifierModel.getMeanStd(decodeOri, L_shuffle);

var_s = std(s_hat - s);
mu_width = mean(width);
var_s_shuffle = std(s_hat_shuffle - s);
mu_width_shuffle = mean(width_shuffle);
contrast = str2num(keys(n).dataset_contrast);
fprintf('Contrast = %f, Stimulus error: original=%f, shuffled=%f\n', contrast, var_s, var_s_shuffle);
fprintf('Mean likelihood width: original=%f, shuffled=%f\n', mu_width, mu_width_shuffle);


dataSet.likelihood = L;
dataSet.decodeOri = decodeOri;

dataSet_shuffle.likelihood = L_shuffle;
dataSet_shuffle.decodeOri = decodeOri;

model.train(dataSet, 10);
fprintf('tested on shuffle = %f\n', model.getLogLikelihood(dataSet_shuffle));
model.train(dataSet_shuffle, 10);