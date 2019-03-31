function z = shiftUntilTarget(x, y, shift, shiftCandidates, method, fillEdge)
%SHIFTFUNCTION Shift the function y=f(x) by shift so that z = f(x-shift)
%evaluated at x. y is expected to be a column vector or a matrix where each
%column represents different functions. 
    if nargin < 6
        fillEdge = false;
    end
    if nargin < 5 || isempty(method)
        method = 'pchip';
    end
    
    if nargin < 4 || isempty(shiftCandidates)
        shiftCandidates = linspace(-100, 100,  3000);
    end
    
    x = x(:);
    
    xs = bsxfun(@minus, x, shiftCandidates);
    originalPeaks = ClassifierModel.getPostMeanStd(x, y);
    
    xmax = max(x);
    xmin = min(x);
    if size(y, 2)==1
        y = repmat(y, 1, length(shift));
    end
    z = y;
    for i=1:size(y,2)
        shifted_ys = interp1(x, y(:,i)', xs, method, 0);
        originalPeak = originalPeaks(i);
        shiftedPeaks = ClassifierModel.getPostMeanStd(x, shifted_ys);
        
        [~, pos] = min(abs(shiftedPeaks - originalPeak - shift(i)));
        z(:, i) = shifted_ys(:, pos);
    end
end 