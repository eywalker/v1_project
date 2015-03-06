
s = linspace(245, 295,100);
sigma = linspace(0, 8, 20);
[sv, sigmav] = meshgrid(s, sigma);
sigmaA = 3;
sigmaB = 15;
stimCenter = 270;
logPrA = -1/2 * log(2*pi) - 1 / 2 * log(sigmav.^2 + sigmaA^2) - (sv-stimCenter).^2 ./ 2 ./ (sigmav.^2 + sigmaA^2);
logPrB = -1/2 * log(2*pi) - 1 / 2 * log(sigmav.^2 + sigmaB^2) - (sv-stimCenter).^2 ./ 2 ./ (sigmav.^2 + sigmaB^2);
logLRatio = logPrA - logPrB;

figure;
v=-30:0.5:2;
v = [v, 0.75, 1.25];
[C, h]=contour(sv, sigmav, logLRatio, v);
clabel(C, h);
hold on;
imagesc(logLRatio);