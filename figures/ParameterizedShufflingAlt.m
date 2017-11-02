original_fits=fetch((cd_plc.PLCTrainSets * cd_plset.ContrastSessionPLSet) * cd_plc.TrainedPLC, '*');
[data_original,v_plc_id, v_trainset_hash]  = dj.struct.tabulate(original_fits, 'plc_train_mu_logl', 'plc_id' , 'plc_trainset_hash');
[contrasts, v_hash] = dj.struct.tabulate(original_fits, 'dataset_contrast', 'plc_trainset_hash');
all_contrasts = cellfun(@str2num, contrasts(:,1));
shuffled_fits = fetch((cd_plc.PLCTrainSets * cd_plset.ShuffledPLSets) * cd_plc.TrainedPLC, '*');
[data_shuffled, ~, ~, v_seed] = dj.struct.tabulate(shuffled_fits, 'plc_train_mu_logl', 'plc_id', 'source_plset_hash', 'plshuffle_seed');
mu_shuffled_kinds = mean(data_shuffled, 3);

modelNames = fetchn(cd_plc.PLCModels, 'plc_label');
trainLL = data_original';
testLL = mu_shuffled_kinds';
testLL(:, 1) = trainLL(:, 1);

edges = arrayfun(@(x) prctile(all_contrasts, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
%%
models_to_plot = [1,2];
%% Contrast vs mean logL plot for non-shuffled and shuffled
line_color = lines(length(modelNames));
figure;
x = logspace(-3, 0, 100);
for idxModel = models_to_plot
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, trainLL(:, idxModel), edges);
    p = '-';
    errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idxModel,:));
    %plot(binc, mu, 'color', line_color(idxModel, :));
    hold on;

end

for idxModel = models_to_plot
    [mu, s, n, binc] = nanBinnedStats(all_contrasts, testLL(:, idxModel), edges);
    p = '--';
    
    errorbar(binc, mu, s./sqrt(n),p, 'color', line_color(idxModel,:));
    %plot(binc, mu, 'color', line_color(idxModel, :));
    hold on;
end
plot(x, ones(size(x)) * log(0.5), 'k--');
title('Test set (shuffled)');
legend(modelNames(models_to_plot));
set(gca, 'xscale', 'log');
xlabel('Contrast');
xlim([1e-3, 1]);
ylabel('Mean log likelihood');


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
NUM_MODELS = length(models_to_plot);
for modelIdx = models_to_plot
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
set(gca, 'xticklabel', modelNames(models_to_plot));
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





%% plot the difference in model w.r.t the first
model_number = 3;
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
N = length(modelNames(models_to_plot));
left = space/2 + width/2;
for modelIdx = models_to_plot
    pos = (modelIdx-1)*(2*width + space) + left;
    h1=bar(pos, muDTrainLL(modelIdx), width);
    errorbar(pos, muDTrainLL(modelIdx), semDTrainLL(modelIdx), 'k');
    h = ttest(dTrainLL(:, modelIdx));
    if ~isnan(h) && h
        h = text(pos, muDTrainLL(modelIdx) + 2*semDTrainLL(modelIdx), '*');
        set(h, 'FontSize', 25);
    end
    hold on;
    
    h2=bar(pos+width, muDTestLL(modelIdx),width, 'FaceColor', [1, 0.3, 0]);
    errorbar(pos+width, muDTestLL(modelIdx), semDTestLL(modelIdx), 'k');
    h = ttest(dTestLL(:, modelIdx));
    if ~isnan(h) && h
        h = text(pos + width, muDTestLL(modelIdx) + 2*semDTestLL(modelIdx), '*');
        set(h, 'FontSize', 25);
    end
end
right = (space + 2 * width) * N;
pos = (2*width + space) * [0:N-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames(models_to_plot));
xlim([0, right]);
ylim([0, 0.04]);
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
ylabel(sprintf('Mean  loglikelihood relative to %s', modelNames{model_number}));
title('Relative mean log-likelihood for non-shuffled vs shuffled data');

