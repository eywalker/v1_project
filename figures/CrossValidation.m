%% Fetch data for Tom: subject_id = 21
key = 'subject_id = 3'
cv_train = pro((cd_dataset.CrossValidationSets & key) * cd_lc.LCModels, cd_lc.TrainedLC * cd_lc.LCTrainSets * cd_dataset.DataSets * cd_dataset.CVTrainSets, 'avg(lc_train_mu_logl) -> train_mu_logl');
cv_test = pro((cd_dataset.CrossValidationSets & key) * cd_lc.LCModels, cd_lc.LCModelFits * cd_lc.LCTestSets * cd_dataset.DataSets * cd_dataset.CVTestSets, 'avg(lc_test_mu_logl)->test_mu_logl');
sessions = fetch(cd_dataset.CrossValidationSets & key, '*');


data = fetch(cv_train * cv_test, '*');
[data_train, v_lcid] = dj.struct.tabulate(data, 'train_mu_logl', 'lc_id');
[data_test, v_lcid] = dj.struct.tabulate(data, 'test_mu_logl', 'lc_id');
[contrasts, v_lc_id2] = dj.struct.tabulate(data, 'cv_contrast', 'lc_id');
all_contrasts = cellfun(@str2num, contrasts(1,:));
data_train = data_train';
data_test = data_test';

%%
data_train = [];
data_test = [];
all_contrasts = cellfun(@str2num, {sessions.cv_contrast});
all_data = fetch(cv_train * cv_test, '*');
for s=sessions'
    fprintf('.')
    data = dj.struct.join(all_data, s);
    data_train = [data_train; [data.train_mu_logl]];
    data_test = [data_test; [data.test_mu_logl]];
end
fprintf('complete\n');


%% Construct labels and contrast edges
modelNames = fetchn(cd_lc.LCModels, 'lc_label');
modelNames = modelNames(v_lcid);
% make trainLL and testLL num_sessions x num_models
trainLL = data_train;
testLL = data_test;
c = min(0.005 * (2.^(0:8)), 1);
% edges = arrayfun(@(x) prctile(all_contrasts, x), 0:10:100);
% edges = [0, unique(edges), 1];
% edges = 0.5*(edges(1:end-1) + edges(2:end));

%c = unique(all_contrasts);

c = [2 * c(1) - c(2), c, 2 * c(end)-c(end-1)];
edges = 0.5 * (c(1:end-1) + c(2:end));
models_to_plot = [1:3, 17:20, 4:6, 7, 23];
NUM_MODELS = length(models_to_plot);

%% Common figure settings
fs = 14;
fs_title = 16;
font = 'Arial';
%% Contrast vs. mean logL plot for non-shuffled and shuffled
%models_to_plot = [17:20, 7];
%NUM_MODELS = length(models_to_plot);

line_color = lines(length(modelNames));
h = figure(1);
set(h, 'name',  'Fit vs Contrast');
subplot(1, 2, 1);

for idx = 1:length(models_to_plot)
    idxModel = models_to_plot(idx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, trainLL(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
    hold on;
end

x = logspace(-3, 0, 100);
plot(x, ones(size(x)) * log(0.5), 'k--');
title('Fit on train set vs contrast');
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

subplot(1, 2, 2);
for idx = 1:length(models_to_plot)
    idxModel = models_to_plot(idx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, testLL(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n),p, 'color', line_color(idx, :));
    hold on;
end
plot(x, ones(size(x)) * log(0.5), 'k--');
title('Fit on test set vs contrast');
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

%% Contrast vs. mean logL plot for trainset and teset with error bars based on difference w.r.t. target
target = 7;

delta_train = bsxfun(@minus, trainLL, trainLL(:, target));
delta_test = bsxfun(@minus, testLL, testLL(:, target));

line_color = lines(length(modelNames));
h = figure(2);
set(h, 'name',  'Fit vs Contrast with SEM relative to target');
subplot(1, 2, 1);

for idx = 1:length(models_to_plot)
    idxModel = models_to_plot(idx);
    [mu] = nanBinnedStats(all_contrasts, trainLL(:, idxModel), edges);
    [~, s, n, binc] = nanBinnedStats(all_contrasts, delta_train(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
    hold on;
end

x = logspace(-3, 0, 100);
plot(x, ones(size(x)) * log(0.5), 'k--');
title(sprintf('Fit on train set vs contrast relative to %s', modelNames{target}));
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

subplot(1, 2, 2);
for idx = 1:length(models_to_plot)
    idxModel = models_to_plot(idx);
    [mu] = nanBinnedStats(all_contrasts, testLL(:, idxModel), edges);
    [~, s, n, binc] = nanBinnedStats(all_contrasts, delta_test(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n),p, 'color', line_color(idx, :));
    hold on;
end
plot(x, ones(size(x)) * log(0.5), 'k--');
title(sprintf('Fit on test set vs contrast relative to %s', modelNames{target}));
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

%% Contrast vs. mean logL plot for non-shuffled and shuffled with error bars based on difference w.r.t. target
target = 7;

delta_train = bsxfun(@minus, trainLL, trainLL(:, target));
delta_test = bsxfun(@minus, testLL, testLL(:, target));

line_color = lines(length(modelNames));
h = figure(3);
set(h, 'name',  'Difference in fit relative to target vs. Contrast');
subplot(1, 2, 1);

for idx = 1:length(models_to_plot)
    idxModel = models_to_plot(idx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, delta_train(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :), 'linewidth', 2);
    hold on;
end

x = logspace(-3, 0, 100);
plot(x, zeros(size(x)), 'k--');
title(sprintf('Fit on train set vs contrast relative to %s', modelNames{target}));
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

subplot(1, 2, 2);
for idx = 1:length(models_to_plot)
    idxModel = models_to_plot(idx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, delta_test(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n),p, 'color', line_color(idx, :), 'linewidth', 2);
    hold on;
end
plot(x, zeros(size(x)), 'k--');
title(sprintf('Fit on test set vs contrast relative to %s', modelNames{target}));
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

%% Plot the difference between train and test
%models_to_plot = 1:7;
%NUM_MODELS = length(models_to_plot);

h = figure(4);
set(h, 'name',  'Difference in fit: test - train');
delta = testLL - trainLL;

ROW = ceil(sqrt(NUM_MODELS));
COL = ceil(NUM_MODELS / ROW);

for idx = 1:NUM_MODELS
    subplot(ROW, COL, idx);
    modelIdx = models_to_plot(idx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, delta(:, modelIdx), edges);
    h=errorbar(binc, mu, s./sqrt(n), '-x', 'Color', [1, 0.2, 0]);
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    hold on;
    x = logspace(-3,0,100);
    plot(x, zeros(size(x)), 'k-.');
    xlim([edges(1), edges(end)]);
    ylabel('Mean log likelihood relative to train set');
    xlabel('Contrast');
end

%% bar plots for average log likelihood across contrast
%models_to_plot = 1:7;
%NUM_MODELS = length(models_to_plot);

muTestLL = nanmean(testLL);
muTrainLL = nanmean(trainLL);

delta = testLL - trainLL;
stdDelta = std(delta);
semDelta = stdDelta ./ sqrt(size(delta, 1));

h = figure(5);
set(h, 'name',  'Average log likelihood across contrast');

width = 2;
space = 0.5;
left = space/2 + width/2;
for idx = 1:NUM_MODELS
    modelIdx = models_to_plot(idx);
    pos = (idx-1)*(2*width + space) + left;
    h1 = bar(pos, muTrainLL(modelIdx), width);
    hold on;
    
    h2=bar(pos+width, muTestLL(modelIdx),width, 'FaceColor', [1, 0.3, 0]);
    errorbar(pos+width, muTestLL(modelIdx), semDelta(modelIdx), 'k');
    h = ttest(delta(:, modelIdx));
    if ~isnan(h) && h
        h = text(pos + width, muTestLL(modelIdx) - 0.01, '*');
        set(h, 'FontSize', 25);
    end
end
legend([h1, h2], {'Train set', 'Test set'});
right = (space + 2 * width) * NUM_MODELS;
pos = (2*width + space) * [0:NUM_MODELS-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames);
xlim([0, right]);
ylabel('Mean loglikelihood');
%rotateXLabels(gca,90);

%% Plot specific models w.r.t. another one


model_number = 3; % model to compare against
modelIdx = 5; % model to plot
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
edges = arrayfun(@(x) prctile(all_contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
%edges = [0,0.02, 0.05, 0.1, 0.15, 0.85,1];
edges=edges(2:end);
%figure;

subplot(1, 1, 1);
[mu_train, s_train, n_train, binc] = nanBinnedStats(all_contrasts, dTrainLL(:, modelIdx), edges);
[mu_test, s_test, n_test, binc] = nanBinnedStats(all_contrasts, dTestLL(:, modelIdx), edges);
h1=errorbar(binc, mu_train, s_train./sqrt(n_train));
hold on;
h2=errorbar(binc, mu_test, s_test./sqrt(n_test), '-x', 'Color', [1,0.3,0]);
%errorbar(binc, mu_fit, s_fit ./sqrt(n_fit), 'o-r');
set(gca, 'xscale', 'log');
title(modelNames{modelIdx});
xlabel('Contrast');
ylabel(sprintf('Log likelihood relative to %s', modelNames{model_number}));
xlim([edges(1), 1]);
x=logspace(-3,2,100);
plot(x, zeros(size(x)), 'k--');
set(gca, 'xtick', [0.01, 0.1, 1]);
set(gca, 'xticklabel', {'1','10','100'});

legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});




%% Plot all models w.r.t. the first
model_number = 1;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
edges = arrayfun(@(x) prctile(all_contrasts, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
%edges = [0,0.02, 0.05, 0.1, 0.15, 0.85,1];
edges=edges(2:end);
figure;
for modelIdx = 1:NUM_MODELS
    subplot(1, NUM_MODELS, modelIdx);
    [mu_train, s_train, n_train, binc] = nanBinnedStats(all_contrasts, dTrainLL(:, modelIdx), edges);
    [mu_test, s_test, n_test, binc] = nanBinnedStats(all_contrasts, dTestLL(:, modelIdx), edges);
    h1=errorbar(binc, mu_train, s_train./sqrt(n_train));
    hold on;
    h2=errorbar(binc, mu_test, s_test./sqrt(n_test), '-x', 'Color', [1,0.3,0]);
    %errorbar(binc, mu_fit, s_fit ./sqrt(n_fit), 'o-r');
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    xlabel('Contrast');
    ylabel(sprintf('Log likelihood relative to %s', modelNames{model_number}));
    xlim([edges(1), edges(end)]);
end
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});

%% plot the difference in model w.r.t the first
model_number = 1;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));

figure;
for modelIdx = 1:NUM_MODELS
    subplot(1, 5, modelIdx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, dTestLL(:, modelIdx) - dTrainLL(:, modelIdx), edges);
    h1=errorbar(binc, mu, s./sqrt(n), '-x', 'Color', [1, 0.3, 0]);
    x = logspace(-3,0,100);
    hold on;
    plot(x, zeros(size(x)), 'k-.');
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    xlabel('Contrast');
    ylabel(sprintf('Difference in loglikelihood relative to %s', modelNames{model_number}));
    xlim([edges(1), edges(end)]);
end
legend(h1, {'Test set (shuffled)'});

%% bar plots for difference in test and train w.r.t. the specified model
%models_idx_plot = 1:length(modelNames);
%NUM_MODELS = length(models_idx_plot);

target = 3;

dTrainLL = bsxfun(@minus, trainLL, trainLL(:, target));
dTestLL = bsxfun(@minus, testLL, testLL(:, target));

muDTestLL = nanmean(dTestLL);
stdDTestLL = nanstd(dTestLL);
semDTestLL = stdDTestLL/sqrt(size(dTestLL,1));

muDTrainLL = nanmean(dTrainLL);
stdDTrainLL = nanstd(dTrainLL);
semDTrainLL = stdDTrainLL/sqrt(size(dTrainLL,1));

h = figure;
set(h, 'name',  'Average log likelihood relative to a model');

width = 2;
space = 0.5;
left = space/2 + width/2;
hold on;
for idx = 1:NUM_MODELS
    modelIdx = models_to_plot(idx);
    pos = (idx-1)*(2*width + space) + left;
    h1=bar(pos, muDTrainLL(modelIdx), width, 'b');
    errorbar(pos, muDTrainLL(modelIdx), semDTrainLL(modelIdx), 'k');
    hold on;
    
    h = ttest(dTrainLL(:, modelIdx));
    if ~isnan(h)
        mult = sign(mean(dTrainLL(:,modelIdx)));
        %h = text(pos, muDTrainLL(modelIdx) + 3*mult*semDTrainLL(modelIdx), '*');
        plot(pos, muDTrainLL(modelIdx) + 3*mult*semDTrainLL(modelIdx), 'r*', 'markersize', 13);
        %set(h, 'FontSize', 25);
    end
    
    
    h2 = bar(pos+width, muDTestLL(modelIdx), width, 'FaceColor', [1, 0.7, 0]);
    errorbar(pos+width, muDTestLL(modelIdx), semDTestLL(modelIdx), 'k');
    
    h = ttest(dTestLL(:, modelIdx));
    if ~isnan(h)
        mult = sign(mean(dTestLL(:,modelIdx)));
        %h = text(pos + width, muDTestLL(modelIdx) + mult*3*semDTestLL(modelIdx), '*');
        plot(pos + width, muDTestLL(modelIdx) + 2*mult*semDTestLL(modelIdx), 'b*', 'markersize', 13);
        %set(h, 'FontSize', 25);
    end
end

right = (space + 2 * width) * NUM_MODELS;
pos = (2*width + space) * [0:NUM_MODELS-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames(models_to_plot));
set(gca, 'FontName', font, 'FontSize', fs);
xlim([0, right]);
legend([h1, h2], {'Train set', 'Test set'});
ylabel(sprintf('Mean  loglikelihood relative to %s', modelNames{target}));
rotateXLabels(gca, 90);
%% bar plots for difference in test vs train w.r.t. the first
model_number = 3;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));

ddLL = dTestLL - dTrainLL;

muDTestLL = mean(dTestLL);
stdDTestLL = std(dTestLL);
semDTestLL = stdDTestLL/sqrt(size(dTestLL,1));

muDTrainLL = mean(dTrainLL);
stdDTrainLL = std(dTrainLL);
semDTrainLL = stdDTrainLL/sqrt(size(dTrainLL,1));


muDDLL = mean(ddLL);
stdDDLL = std(ddLL);
semDDLL = stdDDLL/sqrt(size(ddLL, 1));

figure;
width = 2;
space = 0.5;
N = length(models_to_plot);
left = space/2 + width/2;
for idx = 1:N
    
    pos = (idx-1)*(2*width + space) + left;
    modelIdx = models_to_plot(idx);
    h1=bar(pos, muDTrainLL(modelIdx), width);
    hold on;
    
    h2=bar(pos+width, muDTestLL(modelIdx),width, 'FaceColor', [1, 0.7, 0]);
    errorbar(pos+width, muDTestLL(modelIdx), semDDLL(modelIdx), 'k');

    h = ttest(ddLL(:, modelIdx));
    if ~isnan(h) && ttest(ddLL(:, modelIdx))
        h = text(pos + width, muDTestLL(modelIdx) + 2*semDDLL(modelIdx), '*');
        set(h, 'FontSize', 25);
    end
end
right = (space + 2 * width) * N;
pos = (2*width + space) * [0:N-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames(models_to_plot));
xlim([0, right]);
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
ylabel(sprintf('Mean  loglikelihood relative to %s', modelNames{model_number}));
rotateXLabels(gca, 90);
