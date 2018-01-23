%parpopulate(cd_analysis.BinaryReadout, 'lc_trainset_owner like "%Simulated%"');
parpopulate(cd_analysis.TestsetBinaryReadout, 'lc_testset_owner like "%CleanCVTest%"', 'decoder_id = 3');
%parpopulate(cd_analysis.TestsetBinaryReadout);
