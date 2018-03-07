%%
rel = pro(cd_dlset.LCModelFits & 'decoder_id=3', 'lc_test_logl', 'lc_test_mu_logl', 'lc_test_mu_logl * lc_testset_size -> lc_total_logl');
rel = rel * pro(cd_dataset.CleanContrastSessionDataSet, 'dataset_hash -> dec_trainset_hash') * class_discrimination.CSCLookup;
data = fetch(rel, '*');


%%
all_contrasts = dj.struct.tabulate(data, 'dataset_contrast', 'dec_trainset_hash', 'cv_index', 'lc_id', 'lc_shuffle_id');
subjects = dj.struct.tabulate(data, 'subject_id', 'dec_trainset_hash', 'cv_index', 'lc_id', 'lc_shuffle_id');

contrast = cellfun(@str2num, all_contrasts(:, 1));
subjects = subjects(:, 1);
uniqueSubj = unique(subjects);
subjNames = containers.Map([3, 21],{'L', 'T'});
%%
use_mean = false;

if use_mean
    [v, data_hash, cv_index, lc_id, shuffle_id] = dj.struct.tabulate(data, 'lc_test_mu_logl', 'dec_trainset_hash', 'cv_index', 'lc_id', 'lc_shuffle_id' );
    cvMu = squeeze(mean(v, 2));
else
    [v, data_hash, cv_index, lc_id, shuffle_id] = dj.struct.tabulate(data, 'lc_test_logl', 'dec_trainset_hash', 'cv_index', 'lc_id', 'lc_shuffle_id' );
    S = squeeze(cellcat(v, 2));
    trials = cellfun(@length, S(:,1));
    cs = [];
    ss = [];
    for i=1:length(contrast)
        cs = [cs, repmat(contrast(i), 1, trials(i))];
        ss = [ss, repmat(subjects(i), 1, trials(i))];
    end
    contrast = cs;
    subjects = ss;

    cvMu = cell2mat(cellcat(S, 1));
end
%%
testLL = cvMu(:, :, 1); % get non shuffled data
shuffledLL = cvMu(:, :, 2);


%% build the model names - robust to the case of skipping lc_id
modelNames = {};
for m=fetch(cd_lc.LCModels, 'lc_label')'
    modelNames{m.lc_id} = m.lc_label;
end

% change names for plots
modelNames{32} = 'Bayesian model';
modelNames{38} = 'Non-Bayesian model';

decNames = fetchn(cd_decoder.DecoderModels, 'decoder_label');

%% Construct labels and contrast edges

% c = min(0.005 * (2.^(0:8)), 1);
% % edges = arrayfun(@(x) prctile(all_contrasts, x), 0:10:100);
% % edges = [0, unique(edges), 1];
% % edges = 0.5*(edges(1:end-1) + edges(2:end));
% 
% %c = unique(all_contrasts);
% 
% c = [2 * c(1) - c(2), c, 2 * c(end)-c(end-1)];
% edges = 0.5 * (c(1:end-1) + c(2:end));
filter = contrast > 0.00000001;
edges = prctile(contrast(filter), linspace(0, 100, 9));
edges(1) = edges(1) - 0.001;
edges(end) = edges(end) + 0.001;

%% Common figure settings
fs = 14;
fs_title = 16;
font = 'Arial';


%% Contrast vs. mean logL plot
models_to_plot = lc_id;
line_color = lines(length(models_to_plot));
h = figure;
set(h, 'name',  'Fit vs Contrast');

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    
    subplot(1, length(uniqueSubj), subjIdx);
    for idx = 1:length(models_to_plot)
        modelID = models_to_plot(idx);
        pos = find(lc_id == modelID);
        if isempty(pos)
            continue;
        end
        sessMatch = (subjects == subj);
        
        [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), testLL(sessMatch, pos), edges);
        p = '-';
        errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
        hold on;
    end

    x = logspace(-3, 0, 100);
    plot(x, ones(size(x)) * log(0.5), 'k--');
    title(sprintf('Fit on test set vs contrast for Monkey %s', subjNames(subj)));
    if subjIdx == length(uniqueSubj)
        legend(modelNames(models_to_plot));
    end
    xlabel('Contrast');
    set(gca, 'xscale', 'log');
    xlim([0.003, 1.2]);
    ylabel('Mean log likelihood');
    %ylim([log(0.5), -0.3]);

end
%% Contrast vs. delta mean logL plot relative to a target model
models_to_plot = lc_id;
% compare against this model
target_model = 38;

posTest = find(lc_id == target_model);
delta_test = bsxfun(@minus, testLL, testLL(:, posTest));
delta_shuffled = bsxfun(@minus, shuffledLL, testLL(:, posTest));

line_color = lines(length(models_to_plot));
h = figure;
set(h, 'name',  'Fit vs Contrast');

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    
    hrefs = [];
    subplot(1, length(uniqueSubj), subjIdx);
    for idx = 1:length(models_to_plot)
        modelID = models_to_plot(idx);
        pos = find(lc_id == modelID);
        if isempty(pos)
            continue;
        end
        sessMatch = (subjects == subj);
        [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), delta_test(sessMatch, pos), edges);
        %[mu] = nanBinnedStats(contrast(sessMatch), testLL(sessMatch, pos), edges);
        p = '-';
        errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
        hold on;
        h1 = plot(binc, mu, p, 'color', line_color(idx, :));
        [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), delta_shuffled(sessMatch, pos), edges);
        p = '--';
        errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
        h2 = plot(binc, mu, p, 'color', line_color(idx, :));

        hrefs = [hrefs, h1, h2];
    end

    %x = logspace(-3, 0, 100);
    %plot(x, ones(size(x)) * log(0.5), 'k--');
    title(sprintf('Monkey %s', subjNames(subj)));
    if subjIdx == length(uniqueSubj)
        labels = {};
        for m=1:length(models_to_plot)
            mName = modelNames{models_to_plot(m)};
            labels = [labels, {mName}, {[mName, ' - Shuffled']}];
        end
        legend(hrefs, labels);
    end
    xlabel('Contrast');
    set(gca, 'xscale', 'log');
    xlim([0.003, 1.2]);
    if subjIdx==1
        ylabel('Relative log likelihood');
    end
    %ylim([log(0.5), -0.3]);

end

%% bar plots for delta average log likelihood relative to a taget model
models_to_plot = [38, 32]; %[38, 29, 32, 39:43]; %[2, 25, 33:36, 37:40, 29, 32];

targetModel = 38;
posTrain = find(lc_id == targetModel);

test_delta = bsxfun(@minus, testLL, testLL(:, posTrain));
shuffled_delta = bsxfun(@minus, shuffledLL, testLL(:, posTrain));


%NUM_MODELS = length(models_to_plot);
h = figure;
set(h, 'name',  'Average relative log likelihood');
width = 2;

space = 0.5;
left = space/2 + width/2;


for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    filter = subjects == subj;
    
    fprintf('\nsubject %d p-values: relative to %d\n', subj, targetModel);

    
    muDeltaTestLL = mean(test_delta(filter,:), 1); % take average across all contrasts
    stdDeltaTestLL = std(test_delta(filter, :));
    semDeltaTestLL = stdDeltaTestLL ./ sqrt(sum(filter));
    
    muDeltaShuffledLL = mean(shuffled_delta(filter,:), 1); % take average across all contrasts
    stdDeltaShuffledLL = std(shuffled_delta(filter, :));
    semDeltaShuffledLL = stdDeltaShuffledLL ./ sqrt(sum(filter));

    
    subplot(1, length(uniqueSubj), subjIdx);
    labels = [];
    labelPos = [];
    
    for idx = 1:length(models_to_plot)
        modelId = models_to_plot(idx);
        modelPos = find(lc_id == modelId);
        if isempty(modelPos)
            continue;
        end

        x_pos = (idx-1)*(width + space) + left;
        labelPos = [labelPos x_pos];
        labels = [labels modelNames(modelId)];
        
        
        c = [255, 187, 53] / 255;
        c_shuffled = [148, 252, 155] / 255;
        
        % plot train delta
        h1 = bar(x_pos-width/4, muDeltaTestLL(modelPos), width/2, 'FaceColor', c);
        hold on;
        
        errorbar(x_pos-width/4, muDeltaTestLL(modelPos), semDeltaTestLL(modelPos), 'k');
        [h, p, ci] = ttest(test_delta(filter, modelPos));
        fprintf('model %d: %f\n', modelId, p);
        if ~isnan(h) && h
            mu = muDeltaTestLL(modelPos);
            starPos = mu + sign(mu) * semDeltaTestLL(modelPos) * 1.1;
            hText = text(x_pos-width/4, starPos, '*');
            set(hText, 'FontSize', 25, 'HorizontalAlignment', 'center');
        end
        
        % plot shuffled delta
        h2 = bar(x_pos+width/4, muDeltaShuffledLL(modelPos), width/2, 'FaceColor', c_shuffled);
        hold on;
        
        errorbar(x_pos+width/4, muDeltaShuffledLL(modelPos), semDeltaShuffledLL(modelPos), 'k');
        [h, p, ci] = ttest(shuffled_delta(filter, modelPos));
        fprintf('model %d: %f\n', modelId, p);
        if ~isnan(h) && h
            mu = muDeltaShuffledLL(modelPos);
            starPos = mu + semDeltaShuffledLL(modelPos) * 1.1;
            hText = text(x_pos+width/4, starPos, '*');
            set(hText, 'FontSize', 25, 'HorizontalAlignment', 'center');
        end
    end
    
    if subjIdx == length(uniqueSubj)
        legend([h1, h2], {'Original', 'Shuffled'});
    end
    
    right = x_pos + width/2 + space;
    set(gca, 'xtick', labelPos);
    set(gca, 'xticklabel', labels);
    title(sprintf('Monkey %s', subjNames(subj)));
    xlim([0, right]);
    if subjIdx == 1
        ylabel('Relative log likelihood');
    end
    ylim([-0.01, 0.02 ]);
    rotateXLabels(gca,90);
end

%% bar plots for total log likelihood relative to a taget model
models_to_plot = [38, 32]; %[38, 29, 32, 39:43]; %[2, 25, 33:36, 37:40, 29, 32];

targetModel = 38;
posTrain = find(lc_id == targetModel);

test_delta = bsxfun(@minus, testLL, testLL(:, posTrain));
shuffled_delta = bsxfun(@minus, shuffledLL, testLL(:, posTrain));



%NUM_MODELS = length(models_to_plot);
h = figure;
set(h, 'name',  'Total log likelihood');
width = 2;

space = 0.5;
left = space/2 + width/2;


for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    filter = subjects == subj;
    
    fprintf('\nsubject %d p-values: relative to %d\n', subj, targetModel);

    
    muDeltaTestLL = nansum(test_delta(filter,:), 1); % take average across all contrasts
    muDeltaShuffledLL = nansum(shuffled_delta(filter,:), 1); % take average across all contrasts
 
    
    subplot(1, length(uniqueSubj), subjIdx);
    labels = [];
    labelPos = [];
    
    for idx = 1:length(models_to_plot)
        modelId = models_to_plot(idx);
        modelPos = find(lc_id == modelId);
        if isempty(modelPos)
            continue;
        end

        x_pos = (idx-1)*(width + space) + left;
        labelPos = [labelPos x_pos];
        labels = [labels modelNames(modelId)];
        
        
        c = [255, 187, 53] / 255;
        c_shuffled = [148, 252, 155] / 255;
        
        % plot train delta
        h1 = bar(x_pos-width/4, muDeltaTestLL(modelPos), width/2, 'FaceColor', c);
        hold on;

        % plot shuffled delta
        h2 = bar(x_pos+width/4, muDeltaShuffledLL(modelPos), width/2, 'FaceColor', c_shuffled);
        hold on;
    end
    
    if subjIdx == length(uniqueSubj)
        legend([h1, h2], {'Original', 'Shuffled'});
    end
    
    right = x_pos + width/2 + space;
    set(gca, 'xtick', labelPos);
    set(gca, 'xticklabel', labels);
    title(sprintf('Monkey %s', subjNames(subj)));
    xlim([0, right]);
    if subjIdx==1
        ylabel('Relative log likelihood');
    end
    ylim([-800, 1500 ]);
    rotateXLabels(gca,90);
end

