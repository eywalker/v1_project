%% Fetch the data!
tom = cd_lc.LCTrainSets * (cd_dataset.DataSets * cd_dataset.ContrastSessionDataSet & 'subject_id = 21');
leo = cd_lc.LCTrainSets * (cd_dataset.DataSets * cd_dataset.ContrastSessionDataSet & 'subject_id = 3');


tomPDiff = fetch(pro(cd_analysis.BinaryReadout & 'lc_id = 1', 'lc_id -> model1', 'prop_correct -> p1') * pro(cd_analysis.BinaryReadout & 'lc_id = 7', 'lc_id -> model2', 'prop_correct -> p2') * tom, '*');
leoPDiff = fetch(pro(cd_analysis.BinaryReadout & 'lc_id = 1', 'lc_id -> model1', 'prop_correct -> p1') * pro(cd_analysis.BinaryReadout & 'lc_id = 7', 'lc_id -> model2', 'prop_correct -> p2') * leo, '*');

%% Reorganize the data
tomP1 = [tomPDiff.p1];
tomP2 = [tomPDiff.p2];
tomCont = cellfun(@(x) str2num(x), {tomPDiff.dataset_contrast});

leoP1 = [leoPDiff.p1];
leoP2 = [leoPDiff.p2];
leoCont = cellfun(@(x) str2num(x), {leoPDiff.dataset_contrast});

%% Common figure settings
fs = 18;
fs_title = 20;
font = 'Arial';
c = min(0.005 * (2.^(0:8)), 1);
c = [2 * c(1) - c(2), c, 2 * c(end)-c(end-1)];
edges = 0.5 * (c(1:end-1) + c(2:end));

%% Generate scatter plot for two models

figure('Color', [1,1,1]);

x = linspace(0, 1, 100);

ax = subplot(1,2,1);
hold on;
scatter(tomP1, tomP2, 40, log(tomCont), 'filled');
axis equal
plot(x, x, 'k--');
xlim([0.5, 1]);
ylim([0.5, 1]);
set(ax, 'xtick', 0.5:0.1:1);
set(ax, 'ytick', 0.5:0.1:1);
set(ax, 'CLim', [-3, 0]);
set(ax, 'FontName', font, 'FontSize', fs);
title('Monkey T', 'FontName', font,'FontSize', fs_title);
xlabel('Non-Bayesian model: {\itP}(Correct)');
ylabel('Bayesian model: {\itP}(Correct)');
h = colorbar;
set(h, 'Ticks', [-3:0]);
set(h, 'TickLabels', 10.^[-3:0] * 100);

ax = subplot(1,2,2);
hold on;
scatter(leoP1, leoP2, 40, log(leoCont), 'filled');
axis equal
plot(x, x, 'k--');
xlim([0.5, 1]);
ylim([0.5, 1]);
set(ax, 'xtick', 0.5:0.1:1);
set(ax, 'ytick', 0.5:0.1:1);
set(ax, 'CLim', [-3, -0]);
set(ax, 'FontName', font, 'FontSize', fs);
title('Monkey L', 'FontName', font,'FontSize', fs_title);
xlabel('Non-Bayesian model: {\itP}(Correct)');
ylabel('Bayesian model: {\itP}(Correct)');
h = colorbar;
ylabel(h, 'Contrast (%)', 'rot', -90);
set(h, 'Ticks', [-3:0]);
set(h, 'TickLabels', 10.^[-3:0] * 100);

%% Contrast vs mean probability correct for two models
linec = lines;
figure('color', [1,1,1]);
nSlots = 10;
allCont = [leoCont, tomCont];



% plot for Tom

ax = subplot(1,2,1);
[mu, s, n, binc] = nanBinnedStats(tomCont, tomP1, edges);
errorbar(binc, mu, s./sqrt(n), 'color',linec(1,:));
h1=errorShade(binc, mu, s./sqrt(n), linec(1,:), 0.5);
hold on;
[mu, s, n, binc] = nanBinnedStats(tomCont, tomP2, edges);
errorbar(binc, mu, s./sqrt(n), 'color',linec(2,:));
h2=errorShade(binc, mu, s./sqrt(n), linec(2,:), 0.5);
legend([h1, h2]);

set(ax, 'FontName', font, 'FontSize', fs);
set(ax, 'xscale', 'log');
set(ax, 'Box', 'off');
xlabel('Contast (%)');
ylabel('{\itP}(Correct)');
xlim([0.002, 1]);
ylim([0.5, 0.9]);
set(ax, 'xtick', 10.^[-3:0]);
set(ax, 'xticklabel', 10.^[-3:0] * 100);
set(ax, 'ytick', 0.5:0.1:0.9);
title('Monkey T', 'FontName', font, 'FontSize', fs_title);

% plot for Leo
ax = subplot(1,2,2);
[mu, s, n, binc] = nanBinnedStats(leoCont, leoP1, edges);

errorbar(binc, mu, s./sqrt(n), 'color',linec(1,:));
h1=errorShade(binc, mu, s./sqrt(n), linec(1,:), 0.5);
hold on;
[mu, s, n, binc] = nanBinnedStats(leoCont, leoP2, edges);
errorbar(binc, mu, s./sqrt(n), 'color',linec(2,:));
h2=errorShade(binc, mu, s./sqrt(n), linec(2,:), 0.5);
legend([h1, h2]);

set(ax, 'FontName', font, 'FontSize', fs);
set(ax, 'xscale', 'log');
set(ax, 'Box', 'off');
xlabel('Contast (%)');
ylabel('{\itP}(Correct)');
xlim([0.002, 1]);
ylim([0.5, 0.9]);
set(ax, 'xtick', 10.^[-3:0]);
set(ax, 'xticklabel', 10.^[-3:0] * 100);
set(ax, 'ytick', 0.5:0.1:0.9);
title('Monkey L', 'FontName', font, 'FontSize', fs_title);

%% Difference between modesl
linec = lines;
figure('color', [1,1,1]);
nSlots = 10;
allCont = [leoCont, tomCont];
x = linspace(0.001, 1, 100);
y = zeros(size(x));

% plot for Tom
ax = subplot(2,1,1);
tomDelta = tomP2 - tomP1;
[mu, s, n, binc] = nanBinnedStats(tomCont, tomDelta, edges);
errorbar(binc, mu, s./sqrt(n), 'color',linec(1,:), 'linewidth', 2);
hold on;
plot(x, y, 'k--');

set(ax, 'FontName', font, 'FontSize', fs);
set(ax, 'xscale', 'log');
set(ax, 'Box', 'off');
xlabel('Contast (%)');
ylabel('Difference in {\itP}(Correct)');
xlim([0.002, 1]);
ylim([-0.01, 0.06]);
title('Monkey T', 'FontName', font, 'FontSize', fs_title);
set(ax, 'XTick', [0.01, 0.1, 1]);
set(ax, 'XTickLabel', [1, 10, 100]);
set(ax, 'YTick', -0.01:0.01:0.06);

ax = subplot(2,1,2);
leoDelta = leoP2 - leoP1;
[mu, s, n, binc] = nanBinnedStats(leoCont, leoDelta, edges);
errorbar(binc, mu, s./sqrt(n), 'color',linec(1,:), 'linewidth', 2);
hold on;
plot(x, y, 'k--');

set(ax, 'FontName', font, 'FontSize', fs);
set(ax, 'xscale', 'log');
set(ax, 'Box', 'off');
xlabel('Contast (%)');
ylabel('Difference in {\itP}(Correct)');
xlim([0.002, 1]);
ylim([-0.01, 0.06]);
title('Monkey L', 'FontName', font, 'FontSize', fs_title);
set(ax, 'XTick', [0.01, 0.1, 1]);
set(ax, 'XTickLabel', [1, 10, 100]);
set(ax, 'YTick', -0.01:0.01:0.06);

