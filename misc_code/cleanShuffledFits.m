m1 = cd_dlset.TrainedLC & 'lc_id = 38' & 'lc_shuffle_id = 0';
m2 = pro(cd_dlset.TrainedLC & 'lc_id = 38' & 'lc_shuffle_id = 1', 'lc_shuffle_id -> shuffle_id', 'lc_train_mu_logl -> shuffle_logl');
thr = 4e-4;
filter = pro(m1 * m2, 'abs(lc_train_mu_logl - shuffle_logl) -> delta') & sprintf('delta > %f', thr);
%%

keys = fetch(cd_dlset.CVSetMember & cd_dlset.TrainedLC & filter);

hit = 0;
for i=1:length(keys)
    if mod(i, 10) == 0
        fprintf('.');
    end
    key = keys(i);
    original = fetch(cd_dlset.TrainedLC & key &  'lc_id = 38' & 'lc_shuffle_id = 0', '*');
    shuffled = fetch(cd_dlset.TrainedLC & key &  'lc_id = 38' & 'lc_shuffle_id = 1', '*');
    
    delta = abs(original.lc_train_mu_logl - shuffled.lc_train_mu_logl);
    if abs(original.lc_train_mu_logl - shuffled.lc_train_mu_logl) < thr
        continue;
    end
    fprintf('x');
    
    [data1, dec1, model1] = getAll(cd_dlset.TrainedLC & key & 'lc_id = 38' & 'lc_shuffle_id = 0');
    [data2, dec2, model2] = getAll(cd_dlset.TrainedLC & key & 'lc_id = 38' & 'lc_shuffle_id = 1');
    
    
    % checks
    ll11 = model1.getLogLikelihood(data1);
    ll12 = model1.getLogLikelihood(data2);
    ll21 = model2.getLogLikelihood(data1);
    ll22 = model2.getLogLikelihood(data2);
    
    if abs(ll12 - ll11) > thr || abs(ll21 - ll22) > thr
        disp('Bad case!!');
        disp(key);
        continue;
    end
    
    if ll11 > ll22
        % update shuffled
        model2.setModelConfigs(model1.getModelConfigs);
        [muLL, logL] = model2.getLogLikelihood(data2);
        assert(abs(muLL - ll11) < thr, 'Failure to update correctly');
        assert(muLL >= ll22, 'Failure to update correctly');
        shuffled.lc_train_mu_logl = muLL;
        shuffled.lc_train_logl = logL;
        shuffled.lc_trained_config = model2.getModelConfigs;
        del(cd_dlset.TrainedLC & key & 'lc_id = 38' & 'lc_shuffle_id = 1', true);
        insert(cd_dlset.TrainedLC, shuffled);
    else
        % update original
        model1.setModelConfigs(model2.getModelConfigs);
        [muLL, logL] = model1.getLogLikelihood(data1);
        assert(abs(muLL - ll22) < thr, 'Failure to update correctly');
        assert(muLL >= ll11, 'Failure to update correctly');
        original.lc_train_mu_logl = muLL;
        original.lc_train_logl = logL;
        original.lc_trained_config = model1.getModelConfigs;
        del(cd_dlset.TrainedLC & key & 'lc_id = 38' & 'lc_shuffle_id = 0', true);
        insert(cd_dlset.TrainedLC, original);
    end
    
end