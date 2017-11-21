edges = linspace(240, 300, 11);
keys = fetch(cd_plset.CleanContrastSessionPLSet);
dataset = [];
for idx=1:length(keys)
    fprintf('Working on %d out of %d...\n', idx, length(keys));
    k = keys(idx);
    dset = [];
    plset = fetchPLSet(cd_plset.CleanContrastSessionPLSet & k);
    contrast = plset.contrast(1);
    subject = plset.subject_id(1);
    s = plset.orientation;
    w = plset.likelihood_width;
    [mu, sigma, count, binc] = nanBinnedStats(s, w, edges);
    dset.binc = binc;
    dset.mu = mu;
    dset.contrast = contrast;
    dset.subject = subject;
    dataset = [dataset dset];
    %title(sprintf('Subject %d at contrast %s', subject, contrast));
end

%%
figure;
c = [0, 0.9, 0.9];
cv = [dataset.contrast];

subset = dataset(cv < 0.5);
for i=1:length(subset)
    dset = subset(i);
    plot(dset.binc, dset.mu, 'color', 0.8*c*sqrt(dset.contrast) + 0.2*c);
    hold on;
end