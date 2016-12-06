key = fetch(cd_lc.TrainedLC, 'LIMIT 1');
[dataset, decoder, model] = getAll(cd_lc.TrainedLC & key);
%%
rng(100, 'twister');
dataset.counts = decoder.encode(dataset.orientation, dataset.contrast);
dataset.likelihood = decoder.getLikelihoodDistr(dataset.decodeOri, dataset.contrast, dataset.counts);

dataset.goodUnits = decoder.unitFilter(:);
dataset.totalCounts = sum(dataset.counts, 1);
dataset.goodTotalCounts = dataset.goodUnits' * dataset.counts;

resp=model.classifyLikelihood(dataset);
dataset.selected_class = resp';

dataset.correct_response=strcmp(dataset.selected_class, dataset.stimulus_class);

isLeft = strcmp(dataset.correct_direction, 'Left');
choseLeft = dataset.correct_response == isLeft; % using notXOR trick to flip boolean if correct_response is false
[dataset.selected_direction{choseLeft}] = deal('Left');
[dataset.selected_direction{~choseLeft}] = deal('Right');