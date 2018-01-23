keys = fetch(class_discrimination.CSCLookup & 'subject_id = 21');

sessions = cd_dataset.CleanContrastSessionDataSet & keys(30);

decs = fetch(cd_decoder.TrainedDecoder & pro(sessions, 'dataset_hash -> dec_trainset_hash') & 'decoder_id = 1');

margin = 0.05;
w = (1 - 2*margin)/10;
ROW = ceil(sqrt(self.NUM_UNITS));
COL = ceil(self.NUM_UNITS/ROW);
lb = 230;%min(self.trainStimulus);
ub = 310;%max(self.trainStimulus);
stim = linspace(lb, ub, 100);

spikeCounts = base.encode(stim);
indSkip = [1, 10, 91, 100];
count = 1;
for indUnit=1:100
    if ismember(indUnit, indSkip)
        continue;
    end
    %hax=subplot(ROW,COL,indUnit);
    hax = axes;
    scale=max(spikeCounts(count,:))-min(spikeCounts(count,:));
    hf=plot(stim,(spikeCounts(count,:)-min(spikeCounts(count,:)))/scale);
    xlabel([]);o
    ylabel([]);
    set(hax,'Position',[margin+w*floor((indUnit-1)/10), margin + w*mod(indUnit-1, 10), w, w]);
    set(hax,'xtick',[],'ytick',[]);
    set(hax,'xticklabel',[]);
    set(hax,'yticklabel',[]);
    count = count + 1;
    xlim([lb, ub]);
    ylim([-.05,1.05])
    %ylim([0, 10]);
end

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
