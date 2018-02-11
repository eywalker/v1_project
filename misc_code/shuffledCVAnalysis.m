rel = pro(cd_dlset.LCModelFits, 'lc_test_logl', 'lc_test_mu_logl * lc_testset_size -> lc_total_logl');
rel = rel * pro(cd_dataset.CleanContrastSessionDataSet, 'dataset_hash -> dec_trainset_hash') * class_discrimination.CSCLookup;
data = fetch(rel, '*');

[v, data_hash, cv_index, lc_id, shuffle_id] = dj.struct.tabulate(data, 'lc_total_logl', 'dec_trainset_hash', 'cv_index', 'lc_id', 'lc_shuffle_id' );
subject_id = dj.struct.tabulate(data, 'subject_id', 'dec_trainset_hash', 'cv_index', 'lc_id', 'lc_shuffle_id' );


m1 = v(:,:,1,1);
m1s = v(:,:,1,2);
m2 = v(:,:,2,1);
m2s = v(:,:,2,2);


%%
rel = cd_dlset.TrainedLC & 'dec_trainset_hash = "2f8dde091cc5978f29e4784fe62aebdd60be589f"' & 'cv_index = 1' & 'lc_id = 38';

[data, dec, model] = getAll(rel & 'lc_shuffle_id = 0');
[data2, dec2, model2] = getAll(rel & 'lc_shuffle_id = 1');
%%
s = ClassifierModel.getMeanStd(data.decodeOri, data.likelihood);
s2 = ClassifierModel.getMeanStd(data2.decodeOri, data2.likelihood);

%%
base = cd_dlset.LCModelFits & 'lc_id = 38' & 'lc_shuffle_id=0';
shuffled = cd_dlset.LCModelFits & 'lc_id = 38' & 'lc_shuffle_id = 1';
deltas = pro(base * pro(shuffled, 'lc_shuffle_id -> shuffle_id', 'lc_test_mu_logl -> shuffle_mu_logl'), 'abs(lc_test_mu_logl - shuffle_mu_logl) -> delta');

thr = 5e-5;

filter= deltas & sprintf('delta > %f', thr);
