%% Load data - this is an expensive operation!
%shuffled = load('ShuffledFit61');
%cvFits = load('cvAllFitTo61');

%% group CV fits

result = [];
for idx=1:length(cvFits.sessionData)
    result = [result cvFits.sessionData(idx).cvResults.cvContrast];
end

fits = [];
contrasts2=[result.contrast];
for idxResult = 1:length(result)
    rs = result(idxResult);
    data = rs.data;
    testLL = [];
    for idxCV = 1:length(data)
        testLL = [testLL; [data(idxCV).models.testLL]];
    end
    fits = [fits; mean(testLL)];

end


%% group suffled vs non-shuffled
allResults = [shuffled.sessionData.cvResults];
results = [allResults.cvContrast]; % across all contrasts

contrasts = [results.contrast];
allData = [results.data];

testLL = [];
trainLL = [];
modelNames = {};
for idx=1:length(allData)
    data = allData(idx);
    if idx == 1
        modelNames = {data.models.modelName};
    end
    testLL = [testLL; [data.models.testLL]];
    trainLL = [trainLL; [data.models.trainLL]];
end


%% Contrast vs mean logL plot for non-shuffled and shuffled
line_color = lines(length(modelNames));
figure;
subplot(1,2,1);
edges = arrayfun(@(x) prctile(contrasts, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));

x = logspace(-3, 0, 100);
for idxModel = 1:size(trainLL, 2)
    [mu, s, n, binc] = nanBinnedStats(contrasts, trainLL(:, idxModel), edges);
    if idxModel >= 8
        p = '--';
    else
        p = '-';
    end
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

subplot(1,2,2);
for idxModel = 1:size(testLL, 2)
    [mu, s, n, binc] = nanBinnedStats(contrasts, testLL(:, idxModel), edges);
    if idxModel >= 8
        p = '--';
    else
        p = '-';
    end
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

%% Plot the shuffle, non-shuffle, and CV for each model
figure;
edges = arrayfun(@(x) prctile(contrasts, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
for modelIdx = 1:10
    subplot(2, 5, modelIdx);
    [mu_train, s_train, n_train, binc] = nanBinnedStats(contrasts, trainLL(:, modelIdx), edges);
    [mu_test, s_test, n_test, binc] = nanBinnedStats(contrasts, testLL(:, modelIdx), edges);
    [mu_fit, s_fit, n_fit, binc] = nanBinnedStats(contrasts, fits(:, modelIdx), edges);
    h1=errorbar(binc, mu_train, s_train./sqrt(n_train));
    hold on;
    h2=errorbar(binc, mu_test, s_test./sqrt(n_test), '-x', 'Color', [1, 0.2 0]);
    h3=errorbar(binc, mu_fit, s_fit ./sqrt(n_fit), '-o', 'Color', [0, 0.7, 0]);
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    ylabel('Mean log likelihood');
    xlabel('Contrast');
end
legend([h1, h2, h3], {'Train set (non-shuffled)', 'Test set (shuffled)', 'CV test set'});

%% Plot the difference between non-shuffle(train) and shuffle(test)
figure;
delta = testLL - trainLL;
deltaCV = fits - trainLL;
edges = arrayfun(@(x) prctile(contrasts, x), linspace(0,100,5));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
for modelIdx = 1:10
    subplot(2, 5, modelIdx);
    [mu, s, n, binc] = nanBinnedStats(contrasts, delta(:, modelIdx), edges);
    [mu_cv, s_cv, n_cv, binc] = nanBinnedStats(contrasts, deltaCV(:, modelIdx), edges);
    h1=errorbar(binc, mu, s./sqrt(n), '-x', 'Color', [1, 0.2, 0]);
    hold on;
    h2=errorbar(binc, mu_cv, s_cv./sqrt(n_cv), '-o', 'Color', [0,0.7,0]);
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    x = logspace(-3,0,100);
    plot(x, zeros(size(x)), 'k-.');
    ylabel('Mean log likelihood relative to train set (non-shuffled)');
    xlabel('Contrast');
end
legend([h1, h2], {'Test set (shuffled)', 'CV test set'});

%% bar plots for average log likelihood across contrast
model_number = 1;
muTestLL = mean(testLL);
muTrainLL = mean(trainLL);


delta = testLL - trainLL;
stdDelta = std(delta);
semDelta = stdDelta ./ sqrt(size(delta, 1));

figure;
width = 2;
space = 0.5;
N = length(modelNames);
left = space/2 + width/2;
for modelIdx = 1:N
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
right = (space + 2 * width) * N;
pos = (2*width + space) * [0:N-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames);
rotateXLabels(gca, 90);
xlim([0, right]);
ylabel('Mean loglikelihood');




%% Plot all models w.r.t. the first
model_number = 2;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
dFits = bsxfun(@minus, fits, fits(:, model_number));

edges = arrayfun(@(x) prctile(contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
figure;
for modelIdx = 1:10
    subplot(2, 5, modelIdx);
    [mu_train, s_train, n_train, binc] = nanBinnedStats(contrasts, dTrainLL(:, modelIdx), edges);
    [mu_test, s_test, n_test, binc] = nanBinnedStats(contrasts, dTestLL(:, modelIdx), edges);
    [mu_fit, s_fit, n_fit, binc] = nanBinnedStats(contrasts, dFits(:, modelIdx), edges);
    h1=errorbar(binc, mu_train, s_train./sqrt(n_train));
    hold on;
    h2=errorbar(binc, mu_test, s_test./sqrt(n_test), '-x', 'Color', [1,0.3,0]);
    %errorbar(binc, mu_fit, s_fit ./sqrt(n_fit), 'o-r');
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    xlabel('Contrast');
    ylabel(sprintf('Log likelihood relative to %s', modelNames{model_number}));
end
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});

%% plot the difference in model w.r.t the first
model_number = 2;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
dFits = bsxfun(@minus, fits, fits(:, model_number));

edges = arrayfun(@(x) prctile(contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
figure;
for modelIdx = 1:10
    subplot(2, 5, modelIdx);
    [mu, s, n, binc] = nanBinnedStats(contrasts, dTestLL(:, modelIdx) - dTrainLL(:, modelIdx), edges);
    [mu_fit, s_fit, n_fit, binc] = nanBinnedStats(contrasts, dFits(:, modelIdx) - dTrainLL(:, modelIdx), edges);
    h1=errorbar(binc, mu, s./sqrt(n), '-x', 'Color', [1, 0.3, 0]);
    x = logspace(-3,0,100);
    hold on;
    plot(x, zeros(size(x)), 'k-.');
    h2=errorbar(binc, mu_fit, s_fit./sqrt(n_fit), '-o', 'Color', [0, 0.7,0]);
    set(gca, 'xscale', 'log');
    title(modelNames{modelIdx});
    xlabel('Contrast');
    ylabel(sprintf('Difference in loglikelihood relative to %s', modelNames{model_number}));
end
legend([h1, h2], {'Test set (shuffled)', 'CV test set'});

%% bar plots for difference in shuffle vs non-shuffle w.r.t. the first
model_number = 2;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
dFits = bsxfun(@minus, fits, fits(:, model_number));

edges = arrayfun(@(x) prctile(contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));

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
rotateXLabels(gca, 90);
xlim([0, right]);
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
ylabel(sprintf('Mean  loglikelihood relative to %s', modelNames{model_number}));

%% bar plots for difference in non-shuffle vs cv test w.r.t. the first
model_number = 2;
dTrainLL = bsxfun(@minus, trainLL, trainLL(:, model_number));
dTestLL = bsxfun(@minus, testLL, testLL(:, model_number));
dFits = bsxfun(@minus, fits, fits(:, model_number));

edges = arrayfun(@(x) prctile(contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));

ddLL = dFits - dTrainLL;

muDFits = mean(dFits);
stdDFits = std(dFits);
semDFits = stdDFits/sqrt(size(dFits,1));

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
    
    h2=bar(pos+width, muDFits(modelIdx),width, 'FaceColor', [1, 0.7, 0]);
    errorbar(pos+width, muDFits(modelIdx), semDDLL(modelIdx), 'k');
    h = ttest(ddLL(:, modelIdx));
    if ~isnan(h) && ttest(ddLL(:, modelIdx))
        h = text(pos + width, muDFits(modelIdx) + 2*semDDLL(modelIdx), '*');
        set(h, 'FontSize', 25);
    end
end
right = (space + 2 * width) * N;
pos = (2*width + space) * [0:N-1] + left + width/2;
set(gca, 'xtick', pos);
set(gca, 'xticklabel', modelNames);
rotateXLabels(gca, 90);
xlim([0, right]);
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
ylabel(sprintf('Mean  loglikelihood relative to %s', modelNames{model_number}));
%% analysis of likelihood functions
trainSet = [allData.trainSet];
all_train_stimulus = [trainSet.stimulus];
n_train = arrayfun(@(x) length(x.stimulus), trainSet);
all_train_contrasts = cell2mat(arrayfun(@(x,y) x * ones(1, y), contrasts, n_train, 'UniformOutput', false));
decodeOri_train = trainSet.decodeOri;
likelihood_train = [trainSet.likelihood];
[mu_train, sigma_train] = ClassifierModel.getMeanStd(decodeOri_train, likelihood_train);
mu_train = mu_train(:)';
sigma_train = sigma_train(:)';
edges = arrayfun(@(x) prctile(contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
delta_train = abs(mu_train - all_train_stimulus);
[mean_train_delta, std_train_delta, n_train_delta, binc] = nanBinnedStats(all_train_contrasts, delta_train, edges);
[mean_train_sigma, std_train_sigma, n_train_sigma, binc] = nanBinnedStats(all_train_contrasts, sigma_train, edges);


testSet = [allData.testSet];
all_test_stimulus = [testSet.stimulus];
n_test = arrayfun(@(x) length(x.stimulus), testSet);
all_test_contrasts = cell2mat(arrayfun(@(x,y) x * ones(1, y), contrasts, n_test, 'UniformOutput', false));
decodeOri_test = testSet.decodeOri;
likelihood_test = [testSet.likelihood];
[mu_test, sigma_test] = ClassifierModel.getMeanStd(decodeOri_test, likelihood_test);
mu_test = mu_test(:)';
sigma_test = sigma_test(:)';
edges = arrayfun(@(x) prctile(contrasts, x), linspace(0,100,11));
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
delta_test = abs(mu_test - all_test_stimulus);
[mean_test_delta, std_test_delta, n_test_delta, binc] = nanBinnedStats(all_test_contrasts, delta_test, edges);
[mean_test_sigma, std_test_sigma, n_test_sigma, binc] = nanBinnedStats(all_test_contrasts, sigma_test, edges);


figure;
subplot(2,1,1);
h1 = errorbar(binc, mean_train_delta, std_train_delta./sqrt(n_train_delta));
hold on;
h2 = errorbar(binc, mean_test_delta, std_test_delta./sqrt(n_test_delta), '-x', 'Color', [1, 0.3, 0]);
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
set(gca, 'xscale', 'log');
xlabel('Contrast');
ylabel('Mean absolute error in mean likelihood and actual stimulus (deg)');

subplot(2,1,2);
h1=errorbar(binc, mean_train_sigma, std_train_sigma./sqrt(n_train_sigma));
hold on;
h2=errorbar(binc, mean_test_sigma, std_test_sigma./sqrt(n_test_sigma), '-x', 'Color', [1, 0.3, 0]);
legend([h1, h2], {'Train set (non-shuffled)', 'Test set (shuffled)'});
set(gca, 'xscale', 'log');
xlabel('Contrast');
ylabel('Mean width of the likelihood (deg)');






