for x=1:length(sessionData)
session=sessionData(x);
trialInfo=session.trial_info;
counts=[session.trial_info.counts];
h=figure;
set(h,'name',session.date);
N=length(session.trial_info);
edges=linspace(1,N,30);
for ind=1:96
    if (ind<9)
        pos=ind+1;
    elseif (ind<89)
        pos=ind+2;
    else
        pos=ind+3;
    end
    data=counts(ind,:);
    [mu,sigma,~,binc]=binnedStats(1:N,data,edges);
    subplot(10,10,pos);
    plot(binc,mu);
    mu=mean(data);
    sigma=std(data);
    xlim([0,N]);
    ylim([mu-2*sigma, mu+2*sigma]);
    %pause;
end
end