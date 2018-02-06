keys = fetch(cd_lc.TrainedLC & 'decoder_id = 3', 'LIMIT 10');
[dataset, decoder, model] = getAll(cd_lc.TrainedLC & keys(7));

%%
close all;
x = dataset.decodeOri;
L = dataset.likelihood;

peakExtractor = @ClassifierModel.getMeanStd;

v = shufflePositionWithinBin(dataset.orientation, 2);
peak = peakExtractor(x, L);

Lshuffled = L(:, v);
pmoved = peak(v);

shift = peak - pmoved;

Lshifted = shiftFunction(x, Lshuffled, shift);

newPeak = peakExtractor(x, Lshifted);

figure;
dd = linspace(min(peak), max(peak));
scatter(peak, newPeak);
hold on;
plot(x, x, '--k');

%%
figure;
N = 5;
shuffledDS = shuffleDataSet(cd_shuffle.ShuffleParam, dataset);
x = dataset.decodeOri;
L = dataset.likelihood;
Ls = shuffledDS.likelihood;
probe=randperm(length(x));
for i=1:N*N
    subplot(N, N, i);
    plot(x, L(:,probe(i)));hold on;plot(x, Ls(:,probe(i)))
end




