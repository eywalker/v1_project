function [priorA slip_rate]=fitPPC_NB(sigmaA,sigmaB,decode_ori,likelihood,class_response)
    cf=@(param) -logLPPC_NB(sigmaA,sigmaB,param(1),decode_ori,likelihood,param(2),class_response);
    x=fmincon(cf,[0.5,0.05],[],[],[],[],[0.000,0.000],[1,1]);
    priorA=x(1);
    slip_rate=x(2);
end