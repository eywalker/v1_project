%% Tuning curve plots
close all;
for SESSION_IDX = 1:10
    sigmaA = 3;
    sigmaB = 15;
    sCenter = 270;
    decodeOri = [220:0.5:320];
    %SESSION_IDX = 3;
    % Tuning curve plot
    trialInfo = sessionData(SESSION_IDX).trial_info;

    all_counts = cat(2,trialInfo.counts);             
    all_orientation = [trialInfo.orientation];
    all_orientation=mod(all_orientation,180)+180;
    all_contrast = [trialInfo.contrast];
    all_resp = {trialInfo.selected_class};

    contList = sort(unique(all_contrast)); % list of all contrasts
    contPrior = ones(size(contList)) ./ length(contList); %assume equal-probability for each contrast

    gpCurve = ClassifierModel.CoderDecoder.ContrastAdjustedGPDPCEncoder(96);
    gpCurve.train(all_orientation, all_contrast, all_counts); % train GP tuning curves

    gpCurve.plot()
    set(gcf,'name',sprintf('Session %d', SESSION_IDX),'numbertitle','off');
end

%% Run this before all!
SESSION_IDX = 1;

% experiment configuration
sigmaA = 3;
sigmaB = 15;
sCenter = 270;
decodeOri = [220:0.5:320];
% extract details trial info

trialInfo = sessionData(SESSION_IDX).trial_info;
all_counts = cat(2,trialInfo.counts);             
all_orientation = [trialInfo.orientation];
all_orientation=mod(all_orientation,180)+180;
all_contrast = [trialInfo.contrast];
all_resp = {trialInfo.selected_class};

contList = sort(unique(all_contrast)); % list of all contrasts
contPrior = ones(size(contList)) ./ length(contList); %assume equal-probability for each contrast

% train tuning curves and obtain likelihood for all contrasts
fprintf('Training tuning curves...\n');

gpCurve = ClassifierModel.CoderDecoder.ContrastAdjustedGPDPCEncoder(96);
gpCurve.train(all_orientation, all_contrast, all_counts); % train GP tuning curves


UNIT_THR = -2.5;
pnCodec = ClassifierModel.CoderDecoder.PoissonNoisePPCodec(gpCurve); % wrap GP tuning curves with Poisson noise
logLAll = pnCodec.getLogLikelihood(all_orientation, all_contrast, all_counts); % assess quality of tuning curve
unitLL = mean(logLAll, 2);
goodUnits = (unitLL > UNIT_THR);
pnCodec.baseEncoder = gpCurve.restrict(goodUnits); % remove channels with poor tuning curve fit

L = pnCodec.getLikelihoodDistrWithContrastPrior(decodeOri, contList, contPrior, all_counts(goodUnits,:)); % decode likelihood
%% Plot sample firing rate to likelihood mapping
figure;
S = gpCurve.encode(decodeOri);
prefOri = S * decodeOri(:) ./ sum(S,2);
%[~, pos]=max(gpCurve.encode(decodeOri),[],2);
%prefOri = decodeOri(pos);
TRIAL_IND = 890;
subplot(1,2,1);
stem(prefOri(goodUnits),all_counts(goodUnits,TRIAL_IND));
xlabel('Preferred orientation');
ylabel('Spike counts');
xlim([220,320]);
subplot(1,2,2);
plot(decodeOri, L(:, TRIAL_IND));
xlabel('Hypothesized Orientation');
ylabel('Likelihood');
xlim([220, 320]);

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

%% Plot raw map
figure;
for indCont=1:length(contList)
    contVal=contList(indCont);
    pos = find(all_contrast == contVal);
    
    s = all_orientation(pos);
    lc = L(:, pos);
    
    [s,idx]=sort(s);
    subplot(1,length(contList),indCont);
    imagesc(1:length(s),decodeOri, lc(:,idx));
    hold on;
    plot(1:length(s),s,'k','LineWidth',2);
    set(gca,'CLim',[0 0.3]);
    title(sprintf('Contrast = %0.3f',contVal));
    xlabel('Trial');
    ylabel('s (deg)');
    
end

%%
%% Fit BP model for different values of sigma_l per contrast
figure;
line_color=lines;
legend_label={};
bpl=ClassifierModel.BehavioralClassifier.BPLClassifier2(sigmaA, sigmaB, sCenter);
for indCont=1:length(contList)
    contVal=contList(indCont);
    trialIdx = find(all_contrast == contVal);
    orientation = all_orientation(trialIdx);
    classResp=all_resp(trialIdx);
    lc = L(:, trialIdx);
    [~,sigma_l]=ClassifierModel.getMeanStd(decodeOri,lc);
    
    prcPts=0:10:100;
    
    prcCenter=0.5*(prcPts(1:end-1)+prcPts(2:end));
    edges=prctile(sigma_l,prcPts);
    binc=zeros(length(edges)-1,1);
    priorA=zeros(size(binc));
    sigma_x=zeros(size(binc));
    for ind=1:length(edges)-1
        trials=(sigma_l>edges(ind) & sigma_l<=edges(ind+1));
        binc(ind)=mean(sigma_l(trials));
        ori_sub=orientation(trials);
        resp_sub=classResp(trials);
        bpl.train(ori_sub, [], resp_sub, 30);
        sigma_x(ind) = bpl.sigma;
    end
    disp(binc);
    disp(sigma_x);
    plot(binc,sigma_x,'-o','color',line_color(indCont,:));
    hold on;
    legend_label=[legend_label,sprintf('Contrast = %0.3f',contVal)];
end
xlabel('sigma_l');
ylabel('sigma');
title('sigma of fitted BP-model vs sigma_L');
legend(legend_label);