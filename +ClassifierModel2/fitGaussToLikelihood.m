function [mu,sigma,fitL]=fitGaussToLikelihood(s, L)
    s = s(:);
    fitL=zeros(size(L));
    [mu_init,sigma_init]=getStat(s, L);
    mu=zeros(size(L,2),1);
    sigma=zeros(size(L,2),1);
    options=optimset('Display','off','Algorithm','active-set','MaxFunEvals',1000);
    for indTrial=1:size(L,2)
        target=L(:,indTrial);
        x0=[mu_init(indTrial),sigma_init(indTrial)];
        x=fmincon(@costFun,x0,[],[],[],[],[-inf,0.00001],[Inf,Inf],[],options);
        mu(indTrial)=x(1);
        sigma(indTrial)=x(2);
        gauss=normpdf(s,x(1),x(2));
        fitL(:,indTrial)=gauss./sum(gauss);
    end
    function reg=costFun(param)
        gauss=normpdf(s,param(1),param(2));
        if(sum(gauss)==0)
            reg=Inf;
        else
            gauss=gauss./sum(gauss);
            reg=sum((target-gauss).^2);
        end
    end
end

function [s_mu,sigma,s_max]=getStat(s, L)
    s_mu=sum(bsxfun(@times,L,s))./sum(L);
    sigma=sqrt(sum(bsxfun(@times,L,s.^2))./sum(L)-s_mu.^2);
    [~,s_idx]=max(L);
    s_max=s(s_idx);
end