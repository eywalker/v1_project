result =[]
for idx=1:20
    result = [result sessionData(idx).simpleFitResults.cvContrast];
end

%%
fits = [];
contrasts=[result.contrast];
for idxResult = 1:length(result)
    models = result(idxResult).modelFits;
    fits = [fits; [models.trainLL]];
end

selected = fits(:,[3, 5,6]);

peak = selected(:,1) - selected(:,3);
pw = selected(:,2) - selected(:,3);
%% Make bar plots


muPeak = mean(peak);
semPeak = std(peak) / sqrt(length(peak))
muPW = mean(pw);
semPW = std(pw) / sqrt(length(pw))
help bar
figure;bar(1, muPeak,'r'); hold on; bar(2, muPW, 'b')
errorbar([1,2],[muPeak, muPW], [semPeak, semPW], 'linestyle','none')
errorbar([1,2],[muPeak, muPW], [semPeak, semPW], 'k','linestyle','none')
legend({'Mean only', 'Mean and Standard deviation'})

xlim([0.5,2.5])
set(gca,'xtick',[])
xlabel('Models');
ylabel('Log likelihood relative to Full-likelihood model')
%%
binEdges = [0.005, 0.015, 0.025, 0.055, 0.16, 0.32];
%binEdges = logspace(log10(0.005), log10(0.32),10);
figure;
[peakMu, peakStd, peakN, binc,bins]=nanBinnedStats(contrasts, peak, binEdges);
peakSEM = peakStd ./ sqrt(peakN);
errorbar(binc*100, peakMu, peakSEM, 'r');
hold on;
[pwMu, pwStd, pwN, binc] = nanBinnedStats(contrasts, pw, binEdges);
pwSEM = pwStd ./ sqrt(pwN);
errorbar(binc*100, pwMu, pwSEM, 'b');
xlabel('Contrast (%)');
ylabel('Log likelihood relative to Full-likelihood model');
legend({'Mean only', 'Mean and Standard deviation'})

%% Bars grouped by model
binEdges = [0.005, 0.015, 0.025, 0.055, 0.32];
%binEdges = logspace(log10(0.005), log10(0.32),10);
figure;
[peakMu, peakStd, peakN, binc,bins]=nanBinnedStats(contrasts, peak, binEdges);
peakSEM = peakStd ./ sqrt(peakN);
bar(1:length(binc), peakMu, 0.9, 'r');
hold on;
errorbar(1:length(binc), peakMu, peakSEM, 'k','linestyle','none');

[pwMu, pwStd, pwN, binc] = nanBinnedStats(contrasts, pw, binEdges);
pwSEM = pwStd ./ sqrt(pwN);
bar([1:length(binc)]+length(binc)+1, pwMu, 0.9, 'b');
hold on;
errorbar([1:length(binc)]+length(binc)+1, pwMu, pwSEM, 'k','linestyle','none');
xlabel('Contrast (%)');
ylabel('Log likelihood relative to Full-likelihood model');
legend({'Mean only', 'Mean and Standard deviation'})

%% Bars grouped by contrast
binEdges = [0.005, 0.015, 0.025, 0.055, 0.32];
%binEdges = logspace(log10(0.005), log10(0.32),10);
figure;
[peakMu, peakStd, peakN, binc,bins]=nanBinnedStats(contrasts, peak, binEdges);
peakSEM = peakStd ./ sqrt(peakN);
bar(1:2:2*length(binc), peakMu, 0.4, 'r');
hold on;
errorbar(1:2:2*length(binc), peakMu, peakSEM, 'k','linestyle','none');

[pwMu, pwStd, pwN, binc] = nanBinnedStats(contrasts, pw, binEdges);
pwSEM = pwStd ./ sqrt(pwN);
bar(2:2:2*length(binc), pwMu, 0.4, 'b');
hold on;
errorbar(2:2:2*length(binc), pwMu, pwSEM, 'k','linestyle','none');
xlabel('Contrast (%)');
ylabel('Log likelihood relative to Full-likelihood model');
legend({'Mean only', 'Mean and Standard deviation'})


%% Examples decoded likelihoods

nocv=[sessionData.simpleFitResults];
contInfo=[nocv.cvContrast]
dataSet=[contInfo.dataSet]
conts=[contInfo.contrast]

% High contrasts
contrast = conts(23);
L=[dataSet(23).likelihood];
decodeOri = dataSet(23).decodeOri;
figure;
plot(decodeOri, L(:,3))%3,20
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))
figure;
plot(decodeOri, L(:,20))%3,20
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))
%%
% Mid contrast
contrast = conts(8);
L=[dataSet(8).likelihood];
decodeOri = dataSet(8).decodeOri;
figure;
plot(decodeOri, L(:,13))%13,170
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))

figure;
plot(decodeOri, L(:,193))%13,170
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))

%%
% Low contrast
contrast = conts(1);
L=[dataSet(1).likelihood];
decodeOri = dataSet(1).decodeOri;
figure;
plot(decodeOri, L(:,20))%20,324
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))
figure;
plot(decodeOri, L(:,324))%20,324
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))

%%
% Very low contrast
contrast = conts(3);
L=[dataSet(3).likelihood];
decodeOri = dataSet(3).decodeOri;
figure;
plot(decodeOri, L(:,65))%20,324
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))
figure;
plot(decodeOri, L(:,123))%20,324
xlabel('Orientation (deg)');
ylabel('Likelihood');
title(sprintf('Contrast = %d%%', contrast * 100))





