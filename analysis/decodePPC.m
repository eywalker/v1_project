 % Fetch session list - run only if sessionData struct lost
key = acq.Sessions('session_datetime > "2013-08-01"');
sessionData=fetch((class_discrimination.ClassDiscriminationExperiment * ephys.SpikesAlignedSet) & key);

hSession=waitbar(0,sprintf('Completed session %d out of %d',0,length(sessionData)));
h=waitbar(0,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
for idxSess=1:length(sessionData)
    session=sessionData(idxSess);
    info=fetch(acq.Sessions & session,'*');
    date=info.session_datetime;
    trial_info=fetch(class_discrimination.ClassDiscriminationTrial & session, '*');
    
    
    waitbar(0,h,sprintf('Fetching Recording Data (%f2.2%% complete)',0));
    for i = 1:length(trial_info)
        spikes = fetch(ephys.SpikesAlignedTrial & trial_info(i), 'spikes_aligned');
        trial_info(i).counts = arrayfun(@(x) sum(x.spikes_aligned > 0 & x.spikes_aligned < 500), spikes);
        waitbar(i/length(trial_info),h, sprintf('Fetching Recording Data (%2.2f%% complete)',i/length(trial_info)*100));
    end
    sessionData(idxSess).trial_info=trial_info;
    sessionData(idxSess).date=date;
    waitbar(idxSess/length(sessionData),hSession,sprintf('Completed session %d out of %d',idxSess,length(sessionData)));
end
close(h);
close(hSession);
%% Specify session number
SESSION_NUM=9;

%%
% units = [1 2 3 7, ...
%         11 13 14 15 17 18 19 21 24 29 30, ...
%         41 44 46 47 51 52 53 54 55 56 57 58 61 62 63 64  66 67 68, ...
%         73 74 75 80 82 84 85 86 89 91 92 93];
trialInfo=sessionData(SESSION_NUM).trial_info;
counts = cat(2,trialInfo.counts);             
orientation = [trialInfo.orientation];
orientation=mod(orientation,180)+180;
contrast = [trialInfo.contrast];
%% Fetch contrastInfo struct WARNING: use this with caution!
contrastInfo=sessionData(SESSION_NUM).contrast_info;

%% Approximate reliability of each unit
contrastList=sort(unique(contrast(:)),1,'descend');
trials = find(contrast == contrastList(1));
F = gpRegTuningFunctions(orientation(trials)',counts(:,trials));
unitLL=mean(log(poisspdf(counts(:,trials)',F)));
%% Select units according to sum log likelihood for each unit
val=sort(unitLL);
valReg=val(val ~= -Inf);
perc=prctile(valReg,[25,40]);
%units=find(unitLL>=1.1*mean(perc));
units=find(unitLL>-3);
disp(size(units));
%% Obtain tuning curves and likelihood for the specified contrast level
% trials = find(contrast == 0.9);
% decode_ori = (240:0.5:310)';
% F=gpRegTuningFunctions(orientation(trials)',counts(units,trials),decode_ori);
% likelihood=decodePNPPC(F,counts(units,trials));

%% Plot out the decoded orientation
% [s,idx] = sort(orientation(trials));
% figure;
% imagesc(1:length(trials),decode_ori,likelihood(:,idx));
% set(gca,'CLim',[0 0.3]);
% hold on;
% plot(1:length(trials),s,'k') %% stimulus orientation by trial
% ori=repmat(decode_ori,[1,length(trials)]);
% [s_mu,sigma,s_max]=getLFStat(likelihood(:,idx),decode_ori);
% plot(1:length(trials),s_mu,'r');
% %plot(1:length(trials),sum(likelihood(:,idx).*ori)./sum(likelihood(:,idx)),'r')
% [~,mlIDX]=max(likelihood(:,idx));
% s_hat=decode_ori(mlIDX);
% %plot(1:length(trials),s_hat,'r');

%% Obtain tuning curves and likelihood for all contrast levels
contrastList=sort(unique(contrast(:)),1,'descend');
contrastInfo=struct();
for indCont=1:length(contrastList)
    contVal=contrastList(indCont);
    trials=find(contrast==contVal);
    decode_ori=(230:0.5:310)';
    F=gpRegTuningFunctions(orientation(trials)',counts(units,trials),decode_ori);
    likelihood=decodePNPPC(F,counts(units,trials));
    
    [s_mu,sigma_l,s_hat]=getLFStat(likelihood,decode_ori);
    rangeS=bsxfun(@minus,decode_ori([1,end]),s_hat');
    s_total=min(rangeS(1,:)):0.5:max(rangeS(2,:));
    shifted_L=zeros(length(s_total),size(likelihood,2));
    for indTrial=1:size(likelihood,2);
        pos=(s_total>=rangeS(1,indTrial) & s_total<=rangeS(2,indTrial));
        shifted_L(pos,indTrial)=likelihood(:,indTrial);
    end
    avgLikelihood=mean(shifted_L,2);
    [mu sigma fitL]=fitGaussianLikelihood(likelihood,decode_ori);
    
    % add results to the structure
    contrastInfo(indCont).contrast=contVal;
    contrastInfo(indCont).trials=trials;
    contrastInfo(indCont).stimulus=orientation(trials);
    contrastInfo(indCont).decode_ori=decode_ori;
    contrastInfo(indCont).tuningFx=F;
    contrastInfo(indCont).s_total=s_total;
    contrastInfo(indCont).avgLikelihood=avgLikelihood;
    contrastInfo(indCont).likelihood=likelihood;
    contrastInfo(indCont).gaussFitParam=[mu';sigma'];
    contrastInfo(indCont).gaussFitLikelihood=fitL;
end
sessionData(SESSION_NUM).contrast_info=contrastInfo;

%% Plot raw averaged likelihoods
figure;
line_color=lines;
legend_label={};
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    s_total=contrastInfo(indCont).s_total;
    avgTuningFx=contrastInfo(indCont).avgLikelihood;
    plot(s_total,avgTuningFx,'Color',line_color(indCont,:));
    legend_label=[legend_label,sprintf('Avg of Raw: contrast = %0.3f',contVal)];
    hold on;
end
legend(legend_label);
xlim([-20,20]);
title('Average liklihood function based on raw likelihoods');

%% Plot Gaussian fitted average likelihoods
figure;
line_color=lines;
legend_label={};
x=-40:0.5:40;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    fitParam=contrastInfo(indCont).gaussFitParam;
    sigma=fitParam(2,:);
    mix=mixGaussLikelihood(zeros(size(sigma)),sigma,x);
    plot(x,mix,'--','Color',line_color(indCont,:));
    legend_label=[legend_label,sprintf('Avg of Gauss fitted: contrast = %0.3f',contVal)];
    hold on;
end
legend(legend_label);
xlim([-20,20]);
xlabel('s-s_m_a_x (deg)');
title('Average liklihood function based on Gaussian fitted likelihoods');

%% Plot Gaussian based on averaged sigma_L of Gaussian fitted likelihoods
%figure;
%legend_label={};
x=-40:0.5:40;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    fitParam=contrastInfo(indCont).gaussFitParam;
    sigma=mean(fitParam(2,:));
    gauss=normpdf(x,0,sigma);
    gauss=gauss./sum(gauss);
    plot(x,gauss,'-','Color',line_color(indCont,:));
    legend_label=[legend_label,sprintf('Avg sigma_L: contrast = %0.3f',contVal)];
    hold on;
end
legend(legend_label);
xlim([-20,20]);
xlabel('s-s_m_a_x (deg)');
title('Average liklihood function based on averaged sigma_L');

%% Plot Gaussian based on averaged var_L of Gaussian fitted likelihoods
figure;
%legend_label={};
x=-40:0.5:40;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    fitParam=contrastInfo(indCont).gaussFitParam;
    var_L=fitParam(2,:).^2;
    sigma=sqrt(mean(var_L));
    gauss=normpdf(x,0,sigma);
    gauss=gauss./sum(gauss);
    plot(x,gauss,'-','Color',line_color(indCont,:));
    legend_label=[legend_label,sprintf('Avg var_L: contrast = %0.3f',contVal)];
    hold on;
end
legend(legend_label);
xlim([-20,20]);
xlabel('s-s_m_a_x (deg)');
title('Average liklihood function based on averaged var_L');

%% Plot Gaussian based on averaged J_L of Gaussian fitted likelihoods
%figure;
%legend_label={};
x=-40:0.5:40;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    fitParam=contrastInfo(indCont).gaussFitParam;
    J_L=1./fitParam(2,:).^2
    avgJ=mean(J_L);
    sigma=sqrt(1./avgJ);
    gauss=normpdf(x,0,sigma);
    gauss=gauss./sum(gauss);
    plot(x,gauss,'-','Color',line_color(indCont,:));
    legend_label=[legend_label,sprintf('Avg J_L: contrast = %0.3f',contVal)];
    hold on;
end
legend(legend_label);
xlim([-20,20]);
xlabel('s-s_m_a_x (deg)');
title('Average liklihood function based on averaged J_L');

%% Plot Raw Likelihood maps by contrast
figure;

for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    L=contrastInfo(indCont).likelihood;
    stimulus=contrastInfo(indCont).stimulus;
    decode_ori=contrastInfo(indCont).decode_ori;
    
    [s,idx]=sort(stimulus);
    subplot(1,length(contrastInfo),indCont);
    imagesc(1:length(s),decode_ori,L(:,idx));
    hold on;
    plot(1:length(s),s,'k','LineWidth',2);
    set(gca,'CLim',[0 0.1]);
    title(sprintf('Contrast = %0.3f',contVal));
    xlabel('Trial');
    ylabel('s (deg)');
    
end
%% Plot Gaussian Fitted Likelihood maps by contrast
figure;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    L=contrastInfo(indCont).gaussFitLikelihood;
    stimulus=contrastInfo(indCont).stimulus;
    decode_ori=contrastInfo(indCont).decode_ori;
    
    [s,idx]=sort(stimulus);
    subplot(1,length(contrastInfo),indCont);
    imagesc(1:length(s),decode_ori,L(:,idx));
    hold on;
    plot(1:length(s),s,'k','LineWidth',2);
    set(gca,'CLim',[0 0.3]);
    title(sprintf('Contrast = %0.3f',contVal));
    xlabel('Trial');
    ylabel('s (deg)');
    
end
%% Plot histogram of s_hat-s by contrast
figure;
bins=-60:2.5:60;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    L=contrastInfo(indCont).likelihood;
    stimulus=contrastInfo(indCont).stimulus;
    decode_ori=contrastInfo(indCont).decode_ori;
    
    [~,~,s_hat]=getLFStat(L,decode_ori);
    subplot(length(contrastInfo),1,indCont);
    hist(s_hat'-stimulus,bins);
    title(sprintf('Contrast = %0.3f',contVal));
    xlim([-40,40]);    
    ylabel('Frequency');
end
xlabel('s\_hat - s');
%% Plot distribution of s_hat-s by contrast
figure;
legend_label={};
line_color=lines;

edges=-60:120/51:60;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    L=contrastInfo(indCont).likelihood;
    stimulus=contrastInfo(indCont).stimulus;
    decode_ori=contrastInfo(indCont).decode_ori;
    
    [~,~,s_hat]=getLFStat(L,decode_ori);
    binc=0.5*(edges(1:end-1)+edges(2:end));
    count=histc(s_hat'-stimulus,edges);
    count=count./sum(count);
    plot(binc,count(1:end-1),'color',line_color(indCont,:));
    xlim([-40,40]);    
    legend_label=[legend_label,sprintf('Contrast = %0.3f',contVal)];
    hold on;
    ylabel('Relative Frequency');
end
title('Distribution of error in MLE by contrast');
legend(legend_label);
xlabel('s\_hat - s');
%% Plot sigma_L vs ML error
figure;
legend_label={};
line_color=lines;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    L=contrastInfo(indCont).likelihood;
    s=contrastInfo(indCont).stimulus;
    fitParam=contrastInfo(indCont).gaussFitParam;
    decode_ori=contrastInfo(indCont).decode_ori;
    
    sigma_l=fitParam(2,:)';
    [~,~,s_hat]=getLFStat(L,decode_ori);
    plot(s_hat-s',sigma_l,'.','Color',line_color(indCont,:));
    hold on;
    legend_label=[legend_label,sprintf('Contrast = %0.3f',contVal)];
end
xlabel('ML error');
ylabel('sigma_L');
legend(legend_label);
xlim([-30,30]);
ylim([0,12]);
title('sigma_L vs ML error');

%legend(legend_label);
%% Plot |ML error| vs J_L with correlation analysis
figure;
line_color=lines;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    L=contrastInfo(indCont).likelihood;
    s=contrastInfo(indCont).stimulus;
    fitParam=contrastInfo(indCont).gaussFitParam;
    decode_ori=contrastInfo(indCont).decode_ori;
    
    subplot(length(contrastInfo),1,indCont);
    sigma_l=fitParam(2,:)';
    [~,~,s_hat]=getLFStat(L,decode_ori);
    J_L=sigma_l.^-2;
    J_ML=(s_hat-s').^-2;
    plot(J_ML,J_L,'.','Color',line_color(indCont,:));
    [R,P,PLO,PUP]=corrcoef(J_ML,J_L);
    ylabel('J_L');
    title(sprintf('J_L vs |ML error| : R = %0.2f, p=%0.3f, 95%% CI=[%0.3f, %0.3f]',R(2,1),P(2,1),PLO(2,1),PUP(2,1)));
    hold on;
end
xlabel('|ML Error|');

%legend(legend_label);


%% Plot out likelihood function standard deviation vs contrast
figure;
colors=lines;
legend_label={};
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    fitParam=contrastInfo(indCont).gaussFitParam;
    
    sigma_l=fitParam(2,:);
    plot(contVal*ones(size(sigma_l)),sigma_l,'o','Color',colors(indCont,:));
    legend_label=[legend_label,sprintf('Contrast = %0.3f',contVal)];
    hold on;
end
xlim([-0.1,1]);
xlabel('Contrast');
ylabel('Standard Deviation of Likelihood Function');
legend(legend_label);
title('sigma_L vs contrast');

%% Analyze % correct by binning across J_L and e_ML (error in ML)
figure;
e_ML_cutoff=[15];
e_ML_cutoff=[0 e_ML_cutoff Inf];
grid=zeros(length(contrastInfo),length(e_ML_cutoff)-1);
for indCont=1:length(contrastInfo)
    trials=contrastInfo(indCont).trials;
    stimulusClass={trialInfo(trials).stimulus_class};
    selectedClass={trialInfo(trials).selected_class};
    correctClass=strcmp(stimulusClass,selectedClass);
    L=contrastInfo(indCont).likelihood;
    s=contrastInfo(indCont).stimulus;
    decode_ori=contrastInfo(indCont).decode_ori;
    [~,~,s_hat]=getLFStat(L,decode_ori);
    e_ML=abs(s_hat-s');
    
    for indEML=1:length(e_ML_cutoff)-1
        pos=find(e_ML>e_ML_cutoff(indEML) & e_ML<e_ML_cutoff(indEML+1));
        grid(indCont,indEML)=sum(correctClass(pos))./length(pos);
    end
    
end
[eML_v, cont_v]=meshgrid(1:length(e_ML_cutoff)-1,[contrastInfo(:).contrast]);
plot(cont_v,grid);

%% Analysis of distribution of sigma_l
figure;
colors=lines;
legend_label={};
edges=0:0.25:10;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    fitParam=contrastInfo(indCont).gaussFitParam;
    sigma_l=fitParam(2,:);
    count=histc(sigma_l,edges);
    binc=0.5*(edges(2:end)+edges(1:end-1));
    plot(binc,count(1:end-1),'-o','Color',colors(indCont,:));
    legend_label=[legend_label,sprintf('Contrast = %0.3f',contVal)];
    hold on;
end
xlabel('sigma_L');
ylabel('Frequency');
title('Distribution of sigma_L by contrast');
legend(legend_label);

%% sigma_eML vs sigma_L
figure;
line_color=lines;
legend_handle=[];
legend_label={};
maxEdge=0;
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    L=contrastInfo(indCont).likelihood;
    s=contrastInfo(indCont).stimulus;
    fitParam=contrastInfo(indCont).gaussFitParam;
    decode_ori=contrastInfo(indCont).decode_ori;
    sigma_l=fitParam(2,:)';
    edges=prctile(sigma_l,0:10:100);
    maxEdge=max([edges,maxEdge]);
    [~,~,s_hat]=getLFStat(L,decode_ori);
    e_ml=s_hat-s'; %error in max likelihood estimate
    SIGMA_EML_ALL=std(e_ml); %sigma EML calculated from all trials in the given contrast
    x=linspace(0,100,100);
    [~,sigma_eml, ~, binc, bin]=binnedStats(sigma_l,e_ml,edges);
    h=plot(binc,sigma_eml,'-o','color',line_color(indCont,:));
    legend_handle=[legend_handle,h];
    hold on;
    plot(x,SIGMA_EML_ALL*ones(size(x)),'--','color',line_color(indCont,:));
    legend_label=[legend_label,sprintf('Contrast = %0.3f',contVal)];
end
title('Sigma of error in ML vs sigma_L');
xlabel('sigma_L');
ylabel('sigma_{EML}');
legend(legend_handle,legend_label);
xlim([0,maxEdge*1.1]);

%% Fit BP model for different values of sigma_l per contrast
sigmaA=3;
sigmaB=15;
s_center=270;
figure;
line_color=lines;
legend_label={};
for indCont=1:length(contrastInfo)
    contVal=contrastInfo(indCont).contrast;
    trialIdx=contrastInfo(indCont).trials;
    s=contrastInfo(indCont).stimulus-s_center;
    classResp={trialInfo(trialIdx).selected_class};
    sigma_l=contrastInfo(indCont).gaussFitParam(2,:);
    prcPts=0:10:100;
    prcCenter=0.5*(prcPts(1:end-1)+prcPts(2:end));
    edges=prctile(sigma_l,prcPts);
    binc=zeros(length(edges)-1,1);
    priorA=zeros(size(binc));
    sigma_x=zeros(size(binc));
    for ind=1:length(edges)-1
        trials=(sigma_l>edges(ind) & sigma_l<=edges(ind+1));
        binc(ind)=mean(sigma_l(trials));
        s_sub=s(trials);
        resp_sub=classResp(trials);
        [priorA, sigma_x(ind)]=fitModelBP(sigmaA,sigmaB,s_sub,resp_sub);
    end
    disp(binc);
    disp(sigma_x);
    plot(prcCenter,sigma_x,'-o','color',line_color(indCont,:));
    hold on;
    legend_label=[legend_label,sprintf('Contrast = %0.3f',contVal)];
end
xlabel('sigma_l');
ylabel('sigma');
title('sigma of fitted BP-model vs sigma_L');
legend(legend_label);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% This part of the code runs over ALL sessions - compare sigma_l distribution
allContrastInfo=[sessionData.contrast_info];
contList=sort(unique([allContrastInfo.contrast]),2,'descend');
figure;
colors=lines;
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
legend_handle=zeros(size(contList));
edges=0:0.25:10;
for indCont=1:length(allContrastInfo)
    contVal=allContrastInfo(indCont).contrast;
    fitParam=allContrastInfo(indCont).gaussFitParam;
    sigma_l=fitParam(2,:);
    count=histc(sigma_l,edges);
    binc=0.5*(edges(2:end)+edges(1:end-1));
    match=find(contList==contVal);
    h=plot(binc,count(1:end-1),'-o','Color',colors(match,:));
    legend_handle(match)=h;
    hold on;
end
xlabel('sigma_L');
ylabel('Frequency');
title('Distribution of sigma_L by contrast');
legend(legend_handle,legend_label);