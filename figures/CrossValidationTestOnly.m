%%
cv_testfits = fetch(pro(cd_dataset.CrossValidationSets * cd_lc.LCModels, cd_lc.LCModelFits * cd_lc.LCTestSets * cd_dataset.CVTestSets, 'avg(lc_test_mu_logl)->test_mu_logl'), '*');
[data_test, v_lc_id] = dj.struct.tabulate(cv_testfits, 'test_mu_logl', 'lc_id');
[contrasts, v_lc_id] = dj.struct.tabulate(cv_testfits, 'cv_contrast', 'lc_id');
all_contrasts = cellfun(@str2num, contrasts(1,:));

modelNames = fetchn(cd_lc.LCModels, 'lc_label');
testLL = data_test';
edges = arrayfun(@(x) prctile(all_contrasts, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));

%%
models_to_plot = [3,2,1,4,5,6,7];

%% Contrast vs mean logL plot for non-shuffled and shuffled
line_color = lines(length(modelNames));
figure;
x = logspace(-3, 0, 100);

for idxModel = models_to_plot
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, testLL(:, idxModel), edges);
    p = '-';
    
    errorbar(binc, mu, s./sqrt(n),p, 'color', line_color(idxModel,:));
    %plot(binc, mu, 'color', line_color(idxModel, :));
    hold on;
end
title('Cross validation test set');
legend(modelNames(models_to_plot));
plot(x, ones(size(x)) * log(0.5), 'k-');
set(gca, 'xscale', 'log');
xlabel('Contrast');
xlim([0.005, 1]);
ylabel('Mean log likelihood');



%% bar plots for average log likelihood across contrast relative to the specified model
muTestLL = mean(testLL);
model_number = 3;
delta = bsxfun(@minus, testLL, testLL(:, model_number));
muDelta = mean(delta);
stdDelta = std(delta);
semDelta = stdDelta ./ sqrt(size(delta, 1));

figure;
width = 2;
space = 0.5;
left = space/2 + width/2;
for idx = 1:length(models_to_plot)
    modelIdx = models_to_plot(idx);
    pos = (idx-1)*(width + space) + left;

    hold on;
    h1=bar(pos, muDelta(modelIdx),width, 'FaceColor', [1, 0.3, 0]);
    errorbar(pos, muDelta(modelIdx), semDelta(modelIdx), 'k');
    H = ttest(delta(:, modelIdx));
    if ~isnan(H) && H
        th = text(pos, muDelta(modelIdx) + semDelta(modelIdx) + 0.005, '*');
        set(th, 'FontSize', 25);
    end
end
%legend([h1], {'Test set'});
NUM_MODELS = length(models_to_plot);
right = (space + width) * NUM_MODELS;
pos = (width + space) * [0:NUM_MODELS-1] + left;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames(models_to_plot));
xlim([0, right]);
ylabel('Relative mean loglikelihood');
title('Model fits relative to the maximum likelihood peak-only model');

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




%% Plot all models w.r.t. the specified
model_number = 3;
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
edges = arrayfun(@(x) prctile(all_contrasts, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
%edges = [0,0.02, 0.05, 0.1, 0.15, 0.85,1];
edges=edges(2:end);
figure;
NUM_MODELS = length(models_to_plot);
labels = {};
line_c = lines(NUM_MODELS);
for modelIdx = models_to_plot
    hold on;
    [mu_test, s_test, n_test, binc] = nanBinnedStats(all_contrasts, dTestLL(:, modelIdx), edges);
    h=errorbar(binc, mu_test, s_test./sqrt(n_test), '-', 'Color', line_c(modelIdx, :));
    labels = [labels modelNames(modelIdx)];
    %errorbar(binc, mu_fit, s_fit ./sqrt(n_fit), 'o-r');
    set(gca, 'xscale', 'log');

end
title(sprintf('Model performance relative to %s', modelNames{model_number}));
xlabel('Contrast');
ylabel(sprintf('Log likelihood relative to %s', modelNames{model_number}));
xlim([0.005, 1]);
ylim([-0.03,0.11]);
legend(labels);

%% bar plots for difference in test and train w.r.t. the specified model
model_number = 3;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));


muDTestLL = mean(dTestLL);
stdDTestLL = std(dTestLL);
semDTestLL = stdDTestLL/sqrt(size(dTestLL,1));

muDTrainLL = mean(dTrainLL);
stdDTrainLL = std(dTrainLL);
semDTrainLL = stdDTrainLL/sqrt(size(dTrainLL,1));


figure;
width = 2;
space = 0.5;
N = length(modelNames);
left = space/2 + width/2;
hold on;
for modelIdx = 1:N
    pos = (modelIdx-1)*(2*width + space) + left;
    h1=bar(pos, muDTrainLL(modelIdx), width, 'b');
    errorbar(pos, muDTrainLL(modelIdx), semDTrainLL(modelIdx), 'k');
    hold on;
    
    h = ttest(dTrainLL(:, modelIdx));
    if ~isnan(h)
        mult = sign(mean(dTrainLL(:,modelIdx)));
        h = text(pos, muDTrainLL(modelIdx) + 3*mult*semDTrainLL(modelIdx), '*');
        plot(pos, muDTrainLL(modelIdx) + 3*mult*semDTrainLL(modelIdx), 'r*', 'markersize', 13);
        set(h, 'FontSize', 25);
    end
    
    
    h2=bar(pos+width, muDTestLL(modelIdx), width, 'FaceColor', [1, 0.7, 0]);
    errorbar(pos+width, muDTestLL(modelIdx), semDTestLL(modelIdx), 'k');
    
    h = ttest(dTestLL(:, modelIdx));
    if ~isnan(h)
        mult = sign(mean(dTestLL(:,modelIdx)));
        h = text(pos + width, muDTestLL(modelIdx) + mult*3*semDTestLL(modelIdx), '*');
        set(h, 'FontSize', 25);
    end
end
right = (space + 2 * width) * N;
pos = (2*width + space) * [0:N-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames);
xlim([0, right]);
legend([h1, h2], {'Train set', 'Test set'});
ylabel(sprintf('Mean  loglikelihood relative to %s', modelNames{model_number}));

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