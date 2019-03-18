function [s_mu,sigma]=getPosteriorPeak(s, L)
    s = s(:);
    
    
    s_mu=sum(bsxfun(@times,L,s))./sum(L);
    sigma=sqrt(sum(bsxfun(@times,L,s.^2))./sum(L)-s_mu.^2);
end