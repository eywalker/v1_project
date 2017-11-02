function K = covk(sigma, lambda, x_in, x_out)
    % Implements standard squared-exponential covariance kernel for use in
    % Gaussian process
    % if x_out is omitted, then computes covariance kernel for x_in by x_in
    if nargin < 4
        x_out = x_in;
    end
    x_in = x_in(:)';
    x_out = x_out(:);
    K = sigma.^2 * exp(-(bsxfun(@minus, x_out, x_in) / lambda).^2 / 2);
end