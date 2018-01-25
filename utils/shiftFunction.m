function z = shiftFunction(x, y, shift)
%SHIFTFUNCTION Shift the function y=f(x) by shift so that z = f(x-shift)
%evaluated at x. y is expected to be a column vector or a matrix where each
%column represents different functions. 
    z = y;
    for i=1:size(y,2)
        z(:,i) = interp1(x + shift(i), y(:,i), x, 'pchip', 0);
    end
end