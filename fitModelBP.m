function [priorA sigma]=fitModelBP(sigmaA,sigmaB,s,response)
    
    cf=@(param) -logLModelBP(sigmaA,sigmaB,param(1),param(2),s,response);
    x=fmincon(cf,[0.5,1],[],[],[],[],[0.000,0.000],[1,Inf]);
    priorA=x(1);
    sigma=x(2);
end