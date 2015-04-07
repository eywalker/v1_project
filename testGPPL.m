close all;
N = 17;
mu = linspace(220,320,N);
G = 50
%mu = randn(1, N) * 50 + 270;
sigma = 10;
s_train = rand(1000, 1) * (320-220) + 220;
s_train = randn(10000, 1)*5 + 270;
delta = bsxfun(@minus, s_train(:), mu);
f = bsxfun(@times, G, normpdf(delta, 0, sigma));

subplot(5,1,1);
plot(s_train, f, 'o');
r = poissrnd(f);
r=bsxfun(@minus, r, mean(r));

s_decode = linspace(240, 300, 1000);
K = covk(5, 20, s_train, s_decode);
Kn = covk(1, 20, s_train, s_decode);
subplot(5,1,2);
ps = normpdf(s_decode, 270, 5);
plot(s_decode, ps);
subplot(5,1,3);
plot(s_decode, sum(Kn, 2));
h = K * r;
hn = bsxfun(@rdivide, h, ps(:));
subplot(5,1,4);
plot(s_decode, h);
subplot(5,1,5);
plot(s_decode, hn);


%% test it
s_test = randn(100, 1)*10 + 270;
delta_test = bsxfun(@minus, s_test(:), mu);
r_test = normpdf(delta_test, 0, sigma);
%r_test = bsxfun(@minus, r_test, mean(r));

v = hn * r_test';
vn = bsxfun(@minus, v, max(v));
figure;
plot(s_decode, vn);

[~, pos] = max(vn);
s_hat = s_decode(pos);
figure;
plot(s_test, s_hat, 'ro');
hold on;
plot(s_decode, s_decode, 'k--');