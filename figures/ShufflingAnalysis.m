base = pro(cd_plc.TrainedPLC  & 'plc_trainset_owner like "%CleanContrast%"', 'plc_train_mu_logl -> base_logl', 'plc_trainset_hash -> source_plset_hash', 'plc_trainset_owner -> source_trainset_owner');
leaf = cd_plc.TrainedPLC * pro(cd_plset.ShuffledPLSets, 'plset_hash -> plc_trainset_hash', 'plset_owner -> plc_trainset_owner');
match = pro(base, leaf, '*', 'avg(plc_train_mu_logl) -> leaf_logl') * pro(cd_plset.CleanContrastSessionPLSet, 'plset_hash -> source_plset_hash');
id1 = pro(match & 'plc_id = 1', 'plc_id -> id1', 'base_logl -> base1', 'leaf_logl -> leaf1');
id2 = pro(match & 'plc_id = 2', 'plc_id -> id2', 'base_logl -> base2', 'leaf_logl -> leaf2');


[base1, base2, leaf1, leaf2, c] = fetchn(id1 * id2, 'base1', 'base2', 'leaf1', 'leaf2', 'dataset_contrast');
cv = cellfun(@str2num, c);
%%
edges = prctile(cv, linspace(0, 100, 10));


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


