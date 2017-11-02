
%% Specify session number

sessionData(length(sessionData)).cvResults = [];

parfor sessionNum = 1:length(sessionData)
    fprintf('Working on session %d...\n',sessionNum);
   
    trialInfo=sessionData(sessionNum).trial_info;  
    
    sessionData(sessionNum).cvResults = analyzeSession(trialInfo);
    fprintf('Completed %d!\n', sessionNum);
    
end

