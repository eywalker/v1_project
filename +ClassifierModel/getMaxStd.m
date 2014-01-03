function [s_max,sigma]=getMaxStd(s, L)
    s = s(:);
    [~,s_idx]=max(L);
    s_max=s(s_idx);
    s_mu=sum(bsxfun(@times,L,s))./sum(L);
    sigma=sqrt(sum(bsxfun(@times,L,s.^2))./sum(L)-s_mu.^2);
end