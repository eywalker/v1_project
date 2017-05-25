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

% register both contrast sessions and shuffled PLsets as the trainset for PLC
parpopulate(cd_plc.PLCTrainSets, 'plc_trainset_owner = "cd_plset.ContrastSessionPLSet"');
parpopulate(cd_plc.PLCTrainSets, 'plc_trainset_owner = "cd_plset.ShuffledPLSets"');


parpopulate(cd_plc.TrainedPLC, 'plc_trainset_owner = "cd_plset.ContrastSessionPLSet"');
parpopulate(cd_plc.TrainedPLC, 'plc_trainset_owner = "cd_plset.ShuffledPLSets"');


% register shuffled sets as testset
parpopulate(cd_plc.PLCTestSets, 'plc_trainset_owner = "cd_plset.ShuffledPLSets"');

% register pairing between contrast sessions as trainset and shuffled data
% as testset
pairs = fetch(pro(cd_plset.ShuffledPLSets, 'source_plset_hash -> plc_trainset_hash', 'source_plset_owner -> plc_trainset_owner', 'plset_owner -> plc_testset_owner', 'plset_hash -> plc_testset_hash'), '*');
registerPair(cd_plc.PLCTrainTestPairs, pairs);

% test the fits
parpopulate(cd_plc.PLCTestFits, 'plc_id <=3');