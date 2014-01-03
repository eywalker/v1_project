function p=pRespAGivenS_BP(sigmaA,sigmaB,priorA,sigma,s)
    k1=1/2*log((sigma.^2+sigmaB.^2)./(sigma.^2+sigmaA.^2))+log(priorA./(1-priorA));
    k2=(sigmaB.^2-sigmaA.^2)./(2*(sigma.^2+sigmaA.^2)*(sigma.^2+sigmaB.^2));
    k=sqrt(k1./k2);
    if(~isreal(k))
        p=0;
        return;
    end
    p=(1/2)*(erf((s+k)/sigma/sqrt(2))-erf((s-k)/sigma/sqrt(2)));
end