%% Train models on simulated behavioral data

% prepare simulated behavioral responses
parpopulate(cd_dataset.SimulatedBehavior, 'lc_trainset_owner like "cd_dataset.CleanContrastSession%"', 'lc_id in (3, 7, 27, 32)');

% prepare CV set based on SimulatedBehavior dataset
parpopulate(cd_dataset.SimBehCVSets, 'lc_trainset_owner like "cd_dataset.CleanContrastSession%"');

%%
% register Simulated CV trainset as LC trainset

parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.SimBehCVTrainSets"');

% regiser pairing between Simulated Behavior decoder trainset and Simulated Behavior LC trainset

trainsetAlias = pro(cd_dataset.SimBehCVTrainSets, 'lc_trainset_owner -> src_lc_owner', 'lc_trainset_hash -> src_lc_hash', '*');
pairing = pro(trainsetAlias, 'dataset_hash -> lc_trainset_hash', 'dataset_owner -> lc_trainset_owner');
rel_train = pro(cd_decoder.DecoderTrainSets) * pro(cd_lc.LCTrainSets) & pairing;

registerPair(cd_lc.LCTrainSetPairs, rel_train);

% register Simulated CV testset as LC testset
parpopulate(cd_lc.LCTestSets, 'lc_testset_owner = "cd_dataset.SimBehCVTestSets"');

testsetAlias = pro(cd_dataset.SimBehCVTestSets, 'lc_trainset_owner -> src_lc_owner', 'lc_trainset_hash -> src_lc_hash', '*');

% regiser pairing between simulated CV TrainSets as simulated LC trainsets and CV
% TrainSets as LC testsets
pairing = pro(trainsetAlias, 'dataset_hash -> lc_trainset_hash') * pro(testsetAlias, 'dataset_hash -> lc_testset_hash');
rel_test = pro(cd_lc.LCTrainSets) * pro(cd_lc.LCTestSets) & pairing;
registerPair(cd_lc.LCTrainTestPairs, rel_test);


%% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet" and decoder_id = 1');

%% train all LC models
parpopulate(cd_lc.TrainedLC, rel_train, 'lc_id <= 7 or lc_id >= 24');

%% test trained LC on tset sets
parpopulate(cd_lc.LCModelFits, rel_test);
