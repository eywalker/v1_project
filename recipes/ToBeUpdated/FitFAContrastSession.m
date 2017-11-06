%% Make sure cd_dataset.ShuffleParams is populated

% get all contrast sessions
parpopulate(cd_dataset.FAContrastSessionDataSet);

% register ContrastSessions as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.FAContrastSessionDataSet"');

% register ContrastSessions as LC trainset
parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.FAContrastSessionDataSet"');

% regiser pairing between Contrast Session decoder trainset and Contrast
% Session LC trainset
rel = pro(cd_decoder.DecoderTrainSets * cd_dataset.FAContrastSessionDataSet) * ...
    pro(cd_lc.LCTrainSets * cd_dataset.FAContrastSessionDataSet);
registerPair(cd_lc.LCTrainSetPairs, rel);

% now finally get onto training decoders and then LC models

% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.FAContrastSessionDataSet"');
%%
% train all LC models
parpopulate(cd_lc.TrainedLC, rel);
