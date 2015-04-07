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