keys = fetch(cd_simulated.TrainedLC & 'decoder_id = 4' & 'lc_shuffle_id = 0');
[trainSet, testSet, dec, model] = getAll(cd_dlset.LCModelFits & keys(1));

%%
simTrain = model.simulateDataset(trainSet);

newModel = getLC(cd_lc.LCModels & 'lc_id = 32');
newModel2 = getLC(cd_lc.LCModels & 'lc_id = 38');

newModel.train(simTrain);
newModel2.train(simTrain);

model.getLogLikelihood(simTrain)
newModel.getLogLikelihood(simTrain)
newModel2.getLogLikelihood(simTrain)

%%
simTest = model.simulateDataset(testSet);

model.getLogLikelihood(simTest)
newModel.getLogLikelihood(simTest)
newModel2.getLogLikelihood(simTest)