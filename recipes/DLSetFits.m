% recipe for fitting DL based models
% first fit only on restricted subset
restr = 'lc_id in (32, 38)';

parpopulate(cd_dlset.DLSet);
parpopulate(cd_dlset.DLSetInfo);

parpopulate(cd_dlset.TrainedLC, restr);
parpopulate(cd_dlset.LCModelFits, restr);
