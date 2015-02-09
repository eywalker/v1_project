s = linspace(-30,30, 10000);
sigma = 9;%linspace(0,10,100);
sigmaA = 3;
sigmaB = 15;
priorA = 0.4;

k1 = 1/2 * log((sigmaB.^2 + sigma.^2)./(sigmaA.^2 + sigma.^2)) + log(priorA ./ (1-priorA));
k2 = (sigmaB.^2 - sigmaA.^2) ./ (2 * (sigmaA.^2 + sigma.^2) .* (sigmaB.^2 + sigma.^2));

k = sqrt(k1./k2);

%figure;plot(sigma, k);
%hold on;
%plot(sigma, sigma, 'g--');
%%
pA = (1/2)*(erf((s+k)/sigma./sqrt(2))-erf((s-k)./sigma./sqrt(2)));
%figure;
hold on;
plot(s, pA);