function logL=logLPPC_NB(sigmaA,sigmaB,priorA,decode_ori,likelihood,slip_rate,class_response)
    [~,s_idx]=max(likelihood);
    s_hat=decode_ori(s_idx)';
    k1=1/2*log(sigmaB.^2./sigmaA.^2)+log(priorA./(1-priorA));
    k2=(sigmaB.^2-sigmaA.^2)./2./sigmaA.^2./sigmaB.^2;
    k=sqrt(k1./k2);
    expRespA=(abs(s_hat)<k); %trials where you would expect response 'A'
    respA=strcmp(class_response,'A'); %trials for which subject responded 'A'
    respB=~respA; %trials for which subject responded 'B'
    correctPrediction=(respA & expRespA) | ~(respA | expRespA); %trials where subject responded as expected
    pResp=correctPrediction .* (1-slip_rate) + slip_rate * priorA * respA + slip_rate * (1-priorA) * respB;
    logL=sum(log(pResp));
    logL=logL/length(class_response);
end