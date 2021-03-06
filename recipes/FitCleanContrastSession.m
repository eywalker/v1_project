%% Make sure cd_dataset.ShuffleParams is populated

% get all contrast sessions
parpopulate(cd_dataset.CleanContrastSessionDataSet);

% register ContrastSessions as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"');

% register ContrastSessions as LC trainset
parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"');

% regiser pairing between Contrast Session decoder trainset and Contrast
% Session LC trainset
rel = pro(cd_decoder.DecoderTrainSets * pro(cd_dataset.CleanContrastSessionDataSet, 'dataset_hash -> dec_trainset_hash')) * ...
    pro(cd_lc.LCTrainSets * pro(cd_dataset.CleanContrastSessionDataSet, 'dataset_hash -> lc_trainset_hash'));
registerPair(cd_lc.LCTrainSetPairs, rel);

% now finally get onto training decoders and then LC models

% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet" and decoder_id = 1');
%
% train all LC models
parpopulate(cd_lc.TrainedLC, rel, 'lc_id <=7 or lc_id >= 24');
