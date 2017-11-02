
% group trials by contrast for each session
parpopulate(class_discrimination.ContrastSessionDataSet);

% train Gaussian Process tuning curves on each contrast-session
parpopulate(class_discrimination.DecoderTrainSets, pro(class_discrimination.ContrastSessionDataSet, 'dataset_id -> decoder_trainset_id'));
parpopulate(class_discrimination.TrainedDecoder);

% now train likelihood classifiers on ContrastSessions and then test on
% shuffled contrast-sessions. To do that, register pairing between Decoder
% based on a contrast-session and likelihood-classifier training set based
% on the same contrast-session

parpopulate(class_discrimination.LCTrainSets, pro(class_discrimination.ContrastSessionDataSet, 'dataset_id -> lc_trainset_id'));

%pair contrast-session to itself to be used both in training tuning curve
%and in training likelihood classifiers
contrastSessions = fetch(class_discrimination.ContrastSessionDataSet, '*');
for i = 1:length(contrastSessions)
    dataset_id = contrastSessions(i).dataset_id;
    registerPair(class_discrimination.LCTrainSetPairs, dataset_id, dataset_id);
end

% register shuffled set as test sets for LC, and pair them with respective
% contrast-session train-sets
parpopulate(class_discrimination.LCTestSets, pro(class_discrimination.SCGroupedShuffledDataSets, 'dataset_id -> lc_testset_id'));
%%
trainTestPairs = pro(class_discrimination.ContrastSessionDataSet, 'dataset_id -> lc_trainset_id') * ...
    pro(class_discrimination.SCGroupedShuffledDataSets, 'dataset_id -> lc_testset_id');
missing = fetch(trainTestPairs - class_discrimination.LCTrainTestPairs, '*');
for i = 1:length(missing)
    registerPair(class_discrimination.LCTrainTestPairs, missing(i).lc_trainset_id, missing(i).lc_testset_id);
end
%%

% finally train up likelihood classifiers
parpopulate(class_discrimination.TrainedLikelihoodClassifiers, trainTestPairs);

% ...and test on corresponding shuffled set
parpopulate(class_discrimination.LCModelFits, trainTestPairs);


