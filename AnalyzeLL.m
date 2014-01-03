sigmaA=3;
sigmaB=15;
s_center=270;

llData=struct;
pos=1;

for indSession=1:length(sessionData)
    
    session=sessionData(indSession);
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
        
        llData(pos).session=indSession;
        llData(pos).contrast=contVal;
        llData(pos).beh=logL_Beh;
        llData(pos).BP=logL_BP;
        llData(pos).NB=logL_NB;
        llData(pos).raw=logL_raw;
        
        pos=pos+1;
    end
end
%%
sigmaA=3;
sigmaB=15;
s_center=270;


sumLLData=struct;
for indSession=1:length(sessionData)
        
    session=sessionData(indSession);
    trialInfo=session.trial_info;
    contrastInfo=session.contrast_info;

    contrast=[trialInfo.contrast];
    orientation=[trialInfo.orientation]-s_center;
    resp={trialInfo.selected_class};
    answer={trialInfo.stimulus_class};
    netL=zeros(length(decode_ori),length(trialInfo));
    netGaussParams=zeros(2,length(trialInfo));
    
    for indCont=1:length(contrastInfo)
        trials=contrastInfo(indCont).trials;
        netL(:,trials)=contrastInfo(indCont).likelihood;
        netGaussParams(:,trials)=contrastInfo(indCont).gaussFitParam;
    end
    
    [priorA sigma]=fitModelBP(sigmaA,sigmaB,orientation,resp);
    logL_Beh=logLModelBP(sigmaA,sigmaB,priorA,sigma,orientation,resp);
    
    [priorA, slip_rate]=fitPPC_BP(sigmaA,sigmaB,decode_ori,netL,netGaussParams,resp);
    logL_BP=logLPPC_BP(sigmaA,sigmaB,priorA,decode_ori,netL,netGaussParams,slip_rate,resp);
    
    [priorA, slip_rate]=fitPPC_NB(sigmaA,sigmaB,decode_ori,netL,resp);
    logL_NB=logLPPC_NB(sigmaA,sigmaB,priorA,decode_ori,netL,slip_rate,resp);

    [priorA,alpha,slip_rate]=fitPPC_raw(sigmaA,sigmaB,decode_ori,netL,resp);
    logL_raw=logLPPC_raw(sigmaA,sigmaB,priorA,decode_ori,netL,alpha,slip_rate,resp);
    
    sumLLData(indSession).session=indSession;
    sumLLData(indSession).beh=logL_Beh;
    sumLLData(indSession).BP=logL_BP;
    sumLLData(indSession).NB=logL_NB;
    sumLLData(indSession).raw=logL_raw;
end
%%
a=[sumLLData.session];
a(2,:)=[sumLLData.beh];
a(3,:)=[sumLLData.BP];
a(4,:)=[sumLLData.NB];
a(5,:)=[sumLLData.raw];