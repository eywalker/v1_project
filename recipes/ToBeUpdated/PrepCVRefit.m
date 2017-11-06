rel_train = pro(cd_decoder.DecoderTrainSets * cd_dataset.ContrastSessionDataSet) * ...
    pro(cd_lc.LCTrainSets * cd_dataset.CVTrainSets, 'cv_contrast -> dataset_contrast');
%%

conditions = cd_lc.TrainedLC & 'lc_trainset_owner = "cd_dataset.CVTrainSets"';
del(cd_lc.PrevFitLC & conditions);
populate(cd_lc.PrevFitLC, 'lc_trainset_owner = "cd_dataset.CVTrainSets"');


%%
parpopulate(cd_lc.LCTestSets, 'lc_testset_owner = "cd_dataset.CVTestSets"');


% regiser pairing between CV TrainSets as LC trainsets and CV
% TrainSets as LC testsets
rel_test = pro(cd_lc.LCTrainSets * cd_dataset.CVTrainSets) * ...
    pro(cd_lc.LCTestSets * cd_dataset.CVTestSets);
registerPair(cd_lc.LCTrainTestPairs, rel_test);

%% now finally get onto training decoders and then LC models

%% train all decoders
parpopulate(cd_decoder.TrainedDecoder, 'dec_trainset_owner = "cd_dataset.ContrastSessionDataSet"');


%% train all LC models
parpopulate(cd_lc.TrainedLC, rel_train);

%% test trained LC on tset sets
parpopulate(cd_lc.LCModelFits, rel_test);