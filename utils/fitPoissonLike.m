function [ orid_keys, h ] = fitPoissonLike(binWidth, dataSet)
%FITPOISSONLIKE Fits Poisson-like distribution kernel via pairwise logistic
% methods
%
%   Given dataSet structure with orientation and counts fields, fit
%   Poisson-like distribution kernel h(s) by performing pairwise logistic
%   regression on counts of binned orientation.

pos = dataSet.orientation >= 250 & dataSet.orientation <= 290;

ori = dataSet.orientation(pos);
counts = dataSet.counts(:, pos);

orid = round(ori / binWidth) * binWidth;
[orid_keys, ~, labels] = unique(orid);
N = size(counts, 1);
w = zeros(N, length(orid_keys) - 1);

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

h = [zeros(size(w,1),1), cumsum(w, 2)];
end

