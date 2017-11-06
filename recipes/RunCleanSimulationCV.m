%% Train models on simulated behavioral data

% prepare simulated behavioral responses
parpopulate(cd_dataset.SimulatedBehavior);

% prepare CV set based on SimulatedBehavior dataset
populate(cd_dataset.SimBehCVSets);

% register SimlatedResponses as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.SimulatedBehavior"');

% register SimulatedBehavior as LC trainset
parpopulate(cd_lc.LCTrainSets, 'lc_trainset_owner = "cd_dataset.SimulatedBehavior"');

% regiser pairing between Simulated Behavior decoder trainset and
% Simulated Behavior LC trainset
dataset = cd_dataset.DataSets & cd_dataset.SimulatedBehavior;
rel = pro(cd_decoder.DecoderTrainSets * dataset) * ...
    pro(cd_lc.LCTrainSets * dataset);
registerPair(cd_lc.LCTrainSetPairs, rel);

% now finally get onto training decoders and then LC models
% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.SimulatedBehavior"');

% train all LC models
parpopulate(cd_lc.TrainedLC, rel, 'lc_id in (3, 7)');

parpopulate(cd_lc.TrainedLC, rel, 'lc_id between 1 and 7');
