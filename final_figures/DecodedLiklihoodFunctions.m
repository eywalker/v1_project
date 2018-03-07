 keys = fetch(class_discrimination.CSCLookup & 'subject_id = 21');
 % 41 is good candidate
 sessions = cd_dataset.CleanContrastSessionDataSet & keys(48);
 
 decs = fetch(cd_decoder.TrainedDecoder * pro(sessions, 'dataset_hash -> dec_trainset_hash') & 'decoder_id = 3', 'ORDER BY dataset_contrast');
 
 figure;
 xq = linspace(-50, 50, 1000);
 legends = {};
 hline = [];
 hpatch = [];
 c = lines(length(decs));
 for i=1:length(decs)
     [dataset, decoder] = getAll(cd_decoder.TrainedDecoder & decs(i));
     decodeOri = linspace(220, 320, 1000); 
     L = decoder.getLikelihoodDistr(decodeOri, [], dataset.counts);
     
     %peak = (decoder.decodeOri * L) ./ sum(L);
     [peak, std] = ClassifierModel.getMeanStd(decodeOri, L);
     %[~, p] = max(L);
     %peak = decoder.decodeOri(p);
     %peak = dataset.orientation;
     delta = decodeOri' - peak;
     
     
     [sori,v] = sort(dataset.orientation);
     thr = prctile(L, 99, 1);
     p = (L>thr);
     
     Lx = L .* (1-p) + p .* thr;
     Lx = Lx ./ max(Lx);
     Lx = Lx(:, v);
     subplot(3, 2, 2 + i);
     imagesc(Lx, 'YData', [min(decodeOri), max(decodeOri)]);
     ylim([250, 290]);
     hold on;
     plot(1:length(sori), sori, 'color', 'k', 'LineWidth', 2);
     xlabel('Trials');
     ylabel('Estimated orientation');
     title(sprintf('contrast=%.1f%%', 100 * dataset.contrast(1)))
     
     
     Lall = [];
     for idxL = 1:size(L, 2)
         Lq = interp1(delta(:, idxL), L(:, idxL), xq, 'spline', 0);
         Lall = [Lall; Lq];
     end
     %subplot(1, length(decs), i);
     Ls = mean(Lall);
     %Ls = Ls / sum(Ls);
     subplot(3, 2, 1);
     
     h = plot(xq, Ls, 'LineWidth', 1.5);
     hline = [hline h];
     hold on;
     legends = [legends {sprintf('contrast=%.1f%%', 100 * dataset.contrast(1))}];
     xlim([-20, 20]);
     xlabel('Relative orientation');
     ylabel('Likelihood (a.u.)');
     
     
     subplot(3, 2, 2);
     if i==1
         x = linspace(250, 290, 100);
         plot(x, x, 'k--');
         hold on;
     end
     %scatter(dataset.orientation, peak);
     xlim([250, 290]);
     ylim([250, 290]);
     xlabel('True stimulus orientation');
     ylabel('MAP stimulus orientatin');
     %edges = prctile(dataset.orientation, linspace(0, 100, 7));
     %edges(1) = edges(1) - 1;
     %edges(end) = edges(end) + 1;
     edges = linspace(230, 310, 6);
     
     [mu, sigma, n, binc] = nanBinnedStats(dataset.orientation, peak,edges);
     [sigma, ~, n, binc] = nanBinnedStats(dataset.orientation, std,edges);

     sem = sigma ./ sqrt(n);
     h = errorShade(binc, mu, sigma, c(i, :), 0.5);
     hpatch = [hpatch h];
     hold on;
 end
 legend(hpatch, legends);
 legend(hline, legends);
 