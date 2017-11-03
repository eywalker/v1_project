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
rel_train = pro(cd_decoder.DecoderTrainSets * cd_dataset.CleanContrastSessionDataSet) * ...
    pro(cd_lc.LCTrainSets * cd_dataset.CleanCVTrainSets, 'cv_contrast -> dataset_contrast');

registerPair(cd_lc.LCTrainSetPairs, rel_train);
%% register CVTestSets as LC testset
parpopulate(cd_lc.LCTestSets, 'lc_testset_owner = "cd_dataset.CleanCVTestSets"');


% regiser pairing between CV TrainSets as LC trainsets and CV
% TrainSets as LC testsets
rel_test = pro(cd_lc.LCTrainSets * cd_dataset.CleanCVTrainSets) * ...
    pro(cd_lc.LCTestSets * cd_dataset.CleanCVTestSets);
registerPair(cd_lc.LCTrainTestPairs, rel_test);

%% now finally get onto training decoders and then LC models

%% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet" and decoder_id = 1');

%% train all LC models
parpopulate(cd_lc.TrainedLC, rel_train, 'lc_id <= 7');

%% test trained LC on tset sets
parpopulate(cd_lc.LCModelFits, rel_test);
