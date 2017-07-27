spikes = fetch(class_discrimination.SpikeCountTrials, 'counts');
all_counts = [spikes.counts];
bad = any(all_counts > 200);
bad_session = unique([spikes.session_start_time]);
%%
i = 1;

%%
sess = bad_session(i);

trials = class_discrimination.SpikeCountTrials & sprintf('session_start_time = %d', sess);
data = fetch(trials, 'counts');

counts = [data.counts];

flat_counts = counts(:);
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
   
threshold = mu + 8 * sigma;


subplot(3, 1, 1);
imagesc(counts);
colorbar();
title(['Session ', num2str(i), ' out of ', num2str(length(bad_session))]);
subplot(3, 1, 2);
imagesc(bsxfun(@gt, counts, threshold));
title(sprintf('Subject id=%d', data(1).subject_id));

subplot(3, 1, 3);
imagesc(counts == 0);
title(sprintf('Subject id=%d', data(1).subject_id));

i  = i + 1;

