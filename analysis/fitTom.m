tomkeys = fetch(class_discrimination.ClassDiscriminationExperiment & 'subject_id = 21') % 21 for Tom
data = fetch(class_discrimination.ClassDiscriminationTrial & tomkeys(end), '*')
pdata = packData(data);

model = ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier();
model.train(pdata, 5);

model_fixed =  ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier();
model_fixed.fixParameterByName('a');
model_fixed.fixParameterByName('beta');
model_fixed.a = 0;
model_fixed.beta = -1;
model_fixed.train(pdata, 5);

%% grid search
params = model.params(~model.fixedParams);
lb = model.p_lb(~model.fixedParams);
ub = model.p_ub(~model.fixedParams);
N = 20;
param_values = {}
for i = 1:length(params)
    param_values = [param_values {linspace(lb(i), ub(i))}];
end
param_grid = {};
[a, b, c, d] = ndgrid(param_values{:});

maxPos = 0;
maxScore = 0;
for i = 1:length(a(:))
    fprintf('Working on %d out of %d...\n', i, length(a(:)));
    model.setModelParameters([a(i), b(i), c(i), d(i)]);
    score = model.getLogLikelihood(pdata);
    if score > maxScore
        maxPos = i;
    end
end
