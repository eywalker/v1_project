function z = shiftFunction(x, y, shift, method, fillEdge)
%SHIFTFUNCTION Shift the function y=f(x) by shift so that z = f(x-shift)
%evaluated at x. y is expected to be a column vector or a matrix where each
%column represents different functions. 
    if nargin < 5
        fillEdge = false;
    end
    if nargin < 4 || isempty(method)
        method = 'pchip';
    end
    xmax = max(x);
    xmin = min(x);
    if size(y, 2)==1
        y = repmat(y, 1, length(shift));
    end
    z = y;
    for i=1:size(y,2)
        if fillEdge
            shifted_x = x + shift(i);
            z(:,i) = interp1(shifted_x, y(:,i), x, method, nan);
            z(x <= xmin + shift(i), i) = y(1, i);
            z(x >= xmax + shift(i), i) = y(end, i);
            assert(~any(isnan(z(:,i))), 'Extrapolation was not properly handled');
        else
            z(:,i) = interp1(x + shift(i), y(:,i), x, method, 0);
        end
    end
end 