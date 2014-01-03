function [priorA slip_rate]=fitPPC_BP(sigmaA,sigmaB,decode_ori,likelihood,gaussianFitParams,class_response)
    cf=@(param) -logLPPC_BP(sigmaA,sigmaB,param(1),decode_ori,likelihood,gaussianFitParams,param(2),class_response)
    x=fmincon(cf,[0.5,0.05],[],[],[],[],[0.000,0.000],[1,1]);
    priorA=x(1);
    slip_rate=x(2);
end