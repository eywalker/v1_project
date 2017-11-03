mus = -50:10:50;
sigma = 10;
g = 1000;

s = -5;

f = g * normpdf(s - mus, 0 , sigma);
r = poissrnd(f);

%figure;
subplot(2,1,1);
stem(mus, r);
xlim([-50,50]);
ylim([0, 20]);

sp = linspace(-60,60, 1000);
logf=-(bsxfun(@minus, sp', mus)).^2./2./sigma.^2;
logL = logf * r';
likelihood = exp(logL - max(logL));

subplot(2,1,2);
plot(sp, likelihood);
xlim([-50,50]);