function logL=logLPPC_raw(sigmaA,sigmaB,priorA,decode_ori,likelihood,alpha,slip_rate,class_response)
    psA=normpdf(decode_ori,0,sigmaA);
    psB=normpdf(decode_ori,0,sigmaB);
    prA=likelihood'*psA;
    prB=likelihood'*psB;
    logPostRatio=log(prA)-log(prB)+log(priorA./(1-priorA));
    logDecRatio=alpha.*logPostRatio;
    pB=1./(1+exp(logDecRatio));
    pA=1-pB;
    respA=strcmp(class_response,'A'); %trials for which subject responded 'A'
    respB=~respA; %trials for which subject responded 'B'
    logL=sum(log(pA(respA)*(1-slip_rate)+slip_rate*priorA))+sum(log(pB(respB)*(1-slip_rate)+slip_rate*(1-priorA)));
    logL=logL/length(class_response);
end