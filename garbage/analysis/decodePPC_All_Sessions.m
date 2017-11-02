%% Fit BP model for different values of sigma_l per contrast
sigmaA=3;
sigmaB=15;
s_center=270;
figure;
line_color=lines;
legend_label={};
allContrastInfo=[sessionData.contrast_info];
contList=sort(unique([allContrastInfo.contrast]),2,'descend');
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
legend_handle1=zeros(size(contList));
legend_handle2=legend_handle1;

bpl = ClassifierModel.BehavioralClassifier.BPLClassifier2(sigmaA, sigmaB, sCenter);

prcPts=0:25:100;
prcCenter=0.5*(prcPts(1:end-1)+prcPts(2:end));
distrPrcByContrast=cell(1,length(contList));
sessions=1:9;
for indSession=sessions
    contrastInfo=sessionData(indSession).contrast_info;
    trialInfo=sessionData(indSession).trial_info;
    for indCont=1:length(contrastInfo)
        contVal=contrastInfo(indCont).contrast;
        trialIdx=contrastInfo(indCont).trials;
        s=contrastInfo(indCont).stimulus-s_center;
        classResp={trialInfo(trialIdx).selected_class};
        sigma_l=contrastInfo(indCont).gaussFitParam(2,:);
        
        edges=prctile(sigma_l,prcPts);
        binc=zeros(1,length(edges)-1);
        priorA=zeros(size(binc));
        sigma_x=zeros(size(binc));
        for ind=1:length(edges)-1
            trials=(sigma_l>edges(ind) & sigma_l<=edges(ind+1));
            binc(ind)=mean(sigma_l(trials));
            s_sub=s(trials);
            resp_sub=classResp(trials);
            bpl.train(s_sub,[],resp_sub);
            sigma_x(ind) = bpl.sigma;
        end
        disp(binc);
        disp(sigma_x);
        match=find(contList==contVal);
        distrPrcByContrast{match}=[distrPrcByContrast{match}; sigma_x];
        
        subplot(1,3,1);
        h1=plot(binc,sigma_x,'-o','color',line_color(match,:));
        legend_handle1(match)=h1;
        hold on;
        subplot(1,3,2);
        h2=plot(prcCenter,sigma_x,'-o','color',line_color(match,:));
        legend_handle2(match)=h2;
        hold on;
    end
end
subplot(1,3,1);
xlabel('sigma_L');
ylabel('sigma');
title('sigma of fitted BP-model vs sigma_L');
legend(legend_handle1,legend_label);
subplot(1,3,2);
xlabel('sigma_L percentile (%)');
ylabel('sigma');
title('sigma of fitted BP-model vs sigma_L percentile');
legend(legend_handle2,legend_label);


subplot(1,3,3);
legend_handle=[];
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
hold off;
for indCont=1:length(contList)
    avgSigma_x=mean(distrPrcByContrast{indCont});
    semSigma_x=std(distrPrcByContrast{indCont})./sqrt(size(distrPrcByContrast{indCont},1));
    h=plot(prcCenter,avgSigma_x,'color',line_color(indCont,:));
    errorShade(prcCenter,avgSigma_x,semSigma_x,colors(indCont,:),0.2);
    legend_handle=[legend_handle h];
    hold on;
end
xlabel('sigma_L percentile (%)');
ylabel('sigma');
title('Average sigma of fitted BP-model vs sigma_L percentile');
legend(legend_handle,legend_label);

%% compare sigma_l distribution across contrasts
sessions=[1:6];
allContrastInfo=[sessionData(sessions).contrast_info];
contList=sort(unique([allContrastInfo.contrast]),2,'descend');
figure;
colors=lines;
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
legend_handle=zeros(size(contList));
edges=0:0.25:15;
avgDistr=cell(length(contList),1);
subplot(1,2,1);
for indCont=1:length(allContrastInfo)
    contVal=allContrastInfo(indCont).contrast;
    fitParam=allContrastInfo(indCont).gaussFitParam;
    sigma_l=fitParam(2,:);
    count=histc(sigma_l,edges);
    binc=0.5*(edges(2:end)+edges(1:end-1));
    match=find(contList==contVal);
    avgDistr{match}=[avgDistr{match};count(1:end-1)/sum(count(1:end-1))];
    h=plot(binc,count(1:end-1),'-o','Color',colors(match,:));
    legend_handle(match)=h;
    hold on;
end
xlabel('sigma_L');
ylabel('Frequency');
title('Distribution of sigma_L by contrast');
xlim([0,12]);
legend(legend_handle,legend_label);
subplot(1,2,2);
legend_handle=[];
for indCont=1:length(contList)
    avgFreq=mean(avgDistr{indCont});
    semFreq=std(avgDistr{indCont})./sqrt(size(avgDistr{indCont},1));
    h=plot(binc,avgFreq,'color',colors(indCont,:));
    hold on;
    errorShade(binc,avgFreq,semFreq,colors(indCont,:),0.2);
    legend_handle=[legend_handle h];
    %plot(binc,avgFreq,'color',colors(indCont,:));
end
title('Averaged distribution of sigma_L by contrast');
xlabel('sigma_L');
ylabel('Frequency');
xlim([0,12]);
ylim([0,0.6]);
legend(legend_handle,legend_label);
%% Analyze performance according to the sigma_L 

figure;
line_color=lines;
legend_label={};
allContrastInfo=[sessionData.contrast_info];
contList=sort(unique([allContrastInfo.contrast]),2,'descend');
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
legend_handle1=zeros(size(contList));
legend_handle2=legend_handle1;


prcPts=0:10:100;
prcCenter=0.5*(prcPts(1:end-1)+prcPts(2:end));

distrPrcByContrast=cell(1,length(contList));

sessions=1:9;
for indSession=sessions
    contrastInfo=sessionData(indSession).contrast_info;
    trialInfo=sessionData(indSession).trial_info;
    for indCont=1:length(contrastInfo)
        contVal=contrastInfo(indCont).contrast;
        trialIdx=contrastInfo(indCont).trials;
        classResp={trialInfo(trialIdx).selected_class};
        classStim={trialInfo(trialIdx).stimulus_class};
        correctClass=strcmp(classResp,classStim);
        
        sigma_l=contrastInfo(indCont).gaussFitParam(2,:);
        
        edges=prctile(sigma_l,prcPts);
        binc=zeros(1,length(edges)-1);
        perf_list=zeros(1,length(edges)-1);
        for ind=1:length(edges)-1
            trials=(sigma_l>edges(ind) & sigma_l<=edges(ind+1));
            perf=mean(correctClass(trials));
            perf_list(ind)=perf;
            binc(ind)=mean(sigma_l(trials));
        end
        match=find(contList==contVal);
        distrPrcByContrast{match}=[distrPrcByContrast{match}; perf_list];
        
        
        subplot(1,3,1);
        h1=plot(binc,perf_list,'-o','color',line_color(match,:));
        legend_handle1(match)=h1;
        hold on;
        subplot(1,3,2);
        h2=plot(prcCenter,perf_list,'-o','color',line_color(match,:));
        legend_handle2(match)=h2;
        hold on;
    end
end
subplot(1,3,1);
xlabel('sigma_L');
ylabel('Performance');
title('Performance vs sigma_L');
legend(legend_handle1,legend_label);
subplot(1,3,2);
xlabel('sigma_L percentile (%)');
ylabel('Performance');
title('Performance vs sigma_L percentile');
legend(legend_handle2,legend_label);

subplot(1,3,3);
legend_handle=[];
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
hold off;
for indCont=1:length(contList)
    avgPerf=mean(distrPrcByContrast{indCont});
    semPerf=std(distrPrcByContrast{indCont})./sqrt(size(distrPrcByContrast{indCont},1));
    h=plot(prcCenter,avgPerf,'color',line_color(indCont,:));
    errorShade(prcCenter,avgPerf,semPerf,colors(indCont,:),0.2);
    legend_handle=[legend_handle h];
    hold on;
end
xlabel('sigma_L percentile (%)');
ylabel('Performance');
title('Average sigma of fitted BP-model vs sigma_L percentile');
legend(legend_handle,legend_label);

%% Analyze performance according to the sigma_L vs error_rate


figure;
line_color=lines;
legend_label={};
allContrastInfo=[sessionData.contrast_info];
contList=sort(unique([allContrastInfo.contrast]),2,'descend');
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
legend_handle1=zeros(size(contList));
legend_handle2=legend_handle1;


prcPts=0:10:100;
prcCenter=0.5*(prcPts(1:end-1)+prcPts(2:end));
prcEML=[0:50:100];
prcEMLC=0.5*(prcPts(1:end-1)+prcPts(2:end));
distrPrcByContrast=cell(1,length(contList));
distrPrcByContrast2=cell(1,length(contList));
sessions=1:9;
for indSession=sessions
    contrastInfo=sessionData(indSession).contrast_info;
    trialInfo=sessionData(indSession).trial_info;
    for indCont=1:length(contrastInfo)
        contVal=contrastInfo(indCont).contrast;
        trialIdx=contrastInfo(indCont).trials;
        classResp={trialInfo(trialIdx).selected_class};
        classStim={trialInfo(trialIdx).stimulus_class};
        correctClass=strcmp(classResp,classStim);
        L=contrastInfo(indCont).likelihood;
        decode_ori=contrastInfo(indCont).decode_ori;
        s=contrastInfo(indCont).stimulus;
        [~,~,s_hat]=getLFStat(L,decode_ori);
        eml=abs(s_hat-s');
        sigma_l=contrastInfo(indCont).gaussFitParam(2,:);
        
        edges=prctile(sigma_l,prcPts);
        binc=zeros(1,length(edges)-1);
        perf_list=zeros(1,length(edges)-1);
        perf_list2=zeros(size(perf_list));
        for ind=1:length(edges)-1
            trials=(sigma_l>edges(ind) & sigma_l<=edges(ind+1));
            subCorrect=correctClass(trials);
            eml_sub=eml(trials);
            edgeEML=prctile(eml_sub,prcEML);
            for indEML=1:length(edgeEML)-1
                subtrials=(eml_sub>edgeEML(indEML) & eml_sub<=edgeEML(indEML+1));
                
                perf=mean(subCorrect(subtrials));
                if(indEML==1)
                    perf_list(ind)=perf;
                else
                    perf_list2(ind)=perf;
                    
                end
            end
            binc(ind)=mean(sigma_l(trials));
        end
        match=find(contList==contVal);
        distrPrcByContrast{match}=[distrPrcByContrast{match}; perf_list];
        distrPrcByContrast2{match}=[distrPrcByContrast2{match};perf_list2];
        
        subplot(1,3,1);
        h1=plot(binc,perf_list,'-o','color',line_color(match,:));
        plot(binc,perf_list2,'--x','color',line_color(match,:));
        legend_handle1(match)=h1;
        hold on;
        subplot(1,3,2);
        h2=plot(prcCenter,perf_list,'-o','color',line_color(match,:));
        plot(prcCenter,perf_list2,'--x','color',line_color(match,:));
        legend_handle2(match)=h2;
        hold on;
    end
end
subplot(1,3,1);
xlabel('sigma_L');
ylabel('Performance');
title('Performance vs sigma_L');
legend(legend_handle1,legend_label);
subplot(1,3,2);
xlabel('sigma_L percentile (%)');
ylabel('Performance');
title('Performance vs sigma_L percentile');
legend(legend_handle2,legend_label);

subplot(1,3,3);
legend_handle=[];
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
hold off;
for indCont=1:length(contList)
    avgPerf=mean(distrPrcByContrast{indCont});
    semPerf=std(distrPrcByContrast{indCont})./sqrt(size(distrPrcByContrast{indCont},1));
    avgPerf2=mean(distrPrcByContrast2{indCont});
    semPerf2=std(distrPrcByContrast2{indCont})./sqrt(size(distrPrcByContrast2{indCont},1));
    h=plot(prcCenter,avgPerf,'color',line_color(indCont,:));
    hold on;
    plot(prcCenter,avgPerf2,'--','color',line_color(indCont,:));
    %%errorShade(prcCenter,avgPerf,semPerf,colors(indCont,:),0.2);
    legend_handle=[legend_handle h];
    hold on;
end
xlabel('sigma_L percentile (%)');
ylabel('Performance');
title('Average sigma of fitted BP-model vs sigma_L percentile');
legend(legend_handle,legend_label);
%% Analyze performance according to the sigma_L vs error_rate Ver2!


figure;
line_color=lines;
legend_label={};
allContrastInfo=[sessionData.contrast_info];
contList=sort(unique([allContrastInfo.contrast]),2,'descend');
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
legend_handle1=zeros(size(contList));
legend_handle2=legend_handle1;


prcPts=0:33.3:100;
prcCenter=0.5*(prcPts(1:end-1)+prcPts(2:end));
prcEML=[0:50:100];
prcEMLC=0.5*(prcPts(1:end-1)+prcPts(2:end));
distrPrcByContrast=cell(1,length(contList));
distrPrcByContrast2=cell(1,length(contList));
sessions=1:9;
for indSession=sessions
    contrastInfo=sessionData(indSession).contrast_info;
    trialInfo=sessionData(indSession).trial_info;
    for indCont=1:length(contrastInfo)
        contVal=contrastInfo(indCont).contrast;
        trialIdx=contrastInfo(indCont).trials;
        classResp={trialInfo(trialIdx).selected_class};
        classStim={trialInfo(trialIdx).stimulus_class};
        correctClass=strcmp(classResp,classStim);
        L=contrastInfo(indCont).likelihood;
        decode_ori=contrastInfo(indCont).decode_ori;
        s=contrastInfo(indCont).stimulus;
        [~,~,s_hat]=getLFStat(L,decode_ori);
        eml=abs(s_hat-s');
        sigma_l=contrastInfo(indCont).gaussFitParam(2,:);
        
        edges=prctile(sigma_l,prcPts);
        binc=zeros(1,length(edges)-1);
        perf_list=zeros(1,length(edges)-1);
        perf_list2=zeros(size(perf_list));
        for ind=1:length(edges)-1
            trials=(sigma_l>edges(ind) & sigma_l<=edges(ind+1));
            subCorrect=correctClass(trials);
            eml_sub=eml(trials);
            edgeEML=prctile(eml_sub,prcEML);
            for indEML=1:length(edgeEML)-1
                subtrials=(eml_sub>edgeEML(indEML) & eml_sub<=edgeEML(indEML+1));
                
                perf=mean(subCorrect(subtrials));
                if(indEML==1)
                    perf_list(ind)=perf;
                else
                    perf_list2(ind)=perf;
                    
                end
            end
            binc(ind)=mean(sigma_l(trials));
        end
        match=find(contList==contVal);
        distrPrcByContrast{match}=[distrPrcByContrast{match}; perf_list];
        distrPrcByContrast2{match}=[distrPrcByContrast2{match};perf_list2];
        
    end
end

legend_handle=[];
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
hold off;
for indCont=1:length(contList)
    avgPerf=mean(distrPrcByContrast{indCont});
    semPerf=std(distrPrcByContrast{indCont})./sqrt(size(distrPrcByContrast{indCont},1));
    avgPerf2=mean(distrPrcByContrast2{indCont});
    semPerf2=std(distrPrcByContrast2{indCont})./sqrt(size(distrPrcByContrast2{indCont},1));
    hs=subplot(1,length(contList),indCont);
    plot(prcCenter,avgPerf,'color',line_color(1,:));
    h1=errorShade(prcCenter,avgPerf,semPerf,colors(1,:),0.4);
    hold on;
    plot(prcCenter,avgPerf2,'--','color',line_color(2,:));
    h2=errorShade(prcCenter,avgPerf2,semPerf,colors(2,:),0.4);
    hold on;
    hl=legend([h1,h2],{'Low eml','High eml'});
    set(hl,'Box','off');
    title(sprintf('Contrast = %2.2f',contList(indCont)));
    xlabel('sigma_L');
    ylim([0.57,0.8]);
    set(hs,'Box','off');
    if(indCont==1)
        ylabel('Performance');
    end
end

%% sigma_eML (standard dev of error in ML estimate) vs sigma_L of likelihood function
figure;
line_color=lines;
legend_label={};
allContrastInfo=[sessionData.contrast_info];
contList=sort(unique([allContrastInfo.contrast]),2,'descend');
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
legend_handle1=zeros(size(contList));
legend_handle2=legend_handle1;


prcPts=0:10:100;
prcCenter=0.5*(prcPts(1:end-1)+prcPts(2:end));
distrPrcByContrast=cell(1,length(contList));
sessions=1:9;
for indSession=sessions
    contrastInfo=sessionData(indSession).contrast_info;
    trialInfo=sessionData(indSession).trial_info;
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
        
        
        edges=prctile(sigma_l,prcPts);
        binc=zeros(1,length(edges)-1);
        sigma_eml=zeros(size(binc));
        
        for ind=1:length(edges)-1
            trials=(sigma_l>edges(ind) & sigma_l<=edges(ind+1));
            binc(ind)=mean(sigma_l(trials));
            eml_sub=e_ml(trials);
            sigma_eml(ind)=std(eml_sub);
            
        end
        match=find(contList==contVal);
        distrPrcByContrast{match}=[distrPrcByContrast{match}; sigma_eml];
        
        subplot(1,3,1);
        h1=plot(binc,sigma_eml,'-o','color',line_color(match,:));
        legend_handle1(match)=h1;
        hold on;
        subplot(1,3,2);
        h2=plot(prcCenter,sigma_eml,'-o','color',line_color(match,:));
        legend_handle2(match)=h2;
        hold on;
    end
end
h=subplot(1,3,1);
set(h,'Box','off');
xlabel('sigma_L');
ylabel('sigma_{eml}');
title('sigma_{eml} vs sigma_L');
h=legend(legend_handle1,legend_label);

h=subplot(1,3,2);
set(h,'Box','off');
xlabel('sigma_L percentile (%)');
ylabel('sigma_{eml}');
title('sigma_{eml} vs sigma_L Percentile');
h=legend(legend_handle2,legend_label);



hs=subplot(1,3,3);
legend_handle=[];
legend_label=arrayfun(@(x){sprintf('Contrast = %0.3f',x)},contList);
hold off;
for indCont=1:length(contList)
    avgPerf=mean(distrPrcByContrast{indCont});
    semPerf=std(distrPrcByContrast{indCont})./sqrt(size(distrPrcByContrast{indCont},1));
    h=plot(prcCenter,avgPerf,'color',line_color(indCont,:));
    h=errorbar(prcCenter,avgPerf,semPerf,'Color',colors(indCont,:));
    legend_handle=[legend_handle h];
    hold on;
end
set(hs,'Box','off');
xlabel('sigma_L percentile (%)');
ylabel('sigma_{eml}');
title('Averaged sigma_{eml} vs sigma_L Percentile');
h=legend(legend_handle,legend_label);


