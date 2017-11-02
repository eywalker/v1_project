key = acq.Stimulation('exp_type like "ClassDisc%"') & acq.Sessions('session_datetime like "2009-12-01%"') & acq.Subjects('subject_name = "Woody"'); % woody ventral array data
trials = fetch((class_discrimination.ClassDiscriminationTrial * ephys.SpikesAlignedSet) & key);
t0 = 0;
t1 = 500;
spikes = zeros(length(trials), 96);
for i = 1:length(trials)
    t = trials(i);
    data = fetch(class_discrimination.ClassDiscriminationTrial * ephys.SpikesAlignedTrial & t, '*');
    fprintf(sprintf('Processing trial %d...\n', i));
    x = arrayfun(@(x) sum(x.spikes_aligned > t0 & x.spikes_aligned < t1), data);
    spikes(i, :) = x;
end