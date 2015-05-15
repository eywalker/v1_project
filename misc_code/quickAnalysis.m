%% summarize
valid = [stim.params.trials.validTrial];
correct = [stim.params.trials.correctResponse];
conditions = [stim.params.trials.condition];
cueClass = [stim.params.conditions.cueClass];
condA = find(cueClass == 2); % cue class = 2 -> narrow distribution (distribution A = red)
targetSetup = [stim.params.conditions.targetSetup];
condRight = find(targetSetup == cueClass); % target setup: 1 = red left green right, 2 = green left red right


ori = {stim.params.trials.trialDirection}; % has to be cell array because some entries will be empty
check = cellfun(@isempty, ori);
[ori{check}] = deal(NaN);
ori = [ori{:}];
valid(check) = 0; % make sure to label trials without appropriate orientation as invalid

expA = ismember(conditions, condA); % trials where resp "A" is expected
expB = ~expA;
expRight = ismember(conditions, condRight); % trials where right response is expected
expLeft = ~expRight;

respA = (expA == correct); % counts expected A and correct, as well as expected B and incorrect
respRight = (expRight == correct); % counts expected Right and correct, as well as expected Left and incorrect
loc = stim.params.constants.location;
%% Check for any overall bias
fprintf('Overall performance: %3.1f%%\n', sum(correct & valid)/sum(valid) * 100);

pA = sum(expA & valid) / sum(valid);
m_pA = sum(respA & valid) / sum(valid);
m_pAgivenA = sum(respA & valid & expA) / sum(valid & expA);
m_pAgivenB = sum(respA & valid & expB) / sum(valid & expB);

fprintf('Actual p(A) = %3.2f\n', pA);
fprintf('p("A") = %3.2f\n', m_pA);
fprintf('p("A"|A) = %3.2f\n', m_pAgivenA);
fprintf('p("A"|B) = %3.2f\n', m_pAgivenB);

pRight = sum(expRight & valid) / sum(valid);
m_pRight = sum(respRight & valid) / sum(valid);
m_pRightGivenRight = sum(respRight & valid & expRight) / sum(valid & expRight);
m_pRightGivenLeft = sum(respRight & valid & expLeft) / sum(valid & expLeft);

fprintf('Actual p(Right) = %3.2f\n', pRight);
fprintf('p("Right") = %3.2f\n', m_pRight);
fprintf('p("Right"|Right) = %3.2f\n', m_pRightGivenRight);
fprintf('p("Right"|Left) = %3.2f\n', m_pRightGivenLeft);

m_pRightGivenA = sum(respRight & valid & expA) / sum(valid & expA);
m_pRightGivenB = sum(respRight & valid & expB) / sum(valid & expB);
fprintf('p("Right"|A) = %3.2f\n', m_pRightGivenA);
fprintf('p("Right"|B) = %3.2f\n', m_pRightGivenB);
fprintf('\n');


%% Check by contrasts
contrastLevels = sort(unique([stim.params.conditions.contrast]));
N_train = 20;
N = length(contrastLevels);
figure;
performance = zeros(size(contrastLevels));
fitLapseRate = zeros(1, N);
fitPriorA = zeros(1, N);
fitSigma = zeros(1, N);
fitAlpha = zeros(1, N);
logl = zeros(1, N);
contrasts = zeros(size(ori));
%model = ClassifierModel.BehavioralClassifier.BPLClassifier(3, 15, 270);
model = ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier(3, 15, 270);
model.fixParameterByName('a');
model.fixParameterByName('beta');
model.beta = -1
model.a = 0
for idx = 1:N
    contVal = contrastLevels(idx);
    condNums = find(abs([stim.params.conditions.contrast] - contVal) < 0.001);
    trials = ismember(conditions, condNums);
    contrasts(trials) = contVal;
    perc = sum(valid & correct & trials) / sum(valid & trials);
    performance(idx) = perc;
    fprintf('For %5.1f%% contrast, performed %3.1f%% correct over %d trials\n', contVal, perc*100, sum(valid&trials));
    
    dataSet = struct();
    orid = ori(valid & trials);
    dataSet.orientation = orid;
    ra = respA(valid & trials);
    rr = {};
    [rr{ra}] = deal('A');
    [rr{~ra}] = deal('B');
    dataSet.selected_class = rr;
    dataSet.contrast = ones(size(orid)) * contVal;
    logl(idx) = model.train(dataSet, N_train);
    fitLapseRate(idx) = model.lapseRate;
    fitPriorA(idx) = model.priorA;
    fitSigma(idx) = model.gamma;

    
    
    % looking at the rate of response 'A' for trials with class 'A' over
    % orientations
    binEdges = linspace(230,310,40);
    [mu_A,s_A,ct_A,binc] = nanBinnedStats(ori(valid&trials&expA), respA(valid&trials&expA), binEdges);
    subplot(3,N,idx);
    
    xc = linspace(230, 310, 1000);
    c = ones(size(xc)) * contVal;
    d.orientation = xc;
    d.contrast = c;
    pRespA = model.pRespA(d);
    
    plot(binc, mu_A, 'ro-');
    
    hold on;
    %errorbar(binc, mu_A, s_A./sqrt(ct_A), 'r');
    plot(xc, pRespA, 'k--');
    title(sprintf('LOC(%d, %d)\n%5.1f%% Contrast: Class A(red) Trials ',loc(1), loc(2),  contVal));
    if(idx==1)
        ylabel('Proportion A(red) response');
    end
    xlim([230, 310]);
    ylim([0,1]);
    
    binEdges = linspace(230,310,40);
    [mu_B,s_B,ct_B,binc] = nanBinnedStats(ori(valid&trials&~expA), respA(valid&trials&~expA), binEdges);
    
    
    % looking at the rate of response 'A' for trials with class 'A' over
    % orientations
    subplot(3,N,idx+N);
    plot(binc, mu_B, 'go-');
    %errorbar(binc, mu_B, s_B./sqrt(ct_B), 'g');
    hold on;
    plot(xc, pRespA, 'k--');
    title(sprintf('%5.1f%% Contrast: Class B(green) Trials',contVal));
    if(idx==1)
        ylabel('Proportion A(red) response');
    end
    xlabel('Stimulus orientation (deg)');
    xlim([230, 310]);
    ylim([0,1]);
    
    
    binEdges = linspace(230,310,40);
    [mu,s,ct,binc] = nanBinnedStats(ori(valid&trials), respA(valid&trials), binEdges);
    
    subplot(3,N,idx+2*N);
    plot(binc, mu, 'bo-');
    %errorbar(binc, mu, s./sqrt(ct), 'b');
    hold on;
    plot(xc, pRespA, 'k--');
    title(sprintf('%5.1f%% Contrast: All Trials', contVal));
    if(idx==1)
        ylabel('Proportion A(red) response');
    end
    xlabel('Stimulus orientation (deg)');
    xlim([230, 310]);
    ylim([0,1]);
    

end
% %% plot fitted parameters across contrasts
% figure;
% subplot(4,1,1);
% plot(contrastLevels, performance * 100, 'o-');
% title('Performance (%)');
% 
% subplot(4,1,2);
% plot(contrastLevels, fitSigma,'o-');
% title('Fitted sigma (noise)');
% 
% subplot(4,1,3);
% plot(contrastLevels, 100*fitLapseRate, 'o-');
% title('Fitted lapse rate (%)');
% 
% subplot(4,1,4);
% plot(contrastLevels, fitPriorA, 'o-');
% title('Prior over "A"');
% xlabel('Contrast (%)');

% %% fit across all contrasts
% 
% contrastLevels = sort(unique([stim.params.conditions.contrast]));
% 
% N = length(contrastLevels);
% figure;
% performance = zeros(size(contrastLevels));
% contrasts = zeros(size(ori));
% modelAll = ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier(3, 15, 270);
% % modelAll.fixParameterByName('alpha');
% % modelAll.alpha = 100;
% 
% for idx = 1:N
%     contVal = contrastLevels(idx);
%     condNums = find(abs([stim.params.conditions.contrast] - contVal) < 0.001);
%     trials = ismember(conditions, condNums);
%     contrasts(trials) = contVal;
%     perc = sum(valid & correct & trials) / sum(valid & trials);
%     performance(idx) = perc;
%     fprintf('For %5.1f%% contrast, performed %3.1f%% correct over %d trials\n', contVal, perc*100, sum(valid&trials));
% end
% 
% dataSet = struct();
% ra = respA(valid);
% rr = {};
% [rr{ra}] = deal('A');
% [rr{~ra}] = deal('B');
% dataSet.selected_class = rr;
% dataSet.contrast = contrasts(valid);
% dataSet.orientation = ori(valid);
% 
% modelAll.train(dataSet, 50);
%     
%     
% for idx = 1:N 
%     contVal = contrastLevels(idx);
%     condNums = find(abs([stim.params.conditions.contrast] - contVal) < 0.001);
%     trials = ismember(conditions, condNums);
%     % looking at the rate of response 'A' for trials with class 'A' over
%     % orientations
%     binEdges = linspace(230,310,40);
%     [mu_A,s_A,ct_A,binc] = nanBinnedStats(ori(valid&trials&expA), respA(valid&trials&expA), binEdges);
%     subplot(3,N,idx);
%     
%     xc = linspace(230, 310, 1000);
%     c = ones(size(xc)) * contVal;
%     d.orientation = xc;
%     d.contrast = c;
%     pRespA = modelAll.pRespA(d);
%     
%     %plot(binc, mu_A, 'r');
%     
%     errorbar(binc, mu_A, s_A./sqrt(ct_A), 'r');
%     hold on;
%     plot(xc, pRespA, 'k--');
%     title(sprintf('%5.1f%% Contrast: Class A(red) Trials ', contVal));
%     if(idx==1)
%         ylabel('Proportion A(red) response');
%     end
%     xlim([230, 310]);
%     ylim([0,1]);
%     
%     binEdges = linspace(230,310,40);
%     [mu_B,s_B,ct_B,binc] = nanBinnedStats(ori(valid&trials&~expA), respA(valid&trials&~expA), binEdges);
%     
%     
%     % looking at the rate of response 'A' for trials with class 'A' over
%     % orientations
%     subplot(3,N,idx+N);
%     %plot(binc, mu_B, 'g');
%     errorbar(binc, mu_B, s_B./sqrt(ct_B), 'g');
%     hold on;
%     plot(xc, pRespA, 'k--');
%     title(sprintf('%5.1f%% Contrast: Class B(green) Trials', contVal));
%     if(idx==1)
%         ylabel('Proportion A(red) response');
%     end
%     xlabel('Stimulus orientation (deg)');
%     xlim([230, 310]);
%     ylim([0,1]);
%     
    
%     binEdges = linspace(230,310,40);
%     [mu,s,ct,binc] = nanBinnedStats(ori(valid&trials), respA(valid&trials), binEdges);
%     
%     subplot(3,N,idx+2*N);
%     %plot(binc, mu, 'b');
%     errorbar(binc, mu, s./sqrt(ct), 'b');
%     hold on;
%     plot(xc, pRespA, 'k--');
%     title(sprintf('%5.1f%% Contrast: All Trials', contVal));
%     if(idx==1)
%         ylabel('Proportion A(red) response');
%     end
%     xlabel('Stimulus orientation (deg)');
%     xlim([230, 310]);
%     ylim([0,1]);
%     
% 
% end
% 
% 
% 



% %%
% valid = [stim.params.trials.validTrial];
% correct = [stim.params.trials.correctResponse];
% 
% conditions = [stim.params.trials.condition];
% condA = find([stim.params.conditions.cueClass]==2);
% ori = {stim.params.trials.trialDirection};
% 
% check=cellfun(@isempty, ori);
% [ori{check}] = deal(NaN);
% ori=[ori{:}];
% valid(check) = 0;
% 
% expA = ismember(conditions, condA);
% respA = (expA == correct);
% 
% color_levels = unique([stim.params.conditions.cueColor]);
% 
% N = length(color_levels);
% figure;
% for idx = 1:N
%     color_val = color_levels(idx);
%     
%     cond_nums = find(abs([stim.params.conditions.cueColor] - color_val) < 0.001);
%     trials = ismember(conditions, cond_nums);
%     
%     perc = sum(valid&correct&trials) / sum(valid&trials);
%     
%     fprintf('For %5.1f%% color, performed %3.1f%% correct over %d trials\n', color_val*100, perc*100, sum(valid&trials));
%     
%     binEdges = linspace(230,310,40);
%     [mu_A,s_A,ct_A,binc] = nanBinnedStats(ori(valid&trials&expA), respA(valid&trials&expA), binEdges);
%     
%     subplot(3,N,idx);
%     %plot(binc, mu_A, 'r');
%     errorbar(binc, mu_A, s_A./sqrt(ct_A), 'r');
%     title(sprintf('%5.1f%% Color: Class A(red) Trials ', color_val*100));
%     if(idx==1)
%         ylabel('Proportion A(red) response');
%     end
%     xlim([230, 310]);
%     ylim([0,1]);
%     
%     binEdges = linspace(230,310,20);
%     [mu_B,s_B,ct_B,binc] = nanBinnedStats(ori(valid&trials&~expA), respA(valid&trials&~expA), binEdges);
%     
%     subplot(3,N,idx+N);
%     %plot(binc, mu_B, 'g');
%     errorbar(binc, mu_B, s_B./sqrt(ct_B), 'g');
%     title(sprintf('%5.1f%% Color: Class B Trials', color_val*100));
%     if(idx==1)
%         ylabel('Proportion A(red) response');
%     end
%     xlabel('Stimulus orientation (deg)');
%     xlim([230, 310]);
%     ylim([0,1]);
%     
%     
%     binEdges = linspace(230,310,20);
%     [mu,s,ct,binc] = nanBinnedStats(ori(valid&trials), respA(valid&trials), binEdges);
%     
%     subplot(3,N,idx+2*N);
%     %plot(binc, mu, 'b');
%     errorbar(binc, mu, s./sqrt(ct), 'b');
%     title(sprintf('%5.1f%% Color: All Trials', color_val*100));
%     if(idx==1)
%         ylabel('Proportion A(red) response');
%     end
%     xlabel('Stimulus orientation (deg)');
%     xlim([230, 310]);
%     ylim([0,1]);
% end
%    
% perc = sum(valid&correct) / sum(valid);
% fprintf('Overall, performed %3.1f%% correct\n', perc*100);

%%
