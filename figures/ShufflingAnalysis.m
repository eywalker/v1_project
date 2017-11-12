base = pro(cd_plc.TrainedPLC  & 'plc_trainset_owner like "%CleanContrast%"', 'plc_train_mu_logl -> base_logl', 'plc_trainset_hash -> source_plset_hash', 'plc_trainset_owner -> source_trainset_owner');
leaf = cd_plc.TrainedPLC * pro(cd_plset.ShuffledPLSets, 'plset_hash -> plc_trainset_hash', 'plset_owner -> plc_trainset_owner');
match = pro(base, leaf, '*', 'avg(plc_train_mu_logl) -> leaf_logl') * pro(cd_plset.CleanContrastSessionPLSet, 'plset_hash -> source_plset_hash');
id1 = pro(match & 'plc_id = 1', 'plc_id -> id1', 'base_logl -> base1', 'leaf_logl -> leaf1');
id2 = pro(match & 'plc_id = 2', 'plc_id -> id2', 'base_logl -> base2', 'leaf_logl -> leaf2');