figure;
%%
subplot(1,3,1);
hold on;
fits = [sessionData.simpleFitResults];
a = [fits(10).cvContrast];
d = a(1).dataSet.decodeOri;
colors = lines;
lg_s = {};
for idxC = 1:length(a)
    L = a(idxC).dataSet.likelihood;
    cont = a(idxC).contrast;
    [~, pos]= max(L, [], 1);
    peak = d(pos);
    d_all = [];
    L_all = [];
    for idx = 1:size(L,2)
        d_all = [d_all (d-peak(idx))];
        L_all = [L_all L(:,idx)'];
    end
    bine = linspace(-70,70,100);
    [mu, ~,~,binc] = nanBinnedStats(d_all, L_all, bine);
    v =sum(mu);
    plot(binc, mu/(max(v)), 'color', colors(idxC, :));
    lg_s = [lg_s, {sprintf('contrast = %.1f%%', cont*100)}];
    
end
xlim([-20, 20]);
xlabel('Orientation relative to peak (deg)');
legend(lg_s);
%%
% subplot(1,3,1);
% cla;
% hold on;
% fits = [sessionData.simpleFitResults];
% a = [fits(8).cvContrast];
% d = a(1).dataSet.decodeOri;
% idx = [4,4,5];
% colors = lines;
% lg_s = {};
% for idxC = 1:length(a)
%     L = a(idxC).dataSet.likelihood(:,idx(idxC));
%     cont = a(idxC).contrast;
%     [~, pos]= max(L, [], 1);
%     v = sum(L);
%     peak = d(pos);
%     peak=0;
%     plot(d - peak, L/v, 'color', colors(idxC,:));
%     lg_s = [lg_s, {sprintf('contrast = %d%%', cont*100)}];
%     
% end
% %xlim([-30, 30]);
% ylim([0, 0.2]);
% xlabel('Orientation relative to peak (deg)');
% legend(lg_s);


%%

fits = [sessionData.simpleFitResults];
cvContrast = [fits.cvContrast];
contrasts = [cvContrast.contrast] * 100;
mu_s = zeros(1, length(cvContrast));
for idx = 1:length(cvContrast)
    z = cvContrast(idx);
    data = z.dataSet;
    decodeOri = data.decodeOri;
    L = data.likelihood;
    [~, s] = ClassifierModel.getMaxStd(decodeOri, L);
    %[~, s]=ClassifierModel.fitGaussToLikelihood(decodeOri, L);
    mu_s(idx) = mean(s);
end
uniq_c = unique(contrasts);
mu_u = zeros(1, length(uniq_c));
sigma_u = zeros(1, length(uniq_c));
sem_u = zeros(1, length(uniq_c));
for idx = 1:length(uniq_c)
    c = uniq_c(idx);
    pos = abs(contrasts - c) < 0.00001;
    mu_u(idx)=mean(mu_s(pos));
    sigma_u(idx)= std(mu_s(pos));
    sem_u(idx) = sigma_u(idx) ./ sqrt(sum(pos));
    
end
%binEdges = -0.1:0.05:1;
%[mu_all, ~, ~, binc]=nanBinnedStats(contrasts, mu_s, binEdges);
%figure;plot(contrasts, mu_s,'o');
%figure;plot(binc, mu_all);
subplot(1,3,2);
errorbar(uniq_c, mu_u, sem_u, 'o');

s=regstats(mu_u, log(uniq_c), 'linear');
p = s.tstat.pval(2);
rsq = s.rsquare;
beta = s.beta(end:-1:1);
c_test = logspace(-1, 2.2, 100);
exp_s=polyval(beta, log(c_test));
xlim([10^-2.5, 1.1]);
xlabel('Contrast (%)');
ylabel('Width of likelihood function (deg)');
title(sprintf('P-value: %f, Rsq: %f', p, rsq));
hold on;
plot(c_test, exp_s, 'r--');

set(gca,'xscale','log');
xlim([0.2,150]);
set(gca,'xtick', [0.5, 1, 5, 10, 50, 100]);



%%
result =[];
for idx=1:length(sessionData)
    result = [result sessionData(idx).simpleFitResults.cvContrast];
end

summary = [];
contrasts=[result.contrast];
for idxResult = 1:length(result)
    models = result(idxResult).modelFits;
    summary = [summary; [models.trainLL]];
end

selected = summary(:,[3, 5, 6]);

peak = selected(:,1) - selected(:,3);

%% Peak only
subplot(1,3,3);
binEdges = [0.001,0.015, 0.025, 0.055, 0.16, 0.32, 1];
%binEdges = unique(prctile(contrasts, logspace(-3,2,300)));
%binEdges = logspace(log10(0.005), log10(0.32),10);
[peakMu, peakStd, peakN, binc,bins]=nanBinnedStats(contrasts, peak, binEdges);
peakSEM = peakStd ./ sqrt(peakN);
errorbar(binc*100, peakMu, peakSEM, 'r');

xlabel('Contrast (%)');
ylabel('Trial Averaged Difference in log-likelihood relative to the Full-likelihood model');
%legend({'Mean only', 'Mean and Standard deviation'})
set(gca, 'xscale', 'log');
xlim([0.2,150]);
set(gca,'xtick', [0.5, 1, 5, 10, 50, 100]);

