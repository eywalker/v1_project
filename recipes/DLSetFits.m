% recipe for fitting DL based models
% first fit only on restricted subset
restr = 'lc_id in (32, 38) and decoder_id=4';

parpopulate(cd_dlset.DLSet);
parpopulate(cd_dlset.DLSetInfo);

parpopulate(cd_dlset.TrainedLC, restr);
parpopulate(cd_dlset.LCModelFits, restr);


parpopulate(cd_simulated.TrainedLC, restr);
parpopulate(cd_simulated.LCModelFits, restr);
