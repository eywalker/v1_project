 keys = fetch(class_discrimination.CSCLookup & 'subject_id = 21');
 
 sessions = cd_dataset.CleanContrastSessionDataSet & keys(41);
 
 decs = fetch(cd_decoder.TrainedDecoder & pro(sessions, 'dataset_hash -> dec_trainset_hash') & 'decoder_id = 3');
 
 figure;
 xq = linspace(-50, 50, 1000);
 legends = {};
 hline = [];
 hpatch = [];
 c = lines(length(decs));
 for i=1:length(decs)
     [dataset, decoder] = getAll(cd_decoder.TrainedDecoder & decs(i));
     L = decoder.getLikelihoodDistr(decoder.decodeOri, [], dataset.counts);
     
     %peak = (decoder.decodeOri * L) ./ sum(L);
     [~, p] = max(L);
     peak = decoder.decodeOri(p);
     %peak = dataset.orientation;
     delta = decoder.decodeOri' - peak;
     Lall = [];
     for idxL = 1:size(L, 2)
         Lq = interp1(delta(:, idxL), L(:, idxL), xq, 'spline', 0);
         Lall = [Lall; Lq];
     end
     %subplot(1, length(decs), i);
     Ls = mean(Lall);
     %Ls = Ls / sum(Ls);
     subplot(1, 2, 1);
     

     h = plot(xq, Ls);
     hline = [hline h];
     hold on;
     legends = [legends {sprintf('contrast=%.2f', 100 * dataset.contrast(1))}];
     xlim([-30, 30]);
     xlabel('Relative orientation');
     ylabel('Likelihood (a.u.)');
     
     
     subplot(1, 2, 2);
     if i==1
         x = linspace(240, 300, 100);
         plot(x, x, 'k--');
         hold on;
     end
     %scatter(dataset.orientation, peak);
     xlim([240, 300]);
     ylim([240, 300]);
     xlabel('True stimulus orientation');
     ylabel('Max likelihood decoded stimulus orientatin');
     %edges = prctile(dataset.orientation, linspace(0, 100, 7));
     %edges(1) = edges(1) - 1;
     %edges(end) = edges(end) + 1;
     edges = linspace(230, 310, 6);
     
     [mu, sigma, n, binc] = nanBinnedStats(dataset.orientation, peak,edges);
     sem = sigma ./ sqrt(n);
     h = errorShade(binc, mu, sem, c(i, :), 0.5);
     hpatch = [hpatch h];
     hold on;
 end
 legend(hpatch, legends);
 legend(hline, legends);
 