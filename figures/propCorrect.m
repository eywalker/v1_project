tom = cd_lc.LCTrainSets * (cd_dataset.DataSets * cd_dataset.ContrastSessionDataSet & 'subject_id = 21');
leo = cd_lc.LCTrainSets * (cd_dataset.DataSets * cd_dataset.ContrastSessionDataSet & 'subject_id = 3');

tomPDiff = fetch(pro(cd_analysis.BinaryReadout & 'lc_id = 1', 'lc_id -> model1', 'prop_correct -> p1') * pro(cd_analysis.BinaryReadout & 'lc_id = 7', 'lc_id -> model2', 'prop_correct -> p2') * tom, '*');
leoPDiff = fetch(pro(cd_analysis.BinaryReadout & 'lc_id = 1', 'lc_id -> model1', 'prop_correct -> p1') * pro(cd_analysis.BinaryReadout & 'lc_id = 7', 'lc_id -> model2', 'prop_correct -> p2') * leo, '*');

%% generate scatter plot for two models

%figure('Position', [0, 0, 600, 600]);
figure('Color', [1,1,1]);
tomP1 = [tomPDiff.p1];
tomP2 = [tomPDiff.p2];
tomCont = cellfun(@(x) str2num(x), {tomPDiff.dataset_contrast});

leoP1 = [leoPDiff.p1];
leoP2 = [leoPDiff.p2];
leoCont = cellfun(@(x) str2num(x), {leoPDiff.dataset_contrast});

x = linspace(0, 1, 100);

ax = subplot(1,2,1);
hold on;
scatter(tomP1, tomP2, 30, log(tomCont), 'filled');
plot(x, x, 'k--');
xlim([0.5, 1]);
ylim([0.5, 1]);
set(ax, 'xtick', 0.5:0.1:1);
set(ax, 'ytick', 0.5:0.1:1);
set(ax, 'CLim', [-3, 0]);
title('Monkey T');
xlabel('Non-Bayesian model: \it {p} (Correct)');
ylabel('Bayesian model: \it {p} (Correct)');
h = colorbar;
set(h, 'Ticks', [-3:0]);
set(h, 'TickLabels', 10.^[-3:0] * 100);

ax = subplot(1,2,2);
hold on;
scatter(leoP1, leoP2, 30, log(leoCont), 'filled');
plot(x, x, 'k--');
xlim([0.5, 1]);
ylim([0.5, 1]);
set(ax, 'xtick', 0.5:0.1:1);
set(ax, 'ytick', 0.5:0.1:1);
set(ax, 'CLim', [-3, -0]);
title('Monkey L');
xlabel('Non-Bayesian model: \it {p} (Correct)');
ylabel('Bayesian model: \it {p} (Correct)');
h = colorbar;
ylabel(h, 'Contrast (%)', 'rot', -90);
set(h, 'Ticks', [-3:0]);
set(h, 'TickLabels', 10.^[-3:0] * 100);