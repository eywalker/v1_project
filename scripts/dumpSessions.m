sessions = fetch(class_discrimination.ClassDiscriminationExperiment & class_discrimination.ClassDiscriminationTrial & 'subject_id = 3');

for n=1:length(sessions)
    fprintf('Working on session %d out of %d...\n', n, length(sessions));
    datetime = fetch1(acq.Sessions & sessions(n), 'session_datetime');
    datagram = packData(fetch((class_discrimination.ClassDiscriminationTrial) & sessions(n), '*'));
    datagram.datetime = datetime;
    data(n) = datagram;
end
