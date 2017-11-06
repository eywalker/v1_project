%% Make sure cd_dataset.CVParams is populated

% get all contrast sessions
parpopulate(cd_dataset.FAContrastSessionDataSet);
% get all CVsets
parpopulate(cd_dataset.FACrossValidationSets);

% register FAContrastSessions as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.FAContrastSessionDataSet"');
%% register FACVTrainSets as LC trainset
parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.FACVTrainSets"');


% regiser pairing between Contrast Session decoder trainset and CV
% TrainSets as LC trainsets
% Session LC trainset
rel_train = pro(cd_decoder.DecoderTrainSets * cd_dataset.FAContrastSessionDataSet) * ...
    pro(cd_lc.LCTrainSets * cd_dataset.FACVTrainSets, 'cv_contrast -> dataset_contrast');

registerPair(cd_lc.LCTrainSetPairs, rel_train);
%% register CVTestSets as LC testset
parpopulate(cd_lc.LCTestSets, 'lc_testset_owner = "cd_dataset.FACVTestSets"');


% regiser pairing between CV TrainSets as LC trainsets and CV
% TrainSets as LC testsets
rel_test = pro(cd_lc.LCTrainSets * cd_dataset.FACVTrainSets) * ...
    pro(cd_lc.LCTestSets * cd_dataset.FACVTestSets);
registerPair(cd_lc.LCTrainTestPairs, rel_test);

%% now finally get onto training decoders and then LC models

%% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.FAContrastSessionDataSet" and decoder_id = 1');

%% train all LC models
parpopulate(cd_lc.TrainedLC, rel_train, 'lc_id <= 7');

%% test trained LC on tset sets
parpopulate(cd_lc.LCModelFits, rel_test);
