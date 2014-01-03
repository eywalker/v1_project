sigmaA=3;
sigmaB=15;
s_center=270;

SESSION_NUM=9;
session=sessionData(SESSION_NUM);
trialInfo=session.trial_info;
contrastInfo=session.contrast_info;

contrast=[trialInfo.contrast];
orientation=[trialInfo.orientation]-s_center;
response={trialInfo.selected_class};
answer={trialInfo.stimulus_class};


for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    decode_ori=contrastInfo(indCont).decode_ori-s_center;
    likelihood=contrastInfo(indCont).likelihood;
    trials=contrastInfo(indCont).trials;
    gaussFitParams=contrastInfo(indCont).gaussFitParam;
    resp=response(trials);
    s=orientation(trials);
    
    [priorA sigma]=fitModelBP(sigmaA,sigmaB,s,resp);
    logL_Beh=logLModelBP(sigmaA,sigmaB,priorA,sigma,s,resp)
    
    [priorA, slip_rate]=fitPPC_BP(sigmaA,sigmaB,decode_ori,likelihood,gaussFitParams,resp);
    logL_BP=logLPPC_BP(sigmaA,sigmaB,priorA,decode_ori,likelihood,gaussFitParams,slip_rate,resp)
    
    [priorA, slip_rate]=fitPPC_NB(sigmaA,sigmaB,decode_ori,likelihood,resp);
    logL_NB=logLPPC_NB(sigmaA,sigmaB,priorA,decode_ori,likelihood,slip_rate,resp)
    
    [priorA,alpha,slip_rate]=fitPPC_raw(sigmaA,sigmaB,decode_ori,likelihood,resp);
    logL_raw=logLPPC_raw(sigmaA,sigmaB,priorA,decode_ori,likelihood,alpha,slip_rate,resp)
end
% %%
% netL=zeros(length(decode_ori),length(trialInfo));
% netGaussParams=zeros(2,length(trialInfo));
% for indCont=1:length(contrastInfo)
%     trials=contrastInfo(indCont).trials;
%     netL(:,trials)=contrastInfo(indCont).likelihood;
%     netGaussParams(:,trials)=contrastInfo(indCont).gaussFitParam;
% end
% resp=response;
% [priorA, slip_rate]=fitPPC_BP(sigmaA,sigmaB,decode_ori,netL,netGaussParams,resp);
% logL_BP=logLPPC_BP(sigmaA,sigmaB,priorA,decode_ori,netL,netGaussParams,slip_rate,resp)
% [priorA, slip_rate]=fitPPC_NB(sigmaA,sigmaB,decode_ori,netL,resp);
% logL_NB=logLPPC_NB(sigmaA,sigmaB,priorA,decode_ori,netL,slip_rate,resp)
% 
% [priorA,alpha,slip_rate]=fitPPC_raw(sigmaA,sigmaB,decode_ori,netL,resp);
% logL_raw=logLPPC_raw(sigmaA,sigmaB,priorA,decode_ori,netL,alpha,slip_rate,resp)

%%

sessionList = fetch(class_disc.ClassDiscriminationExperiment * ephys.SpikesAlignedSet);
hSession=waitbar(0,sprintf('Completed session %d out of %d',0,length(sessionList)));
h=waitbar(0,sprintf('Fetching Recording Data (%2.2f%% complete)',0));
for idxSess = 1 : length(sessionList)
    session = sessionList(idxSess);
    date = fetch1(acq.Sessions & session, 'session_datetime');
    trial_info = fetch(class_disc.ClassDiscriminationTrial & session, '*');
    waitbar(0,h,sprintf('Fetching Recording Data (%2.2f%% complete)',0));
    for i = 1 : length(trial_info)
        trial = trial_info(i);
        spikes = fetch(ephys.SpikesAlignedTrial & trial, 'spikes_aligned');
        trial_info(i).counts = arrayfun(@(x) sum(x.spikes_aligned > 0 & x.spikes_aligned < 500), spikes);
        waitbar(i/length(trial_info),h, sprintf('Fetching Recording Data (%2.2f%% complete)',i/length(trial_info)*100));
    end
    sessionList(idxSess).trial_info = trial_info;
    sessionList(idxSess).date = date;
    waitbar(idxSess/length(sessionList),hSession,sprintf('Completed session %d out of %d',idxSess,length(sessionList)));
end
close(h);
close(hSession);