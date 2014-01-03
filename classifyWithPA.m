function classResp=classifyWithPA(s,fPAS,n)
    if (nargin<3)
        n=1;
    end
    
    classResp={};
    for k=1:n
        for i=1:length(s)
            if(rand<fPAS(s(i)))
                classResp=[classResp 'A'];
            else
                classResp=[classResp 'B'];
            end
        end
    end
end