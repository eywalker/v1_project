subject = 3;
sessions = fetch(class_discrimination.SpikeCountSet & sprintf('subject_id = %d', subject));
p = fetch(class_discrimination.ClassDiscriminationTrial & sessions(end-50:end), '*');

cv = [p.contrast];
ori = [p.orientation];
resp = {p.selected_class};
respA = strcmp(resp, 'A');
uniqueContrasts = unique(cv);



%%
edges = linspace(250, 290, 26);
colors = cool(length(uniqueContrasts));
threshold = 1000;
figure;
hs = [];
labels = [];
for i = 1:length(uniqueContrasts)
    c = colors(i, :);
    contv = uniqueContrasts(i);
    filter = cv == contv;
    if sum(filter) < threshold
        continue;
    end
    x = ori(filter);
    y = respA(filter);
    [mu, sigma, n, binc] = nanBinnedStats(x, y, edges);
    [v, pos] = max(mu);
    peakloc = binc(pos);
    h = plot(binc, mu, 'color', c);
    hold on;
    plot(peakloc, v, 'o', 'MarkerSize', 15, 'MarkerFaceColor', c, 'color', c);
    hs = [hs h];
    labels = [labels {sprintf('Contrast = %.3f', contv * 100)}];
    hold on;
end
title(sprintf('Subject %d Pyschometric curves', subject));
xlabel('Stimulus orientation');
ylabel('P(selecting A)');
legend(hs, labels);