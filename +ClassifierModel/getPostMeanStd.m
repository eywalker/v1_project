function [s_mu,sigma]=getPostMeanStd(s, L, prior)
    
    s = s(:);
    if nargin < 3
        prior = exp(-(s - 270).^2 / 2 / 3^2) / sqrt(2 * pi * 3^2) + exp(-(s - 270).^2 / 2 / 15^2) / sqrt(2 * pi * 15^2);
    end
    
    % give likelihood combined with prior 
    L = bsxfun(@times, L, prior);
    
    s_mu=sum(bsxfun(@times,L,s))./sum(L);
    sigma=sqrt(sum(bsxfun(@times,L,s.^2))./sum(L)-s_mu.^2);
end