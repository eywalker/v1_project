all_peaks = [];
all_widths = [];
all_ori = [];
all_contrast = [];
keys = fetch(cd_plset.ContrastSessionPLSet);
for i=1:length(keys)
    key = keys(i);
    plset = fetchPLSet(cd_plset.ContrastSessionPLSet & key);
    all_peaks = [all_peaks, plset.likelihood_peak];
    all_widths = [all_widths, plset.likelihood_width];
    all_ori = [all_ori, plset.orientation];
    all_contrast = [all_contrast, plset.contrast];
    
end

%%
figure;
for i = 1:197
    clf;
plset = fetchPLSet(cd_plset.ContrastSessionPLSet & keys(i));

subplot(2,1,1);
plot(plset.orientation, plset.likelihood_peak,'ro');
hold on;
plot(x, x, 'k--');
title(sprintf('Contrast = %.4f', plset.contrast(1)));

subplot(2,1,2);
plot(plset.orientation, plset.likelihood_width, 'bx');
pause();
end