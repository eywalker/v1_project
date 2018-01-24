restr = 'decoder_id = 3';
train_leaf = pro(cd_dataset.CleanCVTrainSets, 'dataset_hash -> lc_trainset_hash') * pro(cd_lc.TrainedLC, 'lc_train_mu_logl', 'lc_trainset_size');
test_leaf = pro(cd_dataset.CleanCVTestSets, 'dataset_hash -> lc_testset_hash') * pro(cd_lc.LCModelFits, 'lc_test_mu_logl', 'lc_testset_size');
aggr_targets = cd_dataset.CleanCrossValidationSets * cd_lc.LCModels * cd_decoder.DecoderModels & restr;

%% merge all primary keys except for lc_id and decoder_id into a single key
pk = aggr_targets.primaryKey;
filter = ~ismember(pk, {'lc_id', 'decoder_id'});
pk = pk(filter);
joint_id = pro(aggr_targets, sprintf('concat_ws("-", %s) -> joint_id', strjoin(pk, ',')));

train_results = pro(aggr_targets, train_leaf, 'avg(lc_trainset_size * lc_train_mu_logl) -> train_logl', 'count(*) -> n');
train_data = fetch(train_results * joint_id * class_discrimination.CSCLookup & 'n > 2', '*') ;

test_results = pro(aggr_targets, test_leaf, 'sum(lc_testset_size * lc_test_mu_logl) -> test_logl', 'count(*) -> n');
test_data = fetch(test_results * joint_id * class_discrimination.CSCLookup & 'n > 2', '*') ;

%% build the model names - robust to case of skipping lc_id
modelNames = {};
for m=fetch(cd_lc.LCModels, 'lc_label')'
    modelNames{m.lc_id} = m.lc_label;
end
decNames = fetchn(cd_decoder.DecoderModels, 'decoder_label');

%% Fetch data using tabulate with combined primary key

[trainLL, v_jointid, v_lcid, v_decid] = dj.struct.tabulate(train_data, 'train_logl', 'joint_id', 'lc_id', 'decoder_id');
[testLL, v_jointid_test, v_lcid_test, v_decid_test] = dj.struct.tabulate(test_data, 'test_logl', 'joint_id', 'lc_id', 'decoder_id');

%[testLL, v_jointid_c, v_lcid_c, v_decid_c] = dj.struct.tabulate(test_data, 'test_mu_logl', 'joint_id', 'lc_id', 'decoder_id');
%%
all_contrasts = dj.struct.tabulate(train_data, 'cv_contrast', 'joint_id', 'lc_id', 'decoder_id');
subjects = dj.struct.tabulate(train_data, 'subject_id', 'joint_id', 'lc_id', 'decoder_id');

contrast = cellfun(@str2num, all_contrasts(:, 1));
subjects = subjects(:, 1);
uniqueSubj = unique(subjects);
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
filter = contrast > 0.00001;
edges = prctile(contrast(filter), linspace(0, 100, 9));
edges(1) = edges(1) - 0.001;
edges(end) = edges(end) + 0.001;

%% Common figure settings
fs = 14;
fs_title = 16;
font = 'Arial';

%% %% Grid wise model performance comparison on the training set

models_to_plot = [25, 29, 32];
nModels = length(models_to_plot);
vmax = max(trainLL(:)) + 0.01;
vmin = min(trainLL(:)) - 0.01;

line_color = lines(nModels);

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    sessMatch = (subjects == subj);
    
    muLL = mean(trainLL(sessMatch, :), 1);
    
    h = figure;
    set(h, 'name',  sprintf('Train Set Model comparisons for Subject %d', subj));

    for row=1:nModels
        for col=1:nModels
            rowModel = models_to_plot(row);
            colModel = models_to_plot(col);
            posRow = find(v_lcid == rowModel);
            posCol = find(v_lcid == colModel);
            if isempty(posRow) || isempty(posCol)
                continue;
            end
            
            subplot(nModels, nModels, (row-1)*nModels + col);
            
            if row < col
                axis off;
%                 rowV = muLL(posRow);
%                 colV = muLL(posCol);
%                 bar([rowV, colV]);
                continue;
            elseif row == col
                [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), trainLL(sessMatch, posRow), edges);
                p = '-';
                errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(row, :));
                hold on;
                x = logspace(-3, 0, 100);
                plot(x, ones(size(x)) * log(0.5), 'k--');
                title(modelNames(colModel));
                xlabel('Contrast');
                set(gca, 'xscale', 'log');
                xlim([0.003, 1.2]);
                ylabel('Mean log likelihood');
                ylim([vmin, vmax]);
            else
                % on lower left, show scatter plot
                
                scatter(trainLL(sessMatch, posCol), trainLL(sessMatch, posRow), [], contrast(sessMatch));
                [h, p, ci] = ttest(trainLL(sessMatch, posCol), trainLL(sessMatch, posRow));
                xlabel(modelNames(colModel));
                ylabel(modelNames(rowModel));
                hold on;
                x = linspace(vmin, vmax);
                plot(x, x, '--r');
                if row ~= col
                    title(sprintf('p-val = %.3f', p));
                end
                xlim([vmin, vmax]);
                ylim([vmin, vmax]);
                
            end
        end
    end
end

%% Grid wise model performance comparison on the test set

models_to_plot = [24, 28, 32];
nModels = length(models_to_plot);
vmax = max(trainLL(:)) + 0.01;
vmin = min(trainLL(:)) - 0.01;

line_color = lines(nModels);

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    sessMatch = (subjects == subj);
    
    muLL = mean(trainLL(sessMatch, :), 1);
    
    h = figure;
    set(h, 'name',  sprintf('Test Set Model comparisons for Subject %d', subj));

    for row=1:nModels
        for col=1:nModels
            rowModel = models_to_plot(row);
            colModel = models_to_plot(col);
            posRow = find(v_lcid_test == rowModel);
            posCol = find(v_lcid_test == colModel);
            if isempty(posRow) || isempty(posCol)
                continue;
            end
            
            subplot(nModels, nModels, (row-1)*nModels + col);
            
            if row < col
                axis off;
%                 rowV = muLL(posRow);
%                 colV = muLL(posCol);
%                 bar([rowV, colV]);
                continue;
            elseif row == col
                [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), testLL(sessMatch, posRow), edges);
                p = '-';
                errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(row, :));
                hold on;
                x = logspace(-3, 0, 100);
                plot(x, ones(size(x)) * log(0.5), 'k--');
                title(modelNames(colModel));
                xlabel('Contrast');
                set(gca, 'xscale', 'log');
                xlim([0.003, 1.2]);
                ylabel('Mean log likelihood');
                ylim([vmin, vmax]);
            else

                % on lower left, show scatter plot
                
                scatter(testLL(sessMatch, posCol), testLL(sessMatch, posRow), [], contrast(sessMatch));
                [h, p, ci] = ttest(testLL(sessMatch, posCol), testLL(sessMatch, posRow));
                xlabel(modelNames(colModel));
                ylabel(modelNames(rowModel));
                hold on;
                x = linspace(vmin, vmax);
                plot(x, x, '--r');
                if row ~= col
                    title(sprintf('p-val = %.6f', p));
                end
                xlim([vmin, vmax]);
                ylim([vmin, vmax]);
            end
        end
    end
end

%% Contrast vs. mean logL plot for training set
models_to_plot = [25, 29, 32];
line_color = lines(length(models_to_plot));
h = figure(1);
set(h, 'name',  'Fit vs Contrast');

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    subplot(2, length(uniqueSubj), subjIdx);
    for idx = 1:length(models_to_plot)
        modelID = models_to_plot(idx);
        pos = find(v_lcid == modelID);
        if isempty(pos)
            continue;
        end
        sessMatch = (subjects == subj);
        
        [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), trainLL(sessMatch, pos), edges);
        p = '-';
        errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
        hold on;
    end

    x = logspace(-3, 0, 100);
    plot(x, ones(size(x)) * log(0.5), 'k--');
    title(sprintf('Fit on train set vs contrast for subject %d', subj));
    legend(modelNames(models_to_plot));
    xlabel('Contrast');
    set(gca, 'xscale', 'log');
    xlim([0.003, 1.2]);
    ylabel('Mean log likelihood');
    %ylim([log(0.5), -0.3]);
    
    subplot(2, length(uniqueSubj), length(uniqueSubj) + subjIdx);
    for idx = 1:length(models_to_plot)
        modelID = models_to_plot(idx);
        pos = find(v_lcid_test == modelID);
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
    title(sprintf('Fit on test set vs contrast for subject %d', subj));
    legend(modelNames(models_to_plot));
    xlabel('Contrast');
    set(gca, 'xscale', 'log');
    xlim([0.003, 1.2]);
    ylabel('Mean log likelihood');
    %ylim([log(0.5), -0.3]);

end
%% Contrast vs. mean logL plot for trainset and test set with error bars based on difference w.r.t. a target model
models_to_plot = [25,29,32];
% compare against this model
target_model = 25;

posTrain = find(v_lcid == target_model);
delta_train = bsxfun(@minus, trainLL, trainLL(:, posTrain));

posTest = find(v_lcid_test == target_model);
delta_test = bsxfun(@minus, testLL, testLL(:, posTest));

line_color = lines(length(models_to_plot));
h = figure;
set(h, 'name',  'Fit vs Contrast');

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    subplot(2, length(uniqueSubj), subjIdx);
    for idx = 1:length(models_to_plot)
        modelID = models_to_plot(idx);
        pos = find(v_lcid == modelID);
        fprintf('Working on %d...\n', pos);
        if isempty(pos)
            continue;
        end
        sessMatch = (subjects == subj);
        [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), delta_train(sessMatch, pos), edges);
        %[mu] = nanBinnedStats(contrast(sessMatch), trainLL(sessMatch, pos), edges);
        p = '-';
        errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
        hold on; 
    end

    title(sprintf('Fit on train set vs contrast for subject %d', subj));
    legend(modelNames(models_to_plot));
    xlabel('Contrast');
    set(gca, 'xscale', 'log');
    xlim([0.003, 1.2]);
    ylabel('Mean log likelihood');
    %ylim([log(0.5), -0.3]);
    
    subplot(2, length(uniqueSubj), length(uniqueSubj) + subjIdx);
    for idx = 1:length(models_to_plot)
        modelID = models_to_plot(idx);
        pos = find(v_lcid_test == modelID);
        if isempty(pos)
            continue;
        end
        sessMatch = (subjects == subj);
        [mu, s, n, binc] = nanBinnedStats(contrast(sessMatch), delta_test(sessMatch, pos), edges);
        %[mu] = nanBinnedStats(contrast(sessMatch), testLL(sessMatch, pos), edges);
        p = '-';
        errorbar(binc, mu, s./sqrt(n), p, 'color', line_color(idx, :));
        hold on;
    end

    %x = logspace(-3, 0, 100);
    %plot(x, ones(size(x)) * log(0.5), 'k--');
    title(sprintf('Fit on test set vs contrast for subject %d', subj));
    legend(modelNames(models_to_plot));
    xlabel('Contrast');
    set(gca, 'xscale', 'log');
    xlim([0.003, 1.2]);
    ylabel('Mean log likelihood');
    %ylim([log(0.5), -0.3]);

end

%% bar plots for delta average log likelihood across contrast relative to a taget model
models_to_plot = [2, 34, 5, 7, 25, 29, 32];
data = testLL;
targetModel = 2;

if targetModel == 0
    delta = data;
else
    posTrain = find(v_lcid == targetModel);
    delta = bsxfun(@minus, data, data(:, posTrain));
end



%NUM_MODELS = length(models_to_plot);
h = figure;
set(h, 'name',  'Average log likelihood across contrast');
width = 2;
space = 0.5;
left = space/2 + width/2;


for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    filter = subjects == subj
    
    fprintf('\nsubject %d p-values: relative to %d\n', subj, targetModel);

    
    totalLL = nansum(delta(filter,:), 1); % take average across all contrasts
    
    subplot(1, length(uniqueSubj), subjIdx);
    labels = [];
    labelPos = [];
    
    for idx = 1:length(models_to_plot)
        modelId = models_to_plot(idx);
        modelPos = find(v_lcid == modelId);
        if isempty(modelPos)
            continue;
        end

        x_pos = (idx-1)*(width + space) + left;
        labelPos = [labelPos x_pos];
        labels = [labels modelNames(modelId)];
        
        if contains(modelNames(modelId), 'flex', 'IgnoreCase', 1)
            c = [148, 252, 155] / 255;
        else
            c = [255, 187, 53] / 255;
        end
        
        h1 = bar(x_pos, totalLL(modelPos), width, 'FaceColor', c);
        hold on;
    end
    
    right = x_pos + width/2 + space;
    set(gca, 'xtick', labelPos);
    set(gca, 'xticklabel', labels);
    title(sprintf('Relative total log likelihood across contrast for Subject %d', subj));
    xlim([0, right]);
    ylabel('Relative total loglikelihood');
    %ylim([0, 1500 ]);
    rotateXLabels(gca,90);
end

