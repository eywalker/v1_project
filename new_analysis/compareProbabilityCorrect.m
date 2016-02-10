 %% Compare the probability of predicting the monkey's decision right under two distinct models

cond = 'subject_id = 3'; % analyze Tom only

% get all contrastsessions used to train LC
contrastSet = fetch(cd_lc.LCTrainSets * cd_dataset.ContrastSessionDataSet & cond & cd_lc.TrainedLC);
peaks = [];
pws = [];

%%
for id=1:length(contrastSet)

    key = fetch(cd_lc.TrainedLC & contrastSet(id), 'LIMIT 1')
    dataSet = getDataSet(cd_lc.TrainedLC & key);

    modelPeak = getLC(cd_lc.TrainedLC & contrastSet(id) & 'lc_id = 1');

    predictionPeak = modelPeak.pRespA(dataSet) > 0.5;

    modelPW = getLC(cd_lc.TrainedLC & contrastSet(id) & 'lc_id = 4');

    predictionPW = modelPW.pRespA(dataSet) > 0.5;

    actualChoice = strcmp(dataSet.selected_class, 'A');

    peakGood = predictionPeak == actualChoice';
    peaks = [peaks mean(peakGood)];
    pwGood = predictionPW == actualChoice';
    pws = [pws mean(pwGood)];
    
    fprintf('%f vs %f\n', mean(peakGood), mean(pwGood));

end