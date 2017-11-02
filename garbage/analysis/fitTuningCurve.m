for idxSession = 8
    data = sessionData(idxSession);

    trialInfo = data.trial_info;
    all_counts = cat(2,trialInfo.counts);             
    all_orientation = [trialInfo.orientation];
    all_orientation=mod(all_orientation,180)+180;
    all_contrast = [trialInfo.contrast];
    all_resp = {trialInfo.selected_class};

    maxCont = max(all_contrast);
    idx = all_contrast == maxCont;

    gpenc = ClassifierModel.CoderDecoder.ContrastAdjustedGPDPCEncoder(96);
    gpenc.train(all_orientation(idx), all_contrast(idx), all_counts(:,idx));
    
    plot(gpenc);
    set(gcf, 'name', num2str(idxSession));

end


