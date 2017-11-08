%% Make sure cd_plc.PLShuffleParams is populated

% get all contrast sessions
parpopulate(cd_dataset.CleanContrastSessionDataSet);


% register ContrastSessions as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"');

% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"', 'decoder_id = 1');


% parameterize all contrast session sets
parpopulate(cd_plset.CleanContrastSessionPLSet);

% shuffle up all contrast session sets
rel = pro(cd_plset.CleanContrastSessionPLSet, 'plset_owner -> source_plset_owner', 'plset_hash -> source_plset_hash');

parpopulate(cd_plset.ShuffledPLSets, rel);
restr = cd_plset.PLSets & (cd_plset.ShuffledPLSets & rel);
%%
% register both contrast sessions and shuffled PLsets as the trainset for PLC
parpopulate(cd_plc.PLCTrainSets, 'plc_trainset_owner = "cd_plset.CleanContrastSessionPLSet"');
parpopulate(cd_plc.PLCTrainSets, 'plc_trainset_owner = "cd_plset.ShuffledPLSets"', restr);

%%
parpopulate(cd_plc.TrainedPLC, 'plc_trainset_owner = "cd_plset.CleanContrastSessionPLSet"', 'plc_id <=2');
parpopulate(cd_plc.TrainedPLC, 'plc_trainset_owner = "cd_plset.ShuffledPLSets"', 'plc_id <= 2', pro(cd_plc.PLCTrainSets & restr));

%%
% register shuffled sets as testset
parpopulate(cd_plc.PLCTestSets, 'plc_testset_owner = "cd_plset.ShuffledPLSets"', restr);

% register pairing between contrast sessions as trainset and shuffled data
% as testset
pairs = pro(cd_plc.PLCTrainSets) * pro(cd_plc.PLCTestSets) * pro(cd_plset.ShuffledPLSets & rel, 'source_plset_hash -> plc_trainset_hash', 'source_plset_owner -> plc_trainset_owner', 'plset_owner -> plc_testset_owner', 'plset_hash -> plc_testset_hash') ;
registerPair(cd_plc.PLCTrainTestPairs, pairs);

% test the fits
parpopulate(cd_plc.PLCTestFits, 'plc_id <=2');
