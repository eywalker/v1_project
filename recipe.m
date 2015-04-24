parpopulate(class_discrimination.ContrastSessionDataSet);
parpopulate(class_discrimination.DecoderTrainSets, pro(class_discrimination.ContrastSessionDataSet, 'dataset_id -> decoder_trainset_id'));

parpopulate(class_discrimination.TrainedDecoder);


% set up CV sets
parpopulate(class_discrimination.CrossValidationSets);

trainSetPairs = pro(class_discrimination.ContrastSessionDataSet, 'dataset_id -> decoder_trainset_id', 'dataset_contrast -> contrast') * ...
    pro(class_discrimination.CVTrainSets, 'dataset_id -> lc_trainset_id', 'cv_contrast -> contrast');
missing = fetch(trainSetPairs - class_discrimination.LCTrainSetPairs, '*');
for i = 1:length(missing)
    registerPair(class_discrimination.LCTrainSetPairs, missing(i).decoder_trainset_id, missing(i).lc_trainset_id);
end

parpopulate(class_discrimination.TrainedLikelihoodClassifiers, trainSetPairs);

trainTestPairs = pro(class_discrimination.CVTrainSets, 'dataset_id -> lc_trainset_id') * ...
    pro(class_discrimination.CVTestSets, 'dataset_id -> lc_testset_id');
missing = fetch(trainTestPairs - class_discrimination.LCTrainTestPairs, '*');
for i = 1:length(missing)
    registerPair(class_discrimination.LCTrainTestPairs, missing(i).lc_trainset_id, missing(i).lc_testset_id);
end
parpopulate(class_discrimination.LCModelFits, trainTestPairs);


% parameterized lkelihood models
parpopulate(class_discrimination.ContrastSessionParameterizedLikelihoods);
parpopulate(class_discrimination.ShuffledCSPL);
parpopulate(class_discrimination.PLCTrainSets, ...
    pro(class_discrimination.ContrastSessionParameterizedLikelihoods, 'plset_id -> plc_trainset_id'));
parpopulate(class_discrimination.PLCTestSets, ...
    pro(class_discrimination.ShuffledCSPL, 'plset_id -> plc_testset_id'));
parpopulate(class_discrimination.PLCTrainSets, ...
    pro(class_discrimination.ShuffledCSPL, 'plset_id -> plc_trainset_id'));
parpopulate(class_discrimination.PLCTestSets, ...
    pro(class_discrimination.ContrastSessionParameterizedLikelihoods, 'plset_id -> plc_testset_id'));
parpopulate(class_discrimination.TrainedPLC);

% non-shuffled -> shuffle
plcTrainTestPairs = pro(class_discrimination.ContrastSessionParameterizedLikelihoods, 'plset_id -> plc_trainset_id') * ...
    pro(class_discrimination.ShuffledCSPL, 'plset_id -> plc_testset_id');
missing = fetch(plcTrainTestPairs - class_discrimination.PLCTrainTestPairs, '*');
for i = 1:length(missing)
    registerPair(class_discrimination.PLCTrainTestPairs, missing(i).plc_trainset_id, missing(i).plc_testset_id);
end

% shuffle -> non-shuffled
plcTrainTestPairs = pro(class_discrimination.ContrastSessionParameterizedLikelihoods, 'plset_id -> plc_testset_id') * ...
    pro(class_discrimination.ShuffledCSPL, 'plset_id -> plc_trainset_id');
missing = fetch(plcTrainTestPairs - class_discrimination.PLCTrainTestPairs, '*');
for i = 1:length(missing)
    registerPair(class_discrimination.PLCTrainTestPairs, missing(i).plc_trainset_id, missing(i).plc_testset_id);
end

parpopulate(class_discrimination.PLCTestFits);