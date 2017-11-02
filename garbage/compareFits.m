%% analyze models trained on each contrast-session

trainTestPairs = (pro(class_discrimination.ContrastSessionDataSet, 'dataset_contrast -> contrast', 'dataset_id -> lc_trainset_id') * pro(class_discrimination.SCGroupedShuffledDataSets, '*', 'dataset_id -> lc_testset_id'));
allFits = class_discrimination.TrainedLikelihoodClassifiers * class_discrimination.LikelihoodClassifierModels * class_discrimination.LCModelFits * trainTestPairs;
fits = fetch(allFits & 'shuffle_binwidth >10', '*');

%%
[test_ll, v1, v2]=dj.struct.tabulate(fits, 'fit_mu_logl', 'lc_trainset_id', 'lc_label');
[train_ll, v1, v2]=dj.struct.tabulate(fits, 'mu_logl', 'lc_trainset_id', 'lc_label');
c = dj.struct.tabulate(fits, 'contrast', 'lc_trainset_id', 'lc_label');
contrasts =cellfun(@(x) str2num(x), c);
contrasts = contrasts(:, 1);

model_labels = {fits.lc_label};

models = unique(model_labels);
hold on;
edges = arrayfun(@(x) prctile(contrasts, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));

trainLL = train_ll;
testLL = test_ll;
all_contrasts = contrasts(:,1)';
modelNames = unique(model_labels);

% reorder shit...
order = [5, 6, 7, 2, 3, 4, 1, 8, 9, 10, 11];
trainLL = trainLL(:, order);
testLL = testLL(:, order);
modelNames = modelNames(order);

NUM_MODELS = length(modelNames);

%% Contrast vs mean logL plot for non-shuffled and shuffled
line_color = lines(length(modelNames));
figure;

x = logspace(-3, 0, 100);
for idxModel = 1:size(trainLL, 2)
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, trainLL(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idxModel,:));
    %plot(binc, mu, 'color', line_color(idxModel, :));
    hold on;

end
plot(x, ones(size(x)) * log(0.5), 'k--');
title('Trained set (non-shuffled)');
legend(modelNames);
xlabel('Contrast');
set(gca, 'xscale', 'log');
xlim([1e-3, 1]);
ylabel('Mean log likelihood');


for idxModel = 1:size(testLL, 2)
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, testLL(:, idxModel), edges);
    p = '--';
    
    errorbar(binc, mu, s./sqrt(n),p, 'color', line_color(idxModel,:));
    %plot(binc, mu, 'color', line_color(idxModel, :));
    hold on;
end
plot(x, ones(size(x)) * log(0.5), 'k--');
title('Test set (shuffled)');
legend(modelNames);
set(gca, 'xscale', 'log');
xlabel('Contrast');
xlim([1e-3, 1]);
ylabel('Mean log likelihood');


%% Plot the difference between non-shuffle(train) and shuffle(test)
figure;
delta = testLL - trainLL;

for modelIdx = 1:NUM_MODELS
    rows = floor(sqrt(NUM_MODELS));
    cols = ceil(NUM_MODELS / rows);
    subplot(rows, cols, modelIdx);
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
modelIdx = 2; % model to plot
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
    rows = floor(sqrt(NUM_MODELS));
    cols = ceil(NUM_MODELS / rows);
    subplot(rows, cols, modelIdx);
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
    rows = floor(sqrt(NUM_MODELS));
    cols = ceil(NUM_MODELS / rows);
    subplot(rows, cols, modelIdx);
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

