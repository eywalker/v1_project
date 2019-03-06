% recipe for fitting DL based models


% get all contrast sessions
parpopulate(cd_dataset.CleanContrastSessionDataSet);


% register CleanContrastSessions as decoder trainset
parpopulate(cd_decoder.DecoderTrainSets, 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"');

parpopulate(cd_dlset.CVSet);

% use specialized filler table to populate decoder_id = 4 case
% parpopulate(cd_decoder.MLFiller, 'decoder_id = 4');
parpopulate(cd_decoder.PoissonLikeFiller);
parpopulate(cd_decoder.NonLinMLFiller);
parpopulate(cd_decoder.FixedLikelihoodFiller);

parpopulate(cd_dlset.DLSet);


% first fit only on restricted subset
restr = 'lc_id=32 and decoder_id in (10, 11, 12, 13, 15) and lc_shuffle_id=0';
parpopulate(cd_dlset.TrainedLC, restr);
parpopulate(cd_dlset.LCModelFits, restr);

% Fit now on shuffled dataset
restr = 'lc_id=32 and decoder_id in (10, 11, 12, 13, 15) and lc_shuffle_id=1';
parpopulate(cd_dlset.TrainedLC, restr);
parpopulate(cd_dlset.LCModelFits, restr);

parpopulate(cd_dlset.DLSetInfo);
%parpopulate(cd_sim.TrainedLC, restr);
%parpopulate(cd_sim.LCModelFits, restr);
