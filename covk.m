function K = covk(sigma, lambda, x_in, x_out)
    if nargin < 4
        x_out = x_in;
    end
    x_in = x_in(:)';
    x_out = x_out(:);
    K = sigma.^2 * exp(-(bsxfun(@minus, x_out, x_in) / lambda).^2 / 2);
end