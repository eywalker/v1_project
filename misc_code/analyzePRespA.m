% Generates the plot for posterior over class (i.e. P(responding A) )given 
% an observed noisy stimulus and contrast.

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
v=-5:0.5:2;
v = [v, 0, 0.75, 1.25];
hold on;
imagesc(logLRatio);
hold on;
[C, h]=contour(sv, sigmav, logLRatio, v, 'k');
clabel(C, h);

figure;
v = [0];
[C, h]=contour3(sv, sigmav, logLRatio, v, 'k');
clabel(C, h);

hold on;
surf(sv, sigmav, logLRatio);
shading flat;