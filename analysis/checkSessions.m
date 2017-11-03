% Inspect the spike counts within a session to spot bad trials
spikes = fetch(class_discrimination.SpikeCountTrials, 'counts');
all_counts = [spikes.counts];
bad = any(all_counts > 60);
bad_session = unique([spikes.session_start_time]);


%%
for i=1:length(bad_session)

    sess = bad_session(i);

    trials = class_discrimination.SpikeCountTrials & sprintf('session_start_time = %d', sess);
    data = fetch(trials, 'counts');
    
    % across units correction
    zval = 4;
    counts = [data.counts];
    totalCounts = sum(counts, 1);
    lowq = prctile(totalCounts, 25);
    med = prctile(totalCounts, 50);
    highq = prctile(totalCounts, 75);
    sigma = (highq - lowq) / 1.35;
    lowThr = med -  zval * sigma;
    highThr = med + zval * sigma;
    
    

    goodTrials = totalCounts > lowThr & totalCounts < highThr;

    % per unit correction
    lowv = prctile(counts, 25, 2);
    medv = prctile(counts, 50, 2);
    highv = prctile(counts, 75, 2);
    delta = (highv - lowv) / 50;
    factor = 1.5;
    fraction = 0.5;
    hight = medv + factor * 50 * delta;
    lowt = medv - factor * 50 * delta;
    good = bsxfun(@ge, counts, lowt) & bsxfun(@le, counts, hight);
    goodUnitTrials = sum(good, 1) > fraction * size(good, 1);
    

    n = size(counts, 1);
    mu = zeros(n, 1);
    sigma = ones(n, 1);
    for row=1:size(counts, 1)
        cs = counts(row, good(row, :));
        mu(row) = mean(cs);
        sigma(row) = std(cs);
    end
    
    adjCounts = counts ./ mu;
    adjCounts(:, ~goodTrials) = 0;
    
    N = 6;
    subplot(N, 1, 1);
    imagesc(counts ./ max(counts, [], 2));
    title(sprintf('Session %d Subject id=%d', i, data(1).subject_id));
    

    subplot(N, 1, 2);
    imagesc(adjCounts);

%     subplot(4, 1, 3);
%     x=linspace(0, 100, 100);
%     plot(x, prctile(correctedCounts, x, 2)');
    subplot(N, 1, 3);
    imagesc(good);
    title(sprintf('%d out of %d trials removed', sum(~goodTrials | ~goodUnitTrials), length(goodTrials)));


    subplot(N, 1, 4);
    imagesc(goodTrials);
    title(sprintf('%d out of %d trials removed', sum(~goodTrials), length(goodTrials)));

   
    subplot(N, 1, 5);
    imagesc(goodUnitTrials);
    title(sprintf('%d out of %d trials removed', sum(~goodUnitTrials), length(goodTrials)));
    
    subplot(N, 1, 6);
    hist(totalCounts, 50);

    pause();
end

%%

lowv = prctile(counts, 2.5, 2);
highv = prctile(counts, 97.5, 2);
good = bsxfun(@ge, counts, lowv) & bsxfun(@le, counts, highv);

n = size(counts, 1);
mu = zeros(n, 1);
sigma = ones(n, 1);
for row=1:size(counts, 1)
    cs = counts(row, good(row, :));
    mu(row) = mean(cs);
    sigma(row) = std(cs);
end
   
threshold = mu +  6 * sigma;

figure;
subplot(3, 1, 1);
imagesc(bsxfun(@rdivide, counts, mu));
colorbar();
title(['Session ', num2str(i), ' out of ', num2str(length(bad_session))]);
subplot(3, 1, 2);
imagesc(bsxfun(@gt, counts, threshold));
title(sprintf('Subject id=%d', data(1).subject_id));

subplot(3, 1, 3);

imagesc(counts == 0);
title(sprintf('Subject id=%d', data(1).subject_id));

i  = i + 1;

