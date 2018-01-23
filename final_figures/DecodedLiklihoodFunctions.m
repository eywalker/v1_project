 keys = fetch(class_discrimination.CSCLookup & 'subject_id = 21');
 
 sessions = cd_dataset.CleanContrastSessionDataSet & keys(30);
 
 decs = fetch(cd_decoder.TrainedDecoder & pro(sessions, 'dataset_hash -> dec_trainset_hash') & 'decoder_id = 3');
 
 figure;
 xq = linspace(-50, 50, 1000);
 legends = {};
 for i=1:length(decs)
     [dataset, decoder] = getAll(cd_decoder.TrainedDecoder & decs(i));
     L = decoder.getLikelihoodDistr(decoder.decodeOri, [], dataset.counts);
     
     %[~, p] = max(L);
     %peak = decoder.decodeOri(p);
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
     plot(xq + 270, Ls);
     hold on;
     legends = [legends {sprintf('contrast=%.2f', 100 * dataset.contrast(1))}];
 end
 legend(legends);
 