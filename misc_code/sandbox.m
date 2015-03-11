keys = fetch(pro(class_discrimination.ContrastSessionDataSet,'dataset_id -> decoder_trainset_id', 'dataset_contrast -> contrast') ...
    * pro(class_discrimination.CVTrainSets, 'dataset_id -> lc_trainset_id','cv_contrast -> contrast'), '*');

for i = 1:length(keys)
    registerPair(class_discrimination.LCTrainSetPairs, keys(i).decoder_trainset_id, keys(i).lc_trainset_id);
end