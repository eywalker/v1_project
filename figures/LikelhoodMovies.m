rel = (cd_dataset.ContrastSessionDataSet & 'subject_id = 21' & 'dataset_contrast = 0.005');
keys = fetch(class_discrimination.ClassDiscriminationExperiment & rel);

vals = fetch(cd_decoder.DecoderTrainSets * cd_dataset.ContrastSessionDataSet & keys(10));

stimulus = 270;
delta = 0.5;
likelihoods = [];
decodeOri = linspace(220, 320, 1000);
nContrast = length(vals)
for idx=1:nContrast
    [dataset, decoder] = getAll(cd_decoder.TrainedDecoder & vals(idx));
    trials = abs(dataset.orientation - stimulus) < delta;
    counts = dataset.counts(:, trials);
    L = decoder.getLikelihoodDistr(decodeOri, dataset.contrast, counts);
    likelihoods(idx).contrast = dataset.contrast(1);
    likelihoods(idx).L = L;
end

%%
% determin the total number of examples
N = min(min(arrayfun(@(x) size(x.L, 2), likelihoods)), 30);
maxL = max(arrayfun(@(x) max(x.L(:)), likelihoods));

fs = 15;
f=figure;
set(f, 'position', [139,238,878,447]);
for frame=1:N
    for c=1:nContrast
        hold off;
        ax = subplot(1, nContrast, c);
        plot(decodeOri, likelihoods(c).L(:, frame), 'color', 'k', 'linewidth', 2);
        if c==1
            ylabel('Likelihood');
        end
        xlim([230, 310]);
        ylim([0, maxL*1.05]);
        vy = linspace(0, maxL*1.05, 100);
        vx = stimulus * ones(size(vy));
        hold on;
        plot(vx, vy, 'k--');
        
        title(sprintf('Contrast %.1f%%', likelihoods(c).contrast*100));
        set(ax, 'fontsize', fs);
        set(ax, 'xtick', [230:20:310]);
        set(ax, 'ytick', []);
        xlabel('Stimulus orientation');
    end
    pause();
end
    
