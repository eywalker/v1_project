% Create plots simulating decoding the stimulus from the activitiy 
% population of Gaussian tuning curves responding to a single stimulus. 
% Shows different results under two gain values on the resopnse
% (e.g. contrast effect).

s = 20; % stimulus value
N = 25; % population size
sigma = 50; % std of Gaussian tuning curve
gains = [1000, 300];

t_c = linspace(-90,90,N);

figure;
rng(560);
for idxGain = 1:length(gains)
    gain = gains(idxGain);
    r_m = gain * normpdf(s-t_c,0, sigma);
    r=poissrnd(r_m);
    
    %plot(t_c, r_m, 'o');
    %hold on;
    subplot(2,2,2*(idxGain-1)+1);
    plot(t_c, r, 'ro','MarkerSize', 8);
    set(gca, 'xtick',-80:20:80);
    xlim([-90,90]);
    ylim([0,15]);
    xlabel('Preferred Orientation');
    ylabel('Spike Count');

    decode_ori = linspace(-180,180, 500);

    r_exp=gain * normpdf(bsxfun(@minus, decode_ori',t_c), 0, sigma);
    logL=sum(log(poisspdf(repmat(r, [length(decode_ori),1]), r_exp)),2);
    L=exp(logL);
    L = L / sum(L);
    
    subplot(2,2,2*(idxGain-1)+2);
    [v,pos]=max(L);
    v = sum(L);
    L = L / v;
    plot(decode_ori,L);
    
    ml=decode_ori(pos);
    y = linspace(0, 1, 100);
    h = 0.5 * ones(size(decode_ori));
    hold on;
    plot(ml*ones(size(y)), y,'--');
    plot(decode_ori, h, 'm--');
    set(gca, 'xtick',-80:20:80);
    xlim([-90,90]);
    ylim([0,0.07]);
    xlabel('Preferred Orientation');
    ylabel('Likelihood');
    set(gca, 'ytick', []);
end