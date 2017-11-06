decoder_trainset = pro(class_discrimination.SpikeCountSet * class_discrimination.ContrastSessionDataSet, ...
    'dataset_id -> decoder_trainset_id', 'dataset_contrast -> contrast');
lc_trainset = pro(class_discrimination.SpikeCountSet * class_discrimination.CrossValidationSets * class_discrimination.CVTrainSets,...
    'dataset_id -> lc_trainset_id', 'cv_contrast -> contrast');

lc_testset = pro(class_discrimination.SpikeCountSet * class_discrimination.CrossValidationSets * class_discrimination.CVTestSets, ...
    'dataset_id -> lc_testset_id', 'cv_contrast -> contrast');
cv_set = decoder_trainset * lc_trainset;


cv_test_train = fetch(lc_trainset * lc_testset, '*');