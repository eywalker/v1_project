%% Experimental settings
sigmaA=3;
sigmaB=15;
s_center=270;
%% Fetch data for the specified session
SESSION_NUM=1;
trialInfo=sessionData(SESSION_NUM).trial_info;               
orientation = [trialInfo.orientation];
contrast = [trialInfo.contrast];
stimulusClass={trialInfo.stimulus_class};
selectedClass={trialInfo.selected_class};
%% Pool all session data
contrast=[];
orientation=[];
stimulusClass={};
selectedClass={};
for ind=1:length(sessionData)
    trialInfo=sessionData(ind).trial_info;
    orientation=[orientation trialInfo.orientation];
    contrast=[contrast trialInfo.contrast];
    stimulusClass=[stimulusClass {trialInfo.stimulus_class}];
    selectedClass=[selectedClass {trialInfo.selected_class}];
end

%% code to make all orientation lie withint 180-360 deg
orientation=mod(orientation,180)+180;

%% Fit BP-model for each contrast level and then plots results
figure;

line_color=lines;
legend_label={};
legend_handle=[];
contList=sort(unique(contrast),2,'descend');
modelBPFit=struct();
for indCont=1:length(contList)
    contVal=contList(indCont);
    trials=(contrast==contVal);
    s=orientation(trials)-s_center;
    classAnswer=stimulusClass(trials);
    respClass=selectedClass(trials);
    percCorrect=mean(strcmp(classAnswer,respClass));
    respA=strcmp(respClass,'A');
    
    [priorA, sigma_x]=fitModelBP(sigmaA,sigmaB,s,respClass);
    modelBPFit(indCont).contrast=contVal;
    modelBPFit(indCont).priorA=priorA;
    modelBPFit(indCont).sigma=sigma_x;
    
    %edges=prctile(s,0:5:100);
    edges=-50:5:50;
    [mu,sigma,n,binc,bin]=binnedStats(s,respA,edges);
    h=plot(binc,mu,'color',line_color(indCont,:));
    legend_handle=[legend_handle h];
    hold on;
    x=linspace(-50,50,100);
    %plot(x,pRespAGivenS_BP(sigmaA,sigmaB,priorA,sigma_x,x),'--','color',line_color(indCont,:));

    legend_label=[legend_label,sprintf('Contrast = %0.3f, Performance=%2.2f%%',contVal,percCorrect)];
end
legend(legend_handle,legend_label);
title('P(C=''A''|s) for different contrast levels');
xlabel('s (deg)');
ylabel('P(C=''A''|s)');

%% Plot BP-model for the specified contrasts with fixed priorA
figure;
s=-30:0.1:30;
priorA=0.4;
sigmaList=[0.1 2 5 50];
line_color=lines;
legend_label={};
for indSigma=1:length(sigmaList);
    sigma=sigmaList(indSigma);
    pA=pRespAGivenS_BP(sigmaA,sigmaB,priorA,sigma,s);
    plot(s,pA,'color',line_color(indSigma,:));
    hold on;
    legend_label=[legend_label num2str(sigma)];
    
end
legend(legend_label);
