tomkeys = fetch(class_discrimination.ClassDiscriminationExperiment & 'subject_id = 21') % 21 for Tom
data = fetch(class_discrimination.ClassDiscriminationTrial & tomkeys(end-10:end), '*')
pdata = packData(data);

model = ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier();
model.train(pdata, 5);
%%
model_fixed =  ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier();
model_fixed.fixParameterByName('alpha');
model_fixed.fixParameterByName('beta');
model_fixed.alpha = 0;
model_fixed.beta = -1;