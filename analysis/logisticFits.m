dataSet;
width = 3;

orid = round(dataSet.orientation / width) * width;
[orid_keys, ~, labels] = unique(orid);
counts = dataSet.counts;
w = zeros(96, length(orid_keys) - 1);

for i = 1:length(orid_keys) - 1
    if sum(labels==i)==1 && sum(labels==i+1)==1
        w(:,i) = counts(:,labels==i+1) - counts(:, labels==i);
        continue;
    end
    pos = labels == i | labels == i + 1;
    r  = counts(:, pos);
    lbl = labels(pos) == (i+1);
    w(:, i) = glmfit(r', lbl, 'binomial', 'link', 'logit', 'constant', 'off');
end

h=cumsum(w, 2);
%%

figure;
decodeOri = linspace(220, 320, 100);
oric = (orid_keys(2:end) + orid_keys(1:end-1))/2;
y = interp1(oric, h(19, :), decodeOri, 'pchip');
plot(oric, h(19, :), 'r--');
hold on;
plot(decodeOri, y);
xlim([220, 320]);

%%
counts = dataSet.counts;
ori = dataSet.orientation;
n_prc = 10;
edges = prctile(dataSet.orientation, linspace(0,100, n_prc));
n_labels = length(edges) - 1;
labels = sum(bsxfun(@le, edges(1:end-1), ori(:)), 2);
binc = 0.5 * (edges(1:end-1) + edges(2:end));

w = zeros(96, n_labels - 1);
wo = w;
for i = 1:n_labels - 1
    pos = labels == i | labels == i + 1;
    r  = counts(:, pos);
    lbl = labels(pos) == (i+1);
    v = glmfit(r', lbl, 'binomial', 'link', 'logit', 'constant', 'off');
    wo(:, i) = v;
    w(:, i) = v / (binc(i+1) - binc(i));
end

bincc = 0.5 * (binc(1:end-1) + binc(2:end));

x = linspace(250, 290, 200);
deltaS = x(2) - x(1);

dh = interp1(bincc, w', x, 'linear', 0);
h = cumsum(dh, 1) * deltaS;
%%
idx= 53;

figure;
subplot(4,1,1);
hold on;
plot(binc, zeros(size(binc)), 'kx');
plot(edges, zeros(size(edges)), 'rx');
plot(bincc, wo(idx,:), 'o')
subplot(4,1,2);
plot(bincc, w(idx,:), 'o')
subplot(4,1,3);
plot(x, dh(:, idx));
subplot(4,1,4);
plot(x, h(:, idx));






