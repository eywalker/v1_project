keys = fetch(class_discrimination.CSCLookup & 'subject_id = 21');

sessions = fetch(pro(cd_dataset.CleanContrastSessionDataSet & keys(41), 'dataset_hash -> dec_trainset_hash'), '*');
contrasts = cellfun(@str2num, {sessions.dataset_contrast});
[~, pos] = sort(contrasts, 'descend');

%%
close all;
figure;
count = 1;
hList = [];
NUM_UNITS = 96;
ROW = ceil(sqrt(NUM_UNITS));
COL = ceil(NUM_UNITS/ROW);
indSkip = [1, 10, 91, 100]; % index to skip - trick to get corners ignored
margin = 0.05;
padding = 0.005;
w = (1 - 2*margin - 9 * padding)/10 ;

lb = 230;%min(self.trainStimulus);
ub = 310;%max(self.trainStimulus);

for indUnit=1:100
    if ismember(indUnit, indSkip)
        continue;
    end
    %hax=subplot(ROW,COL,indUnit);
    hax = axes('XColor', 'none', 'YColor', 'none');
    hList = [hList hax];
    xlabel([]);
    ylabel([]);
    x = linspace(lb, ub);
    %plot(x, x);
    set(hax,'Position',[margin+(w+padding)*floor((indUnit-1)/10), margin + (w+padding)*mod(indUnit-1, 10), w, w]);
    
    
    %ylim([-.05,1.05])
    %axis off;
    %ylim([0, 10]);
end
%%
leg = {}
for idx = pos
    dec = fetch(cd_decoder.TrainedDecoder & sessions(idx) & 'decoder_id = 1');
    [dataSet, model] = getAll(cd_decoder.TrainedDecoder & dec);
    contVal = contrasts(idx);
    baseEnc = model.baseEncoder; % tuning curve encoder
    stim = linspace(lb, ub, 100);
    leg = [leg {sprintf('Contrast = %.2f', 100 * contVal)}];
    spikeCounts = baseEnc.encode(stim);
    for indUnit=1:NUM_UNITS
        %hax=subplot(ROW,COL,indUnit);
        hax = hList(indUnit);
        axes(hax);
        %scale=max(spikeCounts(indUnit,:))-min(spikeCounts(indUnit,:));
        scale = 1;
        hf=plot(stim,(spikeCounts(indUnit,:)-min(spikeCounts(indUnit,:)))/scale);
        hold on;
        set(hax,'xtick',[],'ytick',[]);
        set(hax,'xticklabel',[]);
        set(hax,'yticklabel',[]);
        set(hax, 'box', 'on');
        %set(hax,'XColor','none');
        %set(hax,'YColor','none');
        xlim([lb, ub]);
        
        if indUnit == 9
            xlabel('Orientation');
            ylabel('Response');
            xticks([lb, 270, ub]);
            xticklabels([lb, 270, ub]);
        end
    end
end


legend(leg);
%%






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
