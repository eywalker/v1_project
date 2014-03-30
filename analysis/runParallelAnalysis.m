
%% Specify session number


for sessionNum = 1%length(sessionData)
    fprintf('Working on session %d...\n',sessionNum);
   
    trialInfo=sessionData(sessionNum).trial_info;  
    
    sessionData(sessionNum).cvResults = analyzeSession(trialInfo);
    fprintf('Completed %d!\n', sessionNum);
    
end

%%
for sessionNum = 11:20%length(sessionData)
    fprintf('Working on session %d...\n',sessionNum);
   
    trialInfo=sessionData(sessionNum).trial_info;  
    sessionData(sessionNum).simpleFitResults = analyzeSessionNoCV(trialInfo);
    fprintf('Completed %d!\n', sessionNum);
end

%%
result =[]
for idx=1:20
    result = [result sessionData(idx).simpleFitResults.cvContrast];
end

%%
fits = [];
contrasts=[result.contrast];
for idxResult = 1:length(result)
    models = result(idxResult).modelFits;
    fits = [fits; [models.trainLL]];
end