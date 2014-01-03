ephys_keys = fetch(acq.Ephys & acq.Sessions('session_datetime > "2013"'))


%%
for key = 1:100
fprintf('Working on %d...',key)
    ephys = acq.Ephys(ephys_keys(key));
cond = sprintf('ABS(timestamper_time - %ld) < 5000', fetch1(ephys, 'ephys_start_time'));
rel = acq.SessionTimestamps(cond) & acq.TimestampSources('source = "Ephys"') & (acq.Sessions * ephys);

[count, timestamperTime, sessionStartTime] = fetchn(rel, 'count', 'timestamper_time', 'session_start_time');
            
% Rescale to times
counterRate = 10e6 / 1000; % pulses / ms (should be stored somewhere)
counterPeriod = 2^32 / counterRate; % period of time it takes to count one cycle

countTime = count / counterRate; 
approximateSessionTime = timestamperTime - sessionStartTime; % approximately how long it has passed since session began

% Compute expected counter value based on CPU time
approximateSessionPeriods = floor(approximateSessionTime / counterPeriod); % approximately how many cycles it has gone through
approximateResidualPeriod = mod(approximateSessionTime, counterPeriod); %
 % Correct edge cases where number of periods is off by one
idx = find((approximateResidualPeriod - countTime) > counterPeriod / 2);
approximateSessionPeriods(idx) = approximateSessionPeriods(idx) + 1;

accurateTime = countTime + approximateSessionPeriods * counterPeriod;
if abs(accurateTime - approximateSessionTime) > counterPeriod / 2
    assert(false)
end
    
fprintf('Completed %d fine\n',key)
end