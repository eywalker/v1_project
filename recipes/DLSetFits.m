% recipe for fitting DL based models
% first fit only on restricted subset
restr = 'lc_id in (32, 38)';
parpopulate(cd_dlset.TrainedLC, restr);
parpopulate(cd_dlset.LCModelFits);

% now fit on all the rest
parpopulate(cd_dlset.TrainedLC);
parpopulate(cd_dlset.LCModelFits);
