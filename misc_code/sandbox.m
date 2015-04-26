keys = fetch(class_discrimination.ContrastSessionDataSet, '*');
N = 145
data = fetchDataSet(class_discrimination.ContrastSessionDataSet & keys(N));
model = ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier();
model.train(data)
class_discrimination.TrainedLikelihoodClassifiers & sprintf('lc_trainset_id = %d', keys(N).dataset_id)


%%
keys = fetch(class_discrimination.TrainedLikelihoodClassifiers & 'lc_id = 6');
pa = zeros(1, length(keys));
for i = 1:length(keys)
    if mod(i, 10)==0
        fprintf('.');
    end
    model = getLC(class_discrimination.TrainedLikelihoodClassifiers & keys(i));
    pa(i) = model.priorA;
end
fprintf('\n');
figure;
hist(pa, 50);