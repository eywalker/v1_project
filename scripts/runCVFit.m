warning ('off','all');
%parpopulate(cd_lc.PrevFitLC, 'decoder_id = 3')
MLBasedFits
GetBinaryPerformance
%CleanCrossValidationSetFits;
%FitCleanContrastSession;
%RunCleanSimulationCV;
%FitShuffledParameterizedCleanContrastSession;
%FitShuffledPointBasedCCS;
quit;
