for idx=1:10
L = sessionData(idx).cvResults.likelihood;
ori = [sessionData(idx).trial_info.orientation];
[mu, sigma, fitL] = ClassifierModel.fitGaussToLikelihood(decodeOri, L);
[bin_mu, bin_s, n_s, binc] = nanBinnedStats(ori, mu, edges);
errorbar(binc, bin_mu, bin_s./sqrt(n_s));
%%
fits = 1:61;
sessions = sessionData(1:61);
cvAll = [sessions.cvResults];
all_trials = vertcat(sessions.trial_info);
L = [cvAll.likelihood];
ori = vertcat(all_trials.orientation);
contrast = [all_trials.contrast];
[mu, sigma] = ClassifierModel.fitGaussToLikelihood(decodeOri, L);
edges = linspace(245,295,21);
%%
for idx=5
    edges = linspace(245,295,21);
    session = sessionData(idx);
    cvData = session.cvResults;
    trial_info = [session.trial_info];
    contrast = [trial_info.contrast];
    s = [trial_info.orientation];
    L = cvData.likelihood;
    [mu, sigma] = ClassifierModel.getMeanStd(decodeOri, L);
    contrast_values = [cvData.cvContrast.contrast];
    line_color = lines;
    figure;
    
    for idxCont = 1:length(contrast_values)
        pos = find(abs(contrast - contrast_values(idxCont)) < 0.00001);
        sigma_sub = sigma(pos);
        ssub = s(pos);
        [sigma_mu, sigma_s, sigma_n, binc] = nanBinnedStats(ssub,sigma_sub, edges);
        hold on;
        errorbar(binc, sigma_mu, sigma_s./sqrt(sigma_n), 'color',line_color(idxCont, :));
    end
    legend(contrast_values);
end
%%
sessions = sessionData;
cvAll = [sessions.cvResults];
all_trials = vertcat(sessions.trial_info);
L = [cvAll.likelihood];
ori = vertcat(all_trials.orientation);
contrast = [all_trials.contrast];
[mu, sigma] = ClassifierModel.getMeanStd(decodeOri, L);
edges = linspace(245,295,21);
%%
[bin_mu, bin_s, n_s, binc] = nanBinnedStats(ori, mu, edges);
[sigma_mu, sigma_s, sigma_n, binc] = nanBinnedStats(ori, sigma, edges);
%%
x = linspace(220,320,100);
figure;
errorbar(binc, bin_mu, bin_s./sqrt(n_s));
hold on;
plot(x, x, 'k--');
%%
x = linspace(220,320,100);
figure;
errorbar(binc, sigma_mu, sigma_s./sqrt(sigma_n));
hold on;
ylim([0, 8]);
%plot(x, x, 'k--');
%%