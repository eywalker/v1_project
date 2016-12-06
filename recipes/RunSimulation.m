%% Make sure cd_dataset.ShuffleParams is populated

% prepare simulated responses
parpopulate(cd_dataset.SimulatedResponses);

% register SimlatedResponses as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.SimulatedResponses"');

% register SimulatedResponses as LC trainset
parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.SimulatedResponses"');

% regiser pairing between Simulated Responses decoder trainset and
% Simulated Responses LC trainset
rel = pro(cd_decoder.DecoderTrainSets * cd_dataset.SimulatedResponses) * ...
    pro(cd_lc.LCTrainSets * cd_dataset.SimulatedResponses);
registerPair(cd_lc.LCTrainSetPairs, rel);

% now finally get onto training decoders and then LC models
% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.SimulatedResponses"');

% train all LC models
parpopulate(cd_lc.TrainedLC, rel, 'lc_id in (1,2,3,7)');
