
%% Add new session data (the incremental add-up feature not implemented yet)
sessionData=fetch(class_discrimination.ClassDiscriminationExperiment * ephys.SpikesAlignedSet);
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

h=waitbar(0,sprintf('Calculating tuning curves and likelihood functions: %d ouf of %d completed',0,length(sessionData)));
for idxSess=1:length(sessionData)
    trialInfo=sessionData(SESSION_NUM).trial_info;
    counts = cat(2,trialInfo.counts);             
    orientation = [trialInfo.orientation];
    orientation=mod(orientation,180)+180;
    contrast = [trialInfo.contrast];

    %% Approximate reliability of each unit
    contrastList=sort(unique(contrast(:)),1,'descend');
    trials = find(contrast == contrastList(1));
    F = gpRegTuningFunctions(orientation(trials)',counts(:,trials));
    unitLL=sum(log(poisspdf(counts(:,trials)',F)));
    %% Slect units according to sum log likelihood for each unit
    val=sort(unitLL);
    valReg=val(val ~= -Inf);
    perc=prctile(valReg,[25,40]);
    %units=find(unitLL>=1.1*mean(perc));
    units=find(unitLL>-5000);
    disp(size(units));
    
    %% Calculate PPC likelihood for each contrast
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
    waitbar(0,h,sprintf('Calculating tuning curves and likelihood functions: %d ouf of %d completed',idxSess,length(sessionData)));
end