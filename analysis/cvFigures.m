result =[];
for idx=1:length(sessionData)
    result = [result sessionData(idx).cvResults.cvContrast];
end

%%
fits = [];
contrasts=[result.contrast];
for idxResult = 1:length(result)
    rs = result(idxResult);
    data = rs.data;
    testLL = [];
    for idxCV = 1:length(data)
        testLL = [testLL; [data(idxCV).models.testLL]];
    end
    fits = [fits; mean(testLL)];
end
modelNames = {result(1).data(1).models.modelName};

%%
line_color = lines(length(modelNames));
figure;
edges = 10.^linspace(-3.5,0,10);
for idxModel = 1:size(fits, 2)
    [mu, s, n, binc] = nanBinnedStats(contrasts, exp(fits(:, idxModel)), edges);
    errorbar(binc, mu, s./sqrt(n), 'color', line_color(idxModel,:));
    plot(binc, mu, 'color', line_color(idxModel, :));
    hold on;
end
legend(modelNames);

%% Create comparative bar plots...
baseModelIdx = 2;%find(strcmp(modelNames,'FullLikelihood'))
fits_c = fits;
fits_c(:, baseModelIdx) = [];
delta_fits = bsxfun(@minus, fits_c, fits(:, baseModelIdx));
modelNames_d = modelNames;
modelNames_d(baseModelIdx) = [];
mu_delta = mean(delta_fits);
s_delta = std(delta_fits,[], 1);
n = size(delta_fits, 1);
sem_delta = s_delta ./ sqrt(n);
figure;
line_color = lines(length(modelNames));
for idx = 1:length(modelNames_d)
    h = bar(idx, mu_delta(idx), 'FaceColor', line_color(idx,:));
    leg_list = [leg_list h];
    hold on;
    errorbar(idx, mu_delta(idx), sem_delta(idx), '.');
end
legend(leg_list, modelNames_d);