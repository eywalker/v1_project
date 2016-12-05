function [med,sigma]=getMedStd(s, L)
%% Return median and std of the likelihood function
    s = s(:);
    s_mu=sum(bsxfun(@times,L,s))./sum(L);
    sigma=sqrt(sum(bsxfun(@times,L,s.^2))./sum(L)-s_mu.^2);
    [~, pos] = max(diff(cumsum(L) ./ sum(L) > 0.5));
    pos = pos + 1;
    med = s(pos);
end