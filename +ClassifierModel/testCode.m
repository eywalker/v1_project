SESSION_NUM=13;
trialInfo=sessionData(SESSION_NUM).trial_info;
counts=cat(2,trialInfo.counts);
orientation=[trialInfo.orientation];
orientation=mod(orientation,180)+180;
contrast=[trialInfo.contrast];

contrastList=sort(unique(contrast(:)),1,'descend');
contVal=contrastList(1);
trials=find(contrast==contrastList(1)); %choose highest contrast
GPtc=ClassifierModel.GPPPCEncoder(size(counts,1)); %initialize with 96 units
GPtc.train(orientation(trials),[],counts(:,trials)); %train the GP tuning curves
%decode_ori=230:0.5:310;

sc=GPtc.encode(decode_ori,contVal);

pnEnc=ClassifierModel.PoissonNoisePPCEncoder(GPtc);
likelihood=pnEnc.getLikelihood(orientation(trials),[],counts(:,trials));

%%
F = gpRegTuningFunctions(orientation(trials)',counts(:,trials));
%%
ms=[];
for i = 1: 8
    ms=cat(1, ms, sessionData(i).modelScores);
    
end
csvwrite('modelScoreOutput.csv',ms);
%
%%
SESSION_NUM = 8;
trialInfo = sessionData(SESSION_NUM).trial_info;
contrast = [trialInfo.contrast];
stimClass = {trialInfo.stimulus_class};
respClass = {trialInfo.selected_class};
correctResp = strcmp(stimClass, respClass);
a = [trialInfo.correct_response];
contrastList = sort(unique(contrast),2,'descend');
for ind = 1 : length(contrastList)
    trials = (contrast == contrastList(ind));
    fprintf('Contrast %f: %f %f\n', contrastList(ind),mean(correctResp(trials)),mean(a(trials)));
end