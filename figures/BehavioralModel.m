sessions = class_discrimination.ClassDiscriminationExperiment & 'subject_id = 21' & acq.Sessions('session_datetime > "2014-10-01"', 'session_datetime < "2015-01"');
data = fetch(class_discrimination.ClassDiscriminationTrial & sessions, '*');
pdata1 = packData(data);

sessions = class_discrimination.ClassDiscriminationExperiment & 'subject_id = 21' & acq.Sessions('session_datetime > "2015-04-01"');
data = fetch(class_discrimination.ClassDiscriminationTrial & sessions, '*');
pdata2 = packData(data);
%% Look at performance across contrast


edges = arrayfun(@(x) prctile(pdata1.contrast, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
[mu1, sigma1, n1, binc] = nanBinnedStats(pdata1.contrast, pdata1.correct_response, edges);
figure;
sem1 = sigma1 ./ sqrt(n1);
errorbar(binc, mu1*100, sem1*100, 'b');
hold on;
%errorShade(binc, mu1*100, sem1*100, [0, 0.5, 1], 0.2);

edges = arrayfun(@(x) prctile(pdata2.contrast, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
[mu2, sigma2, n2, binc] = nanBinnedStats(pdata2.contrast, pdata2.correct_response, edges);
sem2 = sigma2 ./ sqrt(n2);
hold on;
errorbar(binc, mu2*100, sem2*100, 'g');
%errorShade(binc, mu2*100, sem2*100, [0,0.5, 0], 0.2);
set(gca, 'xscale', 'log');
set(gca, 'xticklabel', [0.1, 1, 10, 100]);
xlabel('Stimulus contrast (%)');
ylabel('Performance (% correct)');
legend({'Oct - Dec, 2014', 'Feb, 2015 - Now'})
x = logspace(-3, 0, 100);
t = ones(size(x));
y = t * 0.8236 * 100
plot(x, y, 'k--');
plot(x, t*50, 'k--');

%% Resp A vs contrast and Resp B vs contrast 
pdata = pdata2;
edges = arrayfun(@(x) prctile(pdata.contrast, x), 0:10:100);
edges = [0, unique(edges), 1];
edges = 0.5*(edges(1:end-1) + edges(2:end));
select_a = strcmp(pdata.selected_class,'A');
select_b = strcmp(pdata.selected_class, 'B');
[muA, sigmaA, nA, binc] = nanBinnedStats(pdata.contrast, select_a, edges);
[muB, sigmaB, nB, binc] = nanBinnedStats(pdata.contrast, select_b, edges);
figure;
semA = sigmaA ./ sqrt(nA);
semB = sigmaB ./ sqrt(nB);
errorbar(binc, muA*100, semA*100, 'r');
hold on;
errorbar(binc, muB*100, semB*100, 'g');

%%

sessions = class_discrimination.ClassDiscriminationExperiment & 'subject_id = 21' & acq.Sessions('session_datetime > "2015-04-01"');
data = fetch(class_discrimination.ClassDiscriminationTrial & sessions, '*');
pdata = packData(data);
%% Look how re

%%
model_bayes = ClassifierModel.BehavioralClassifier.BehavioralBPLClassifier();
model_bayes.train(pdata, 10);
%%
model_nb = ClassifierModel.BehavioralClassifier.FixedCriterionClassifier();
model_nb.train(pdata, 10);
%% plot bayesian model
test_data = struct();
test_ori = linspace(250, 290, 1000);
test_data.orientation = test_ori;
base = ones(size(test_data.orientation));

ori_edges = linspace(250,290,21);

cont = unique(pdata.contrast);
figure;
selected_a = strcmp(pdata.selected_class, 'A');
line_c = lines(length(cont));
subset = [0.005, 0.01, 0.02, 0.04, 0.06, 0.1];
labels = {}
handles = [];
for i = 1:length(subset)
    cont_val = subset(i);
    pos = pdata.contrast == cont_val;
    select = selected_a(pos);
    ori = pdata.orientation(pos);
    [mu, sigma, n, binc] = nanBinnedStats(ori, select, ori_edges);
    h=plot(binc, mu, 'o', 'color', line_c(i,:));
    handles = [handles h];
    hold on;
    labels = [labels {sprintf('contrast = %.2f%', cont_val * 100)}];
    
    
    test_data.contrast = base * cont_val;
    pA = model_bayes.pRespA(test_data);
    plot(test_ori, pA, 'color', line_c(i,:));
end
legend(handles, labels)
%% plot non-bayesian model
test_data = struct();
test_ori = linspace(250, 290, 1000);
test_data.orientation = test_ori;
base = ones(size(test_data.orientation));

ori_edges = linspace(250,290,21);

cont = unique(pdata.contrast);
figure;
selected_a = strcmp(pdata.selected_class, 'A');
line_c = lines(length(cont));
subset = [0.005, 0.01, 0.02, 0.04, 0.06, 0.1];
labels = {}
handles = [];
for i = 1:length(subset)
    cont_val = subset(i);
    pos = pdata.contrast == cont_val;
    select = selected_a(pos);
    ori = pdata.orientation(pos);
    [mu, sigma, n, binc] = nanBinnedStats(ori, select, ori_edges);
    h=plot(binc, mu, 'o', 'color', line_c(i,:));
    handles = [handles h];
    hold on;
    labels = [labels {sprintf('contrast = %.2f%', cont_val * 100)}];
    
    
    test_data.contrast = base * cont_val;
    pA = model_nb.pRespA(test_data);
    plot(test_ori, pA, 'color', line_c(i,:));
end
legend(handles, labels)