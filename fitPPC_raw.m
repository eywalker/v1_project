function [priorA,alpha,slip_rate]=fitPPC_raw(sigmaA,sigmaB,decode_ori,likelihood,class_response)
    cf=@(param) -logLPPC_raw(sigmaA,sigmaB,param(1),decode_ori,likelihood,param(2),param(3),class_response);
    x=fmincon(cf,[0.5,1,0.05],[],[],[],[],[0.000,0.0001,0.000],[1,1000,1]);
    priorA=x(1);
    alpha=x(2);
    slip_rate=x(3);
end