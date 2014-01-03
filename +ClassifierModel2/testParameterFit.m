%%
import ClassifierModel.*;
pARange = linspace(0.5,0.9,50);
lapseRateRange = 0; %linspace(0,1,30);
sigmaRange = linspace(0,10,50); %linspace(0,10,10);

[paV, lapseV, sigmaV] = meshgrid(pARange, lapseRateRange, sigmaRange);

paV = paV(:);
lapseV = lapseV(:);
sigmaV = sigmaV(:);

llGen = zeros(size(paV));

paFit = zeros(size(paV));
lapseFit = zeros(size(lapseV));
sigmaFit = zeros(size(sigmaV));

llFit = zeros(size(llGen));

generator = BPLClassifier(5, 15, 0);
tester = BPLClassifier(5, 15, 0);
%%


stimulus = randn(1,10000)*10;
h = waitbar(0,'Working...');
for ind = 1:length(paV)
    generator.priorA = paV(ind);
    generator.lapseRate = lapseV(ind);
    generator.sigma = sigmaV(ind);
    
    resp = generator.classify(stimulus, []);
    llGen(ind) = generator.getLogLikelihood(stimulus, [], resp);
    llFit(ind) = tester.train(stimulus, [], resp);
    
    paFit(ind) = tester.priorA;
    lapseFit(ind) = tester.lapseRate;
    sigmaFit(ind) = tester.sigma;
    waitbar(ind/length(paV),h, sprintf('Working...(%f %% completed)',ind/length(paV)));
end
close(h);

%%
close all;
figure;
plot(paV, paFit,'*');
hold on;
plot(0:0.01:1,0:0.01:1);
title('PriorA')
xlabel('True');
ylabel('Estimated');

figure;
plot(lapseV, lapseFit, '*');
hold on;
plot(0:0.01:1,0:0.01:1);
title('Lapse rate');
xlabel('True');
ylabel('Estimated');

figure;
plot(sigmaV, sigmaFit, '*');
hold on;
plot(0:0.1:10,0:0.1:10);
title('Sigma');
xlabel('True');
ylabel('Estimated');

figure;
plot(llGen,llFit,'*');
x = linspace(min(llGen),max(llGen),100);
hold on;
plot(x, x, '--');
title('Log Likelihood');
xlabel('True');
ylabel('Model Fit');
