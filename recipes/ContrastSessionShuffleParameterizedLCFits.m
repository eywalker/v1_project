%% Make sure cd_plc.PLShuffleParams is populated

% get all contrast sessions
parpopulate(cd_dataset.ContrastSessionDataSet);
% register ContrastSessions as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.ContrastSessionDataSet"');
% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.ContrastSessionDataSet"');


% parameterize all contrast session sets
parpopulate(cd_plset.ContrastSessionPLSet);

% shuffle up all contrast session sets
rel = pro(cd_plset.ContrastSessionPLSet, 'plset_owner -> source_plset_owner', 'plset_hash -> source_plset_hash');
parpopulate(cd_plset.ShuffledPLSets, rel);

% register both contrast sessions and PLsets as the trainset for PLC
parpopulate(cd_plc.PLCTrainSets, 'plc_trainset_owner = "cd_plset.ContrastSessionPLSet"');
parpopulate(cd_plc.PLCTrainSets, 'plc_trainset_owner = "cd_plset.ShuffledPLSets"');


parpopulate(cd_plc.TrainedPLC, 'plc_trainset_owner = "cd_plset.ContrastSessionPLSet"');
parpopulate(cd_plc.TrainedPLC, 'plc_trainset_owner = "cd_plset.ShuffledPLSets"');