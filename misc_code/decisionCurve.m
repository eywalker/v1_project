


sigmas = linspace(0,30,10);
sigmaA = 3;
sigmaB = 15;
priorA = 0.73;
lapseRate = 0.0;
s_hat = linspace(-20, 20,100);
l_color = lines(length(sigmas));
figure;
for i = 1:length(sigmas)
    sigma = sigmas(i);
    k1 = 1/2*log((sigma.^2 + sigmaB.^2)./(sigma.^2 + sigmaA.^2)) + log(priorA./(1-priorA));
    k2 = 1/2*(sigmaB.^2 - sigmaA.^2) ./ ((sigma.^2 + sigmaA.^2) .* (sigma.^2 + sigmaB.^2));
    k = sqrt(k1./k2);

    unreal_k = ~arrayfun(@isreal, k);
    k(unreal_k) = 0; % give 0 to pass by erf function
    LCA = ((1/2)*(erf((s_hat+k)./sigma./sqrt(2)) - erf((s_hat-k)./sigma./sqrt(2)))); % p(C='A'|s)
    LCA(unreal_k) = 0;
    pA = LCA * (1-lapseRate) + lapseRate * 0.5;
    hold off;
    plot(s_hat, pA, 'color', l_color(i,:));
    ylim([0, 1]);
    pause();
end