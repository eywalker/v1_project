function  logL=logLModelBP(sigmaA,sigmaB,priorA,sigma,s,class_response)
    k1=1/2*log((sigma.^2+sigmaB.^2)./(sigma.^2+sigmaA.^2))+log(priorA./(1-priorA));
    k2=(sigmaB.^2-sigmaA.^2)./(2*(sigma.^2+sigmaA.^2)*(sigma.^2+sigmaB.^2));
    k=sqrt(k1./k2);
    if(~isreal(k))
        logL=-Inf;
        return
    end
    pCA=@(s)((1/2)*(erf((s+k)/sigma/sqrt(2))-erf((s-k)/sigma/sqrt(2)))); % p(C='A' | s);
    respA=strcmp(class_response,'A'); %trials for which subject responded 'A'
    respB=~respA; %trials for which subject responded 'B'
    logLA=0;
    logLB=0;
    if(any(respA))
        logLA=sum(log(pCA(s(respA))+0.0000001));
    end
    if(any(respB))
        logLB=sum(log(1-pCA(s(respB)+0.0000001)));
    end
    logL=(logLA+logLB)./length(class_response);
    
end