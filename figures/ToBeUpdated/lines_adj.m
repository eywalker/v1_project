function cm = lines_adj(m, alpha, shift)
    if nargin < 2
        alpha = 0.9;
    end
    if nargin < 3
        shift = 0;
    end
    vals = 1:m;
    decay = alpha .^ floor((vals-1) / 7);
    shift = bsxfun(@times, shift(:), floor((vals-1) / 7));
    cm = bsxfun(@times, lines(m), decay');
    cm = bsxfun(@plus, cm, shift');
    cm(cm > 1) = 1;
    cm(cm < 0) = 0;
end