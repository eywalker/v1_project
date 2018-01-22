base = pro(cd_plc.TrainedPLC  & 'plc_trainset_owner like "%CleanContrast%"', 'plc_train_mu_logl -> base_logl', 'plc_trainset_hash -> source_plset_hash', 'plc_trainset_owner -> source_trainset_owner');
leaf = cd_plc.TrainedPLC * pro(cd_plset.ShuffledPLSets, 'plset_hash -> plc_trainset_hash', 'plset_owner -> plc_trainset_owner');
match = pro(base, leaf, '*', 'avg(plc_train_mu_logl) -> leaf_logl') * pro(cd_plset.CleanContrastSessionPLSet * class_discrimination.CSCLookup,'*', 'plset_hash -> source_plset_hash');

%%
data = fetch(match, '*');
indexFields = {'source_plset_hash', 'plc_id'};
[original, v_hash, v_id] = dj.struct.tabulate(data, 'base_logl', indexFields{:});
shuffled = dj.struct.tabulate(data, 'leaf_logl', indexFields{:});
contrast = dj.struct.tabulate(data, 'dataset_contrast', indexFields{:});
subjects = dj.struct.tabulate(data, 'subject_id', indexFields{:});

cv = cellfun(@str2num, contrast);
cv = cv(:, 1);
subjects = subjects(:, 1);

uniqueSubj = unique(subjects);

%% build the model names - robust to case of skipping lc_id
modelNames = {};
for m=fetch(cd_lc.LCModels, 'lc_label')'
    modelNames{m.lc_id} = m.lc_label;
end

%% Plot shuffled vs not-shuffled
%edges = logspace(-4, 0, 8);
figure;

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    sessMatch = (subjects == subj);
    
    subplot(1, length(uniqueSubj), subjIdx);
    
    filter = cv > 0.002;
    edges = prctile(cv(filter), linspace(0, 100, 6));
    edges(1) = edges(1) - 0.001;
    edges(end) = edges(end) + 0.001;
    hold on;
    colors = lines;
    handles = [];
    labels = [];
    for i=1:length(v_id)

        [mu, sigma, count, binc] = nanBinnedStats(cv(sessMatch), original(sessMatch, i), edges);
        h = errorbar(binc, mu, sigma./sqrt(count), 'color', colors(i, :));

        [mu, sigma, count, binc] = nanBinnedStats(cv(sessMatch), shuffled(sessMatch, i), edges);
        errorbar(binc, mu, sigma./sqrt(count),'--', 'color', colors(i, :));

    end
    set(gca, 'XScale', 'log')
end

%% Plot shuffled vs not-shuffled relative to baseline
%edges = logspace(-4, 0, 8);
figure;

target = 1;
pos = find(v_id == 1);
deltaOriginal = original - original(:, pos);
deltaShuffled = shuffled - shuffled(:, pos);

for subjIdx = 1:length(uniqueSubj)
    subj = uniqueSubj(subjIdx);
    sessMatch = (subjects == subj) & cv > 0.004;
    
    subplot(1, length(uniqueSubj), subjIdx);
    
    filter = cv > 0.002;
    edges = prctile(cv(filter), linspace(0, 100, 7));
    edges(1) = edges(1) - 0.001;
    edges(end) = edges(end) + 0.001;
    hold on;
    colors = lines;
    handles = [];
    labels = [];
    for i=1:length(v_id)
        [mu, sigma, count, binc] = nanBinnedStats(cv(sessMatch), deltaOriginal(sessMatch, i), edges);
        h = errorbar(binc, mu, sigma./sqrt(count), 'color', colors(i, :), 'linewidth', 2);
        handles = [handles h];
        labels = [labels {modelNames{i} }];

        [mu, sigma, count, binc] = nanBinnedStats(cv(sessMatch), deltaShuffled(sessMatch, i), edges);
        h = errorbar(binc, mu, sigma./sqrt(count),'--', 'color', colors(i, :), 'linewidth', 2);
        handles = [handles h];
        labels = [labels {[modelNames{i} ' - shuffled']}];
    end
    title(sprintf('Subject %d', subj));
    set(gca, 'XScale', 'log');
    legend(handles, labels);
    xlabel('Contrast');
    ylabel('Difference in mean log-likelihood');
    ylim([-0.05, 0.15]);
end
%%

id1 = pro(match & 'plc_id = 1', 'plc_id -> id1', 'base_logl -> base1', 'leaf_logl -> leaf1');
id2 = pro(match & 'plc_id = 2', 'plc_id -> id2', 'base_logl -> base2', 'leaf_logl -> leaf2');


[base1, base2, leaf1, leaf2, c] = fetchn(id1 * id2, 'base1', 'base2', 'leaf1', 'leaf2', 'dataset_contrast');
cv = cellfun(@str2num, c);
%%


%%
figure;
lv = log(0.5);
x = linspace(lv, 0);


subplot(2, 2, 1);
scatter(base1, base2, [], cv);
hold on;
plot(x, x, '--');
xlabel('Original model 1');
ylabel('Original model 2');
axis([lv, 0, lv, 0]);

subplot(2, 2, 2);
scatter(base2, leaf2, [], cv);
hold on;
plot(x, x, '--');
xlabel('Original model 2');
ylabel('Shuffled model 2');
axis([lv, 0, lv, 0]);


subplot(2, 2, 3);
scatter(base1, leaf1, [], cv);
hold on;
plot(x, x, '--');
xlabel('Original model 1');
ylabel('Shuffled model 1');
axis([lv, 0, lv, 0]);


subplot(2, 2, 4);
scatter(leaf1, leaf2, [], cv);
hold on;
plot(x, x, '--');
xlabel('Shuffled model 1');
ylabel('Shuffled model 2');
axis([lv, 0, lv, 0]);


