%% Generates Psychometric curves for the two monkeys using all the trials for which 


close all;
figure;
nBins = 7;

subjects = [3, 21];

for subjIdx=1:length(subjects)
    subject= subjects(subjIdx);
    sessions = fetch(class_discrimination.SpikeCountSet & sprintf('subject_id = %d', subject));
    % only use trials for which we have recorded spikes
    p = fetch(class_discrimination.ClassDiscriminationTrial & sessions, '*');

    cv = [p.contrast];
    ori = [p.orientation];
    resp = {p.selected_class};
    respA = strcmp(resp, 'A');
    uniqueContrasts = unique(cv);
    c_edges = prctile(cv(:), linspace(0, 100, nBins + 1));
    c_edges = [0, 0.01, 0.02, 0.04, 0.08, 0.16, 0.32, 0.64];
    c_edges(1) = c_edges(1);
    c_edges(end) = c_edges(end);

    n = 25;
    ed1 = prctile(ori, linspace(0, 50, (n+1)/2));
    ed1 = max(ed1, 220);
    ed2 = prctile(ori, linspace(50, 100, (n+1)/2));
    ed2 = min(ed2, 320);

    ed = (fliplr(ed2) - 270 + (270 - ed1)) / 2;

    edges = [270 - ed, fliplr(ed(1:end-1)) + 270];

    %edges = linspace(250, 290, 9);
    colors = cool(length(c_edges)-1);
    threshold = 10;
    
    subplot(1, length(subjects), subjIdx);
    
    hs = [];
    labels = [];
    for i = 1:length(c_edges)-1
        c = colors(i, :);
        %contv = uniqueContrasts(i);
        low = c_edges(i);
        high = c_edges(i+1);
        contv = 0.5 * (low + high);
        filter = (cv >= low) & (cv < high);
        x = ori(filter);
        y = respA(filter);
        [mu, sigma, n, binc] = nanBinnedStats(x, y, edges);
        [v, pos] = max(mu);
        peakloc = sum(x(:) .* y(:)) ./ sum(y(:));
        %peakloc = binc(pos);
        h = plot(binc, mu, '-', 'color', c, 'LineWidth', 2);
        hold on;
        plot(peakloc, v, 'o', 'MarkerSize', 10, 'MarkerFaceColor', c, 'color', c);
        hs = [hs h];
        labels = [labels {sprintf('Contrast in [%.1f, %.1f)', max(low*100, 0.5), min(high * 100, 60))}];
        hold on;
    end
    title(sprintf('Subject %d Pyschometric curves', subject));
    xlim([250, 290]);
    xlabel('Stimulus orientation');
    ylabel('P(selecting A)');
    if subjIdx == length(subjects)
        legend(hs, labels);
    end
end