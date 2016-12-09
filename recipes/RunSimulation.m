%% Make sure cd_dataset.ShuffleParams is populated

% prepare simulated responses
parpopulate(cd_dataset.SimulatedResponses);

% register SimlatedResponses as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.SimulatedResponses"');

% register SimulatedResponses as LC trainset
parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.SimulatedResponses"');

% regiser pairing between Simulated Responses decoder trainset and
% Simulated Responses LC trainset
dataset = cd_dataset.DataSets & cd_dataset.SimulatedResponses;
rel = pro(cd_decoder.DecoderTrainSets * dataset) * ...
    pro(cd_lc.LCTrainSets * dataset);
registerPair(cd_lc.LCTrainSetPairs, rel);

% now finally get onto training decoders and then LC models
% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.SimulatedResponses"');

% train all LC models
parpopulate(cd_lc.TrainedLC, rel, 'lc_id between 1 and 7');
