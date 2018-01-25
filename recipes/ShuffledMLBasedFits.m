%% Make sure cd_dataset.CVParams is populated

% get all contrast sessions
parpopulate(cd_dataset.CleanContrastSessionDataSet);
% get all CVsets
parpopulate(cd_dataset.CleanCrossValidationSets);

% register CleanContrastSessions as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"');
%% register CleanCVTrainSets as LC trainset
parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.CleanCVTrainSets"');


% regiser pairing between Contrast Session decoder trainset and CV
% TrainSets as LC trainsets
% Session LC trainset
rel_train = pro(cd_decoder.DecoderTrainSets * pro(cd_dataset.CleanContrastSessionDataSet, 'dataset_hash -> dec_trainset_hash')) * ...
    pro(cd_lc.LCTrainSets *  pro(cd_dataset.CleanCVTrainSets, 'dataset_hash -> lc_trainset_hash'), 'cv_contrast -> dataset_contrast');

%registerPair(cd_lc.LCTrainSetPairs, rel_train);
%% register CVTestSets as LC testset
parpopulate(cd_lc.LCTestSets, 'lc_testset_owner = "cd_dataset.CleanCVTestSets"');


% regiser pairing between CV TrainSets as LC trainsets and CV
% TrainSets as LC testsets
rel_test = pro(cd_lc.LCTrainSets * pro(cd_dataset.CleanCVTrainSets, 'dataset_hash -> lc_trainset_hash')) * ...
    pro(cd_lc.LCTestSets * pro(cd_dataset.CleanCVTestSets, 'dataset_hash -> lc_testset_hash'));
%registerPair(cd_lc.LCTrainTestPairs, rel_test);

%% now finally get onto training decoders and then LC models

%% train all decoders
% use specialized filler table to populate decoder_id = 3 case
parpopulate(cd_decoder.MLFiller);

%% train all LC models
parpopulate(cd_shuffle.ShuffledTrainedLC, rel_train, 'lc_id in (2, 7, 25, 32, 38)', 'decoder_id = 3');

%% test trained LC on tset sets
parpopulate(cd_shuffle.ShuffledLCModelFits, rel_test);
