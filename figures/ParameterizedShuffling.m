key = 'subject_id = 21'
original_fits=fetch((cd_plc.PLCTrainSets * cd_plset.PLSets * cd_plset.ContrastSessionPLSet & key) * cd_plc.TrainedPLC, '*');
[data_original,v_plc_id, v_trainset_hash]  = dj.struct.tabulate(original_fits, 'plc_train_mu_logl', 'plc_id' , 'plc_trainset_hash');
[contrasts, v_hash] = dj.struct.tabulate(original_fits, 'dataset_contrast', 'plc_trainset_hash');
all_contrasts = cellfun(@str2num, contrasts(:,1));
selection = pro(cd_plset.ContrastSessionPLSet & key, 'plset_hash -> source_plset_hash');
filter = 'plshuffle_method = "shuffleLikelihoodWidthsAroundActualStims" and plshuffle_binwidth = 3';
shuffled_fits = fetch((cd_plc.PLCTrainSets * cd_plset.PLSets * cd_plset.ShuffledPLSets & selection) * cd_plc.TrainedPLC & filter, '*');
[data_shuffled, ~, ~, v_seed] = dj.struct.tabulate(shuffled_fits, 'plc_train_mu_logl', 'plc_id', 'source_plset_hash', 'plshuffle_seed');
mu_shuffled_kinds = mean(data_shuffled, 3);
%% Construct labels and edges
modelNames = fetchn(cd_plc.PLCModels, 'plc_label');
trainLL = data_original';
testLL = mu_shuffled_kinds';
%testLL(:, 1) = trainLL(:, 1);

%edges = arrayfun(@(x) prctile(all_contrasts, x), 0:10:100);
%edges = [0, unique(edges), 1];
%edges = 0.5*(edges(1:end-1) + edges(2:end));

c = [2 * c(1) - c(2), c, 2 * c(end)-c(end-1)];
edges = 0.5 * (c(1:end-1) + c(2:end));

%% Contrast vs mean logL plot for non-shuffled and shuffled
models_to_plot = 1:7;
NUM_MODELS = length(models_to_plot);

line_color = lines(length(modelNames));
h = figure;
set(h, 'name', 'Mean LogL fit vs Contrast for original and shuffled data');

subplot(1, 2, 1);

for idx = 1:NUM_MODELS
    idxModel = models_to_plot(idx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, trainLL(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx,:));
    hold on;

end
x = logspace(-3, 0, 100);
plot(x, ones(size(x)) * log(0.5), 'k--');
title('Fit on original (non-shuffled) set');
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');


subplot(1, 2, 2);
for idx = 1:NUM_MODELS
    idxModel = models_to_plot(idx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, testLL(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n),p, 'color', line_color(idx,:));
    %plot(binc, mu, 'color', line_color(idxModel, :));
    hold on;
end
x = logspace(-3, 0, 100);
plot(x, ones(size(x)) * log(0.5), 'k--');
title('Fit on shuffled set');
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

%% Contrast vs. mean logL plot for non-shuffled and shuffled with error bars based on difference w.r.t. target
models_to_plot = 1:7;
NUM_MODELS = length(models_to_plot);
target = 1;

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
title(sprintf('Fit on original set vs contrast relative to %s', modelNames{target}));
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
title(sprintf('Fit on shuffled set vs contrast relative to %s', modelNames{target}));
legend(modelNames(models_to_plot));
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([0.003, 1.2]);
ylabel('Mean log likelihood');

%% Contrast vs. mean logL plot for non-shuffled and shuffled relative to the target model treated as 0
models_to_plot = 1:7;
NUM_MODELS = length(models_to_plot);
target = 1;

delta_train = bsxfun(@minus, trainLL, trainLL(:, target));
delta_test = bsxfun(@minus, testLL, testLL(:, target));

line_color = lines(length(modelNames));
h = figure(3);
set(h, 'name',  'Difference in fit relative to target vs. Contrast');
subplot(1, 2, 1);

for idx = 1:NUM_MODELS
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
for idx = 1:NUM_MODELS
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
%% Plot the difference between non-shuffle(train) and shuffle(test)
figure;
delta = testLL - trainLL;
NUM_MODELS=5;
for modelIdx = 1:NUM_MODELS
    subplot(1, 5, modelIdx);
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, delta(:, modelIdx), edges);
    h=errorbar(binc, mu, s./sqrt(n), '-x', 'Color', [1, 0.2, 0]);
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    hold on;
    x = logspace(-3,0,100);
    plot(x, zeros(size(x)), 'k-.');
    xlim([edges(1), edges(end)]);
    ylabel('Mean log likelihood relative to train set (non-shuffled)');
    xlabel('Contrast');
end
%legend(h1, {'Test set (shuffled)'});

%% bar plots for average log likelihood across contrast
muTestLL = mean(testLL);
muTrainLL = mean(trainLL);


delta = testLL - trainLL;
stdDelta = std(delta);
semDelta = stdDelta ./ sqrt(size(delta, 1));

figure;
width = 2;
space = 0.5;
left = space/2 + width/2;
for modelIdx = 1:NUM_MODELS
    pos = (modelIdx-1)*(2*width + space) + left;
    h1=bar(pos, muTrainLL(modelIdx), width);
    hold on;
    
    h2=bar(pos+width, muTestLL(modelIdx),width, 'FaceColor', [1, 0.3, 0]);
    errorbar(pos+width, muTestLL(modelIdx), semDelta(modelIdx), 'k');
    h = ttest(delta(:, modelIdx));
    if ~isnan(h) && h
        h = text(pos + width, muTestLL(modelIdx) - 0.1, '*');
        set(h, 'FontSize', 25);
    end
end
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
right = (space + 2 * width) * NUM_MODELS;
pos = (2*width + space) * [0:NUM_MODELS-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames);
xlim([0, right]);
ylabel('Mean loglikelihood');

%% Plot specific models w.r.t. another one
model_number = 1; % model to compare against
modelIdx = 5; % model to plot
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
edges = arrayfun(@(x) prctile(all_contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
%edges = [0,0.02, 0.05, 0.1, 0.15, 0.85,1];
edges=edges(2:end);
figure;

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

%% bar plots for difference in shuffle vs non-shuffle w.r.t. the first
model_number = 1;
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
N = length(modelNames);
left = space/2 + width/2;
for modelIdx = 1:N
    pos = (modelIdx-1)*(2*width + space) + left;
    h1=bar(pos, muDTrainLL(modelIdx), width);
    hold on;
    
    h2=bar(pos+width, muDTestLL(modelIdx),width, 'FaceColor', [1, 0.7, 0]);
    errorbar(pos+width, muDTestLL(modelIdx), semDDLL(modelIdx), 'k');
    ttest(dTestLL(:, modelIdx))
    h = ttest(ddLL(:, modelIdx));
    if ~isnan(h) && ttest(ddLL(:, modelIdx))
        h = text(pos + width, muDTestLL(modelIdx) + 2*semDDLL(modelIdx), '*');
        set(h, 'FontSize', 25);
    end
end
right = (space + 2 * width) * N;
pos = (2*width + space) * [0:N-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames);
xlim([0, right]);
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
ylabel(sprintf('Mean  loglikelihood relative to %s', modelNames{model_number}));

