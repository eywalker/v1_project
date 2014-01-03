
%% Specify session number


for sessionNum = 1:5%length(sessionData)
    fprintf('Working on session %d...\n',sessionNum);
   
    trialInfo=sessionData(sessionNum).trial_info;  
    
    sessionData(sessionNum).cvResults = analyzeSession(trialInfo);
    fprintf('Completed %d!\n', sessionNum);
    
end

% %%
% testStat=[]
% for indSession = 1:length(sessionData)
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indConrast = 1:length(cvContrast)
%         cvData = cvContrast(indContrast).data;
%         testLL = []
%         for indCV = 1:length(cvData)
%             testLL = [testLL vertcat(cvData(indCV).models.testLL)]
%         end
%         testStat = [testStat mean(testLL,2)]
%     end
% end
% 
% 
% %%
% figure;
% nbStats = zeros(10, 2);
% bplStats = zeros(10, 2);
% flStats = zeros(10, 2);
% colorMap = lines;
% for ind = 1:10
%     cvData = sessionData(ind).cvResults.data;
%     nbTest = [cvData.nbTestLL]
%     nbStats(ind, :) = [mean(nbTest), std(nbTest)/sqrt(10)];
%     bplTest = [cvData.bplTestLL];
%     bplStats(ind, :) = [mean(bplTest), std(bplTest)/sqrt(10)];
%     flTest = [cvData.flTestLL];
%     flStats(ind, :) = [mean(flTest), std(flTest)/sqrt(10)];
%     plot([1,2,3], [mean(nbTest), mean(bplTest), mean(flTest)], 'Color', colorMap(ind,:));
%     hold on;
% end
% set(gca,'xtick',[1,2,3]);
% set(gca,'xticklabel',{'Peak-only', 'Peak+Width', 'Full-likelihood'});
% ylabel('Average log-likelihood');
% %%
% figure;
% plot(1:13, exp(nbStats(:,1)-nbStats(:,1)), 1:13, exp(bplStats(:,1)-nbStats(:,1)), 1:13, exp(flStats(:, 1)-nbStats(:,1)));
% %%
% cvData = sessionData(1).cvResults.data;
% nbTrain = [cvData.nbTrainLL]
% nbTest = [cvData.nbTestLL]
% bplTrain = [cvData.bplTrainLL];
% bplTest = [cvData.bplTestLL];
% flTrain = [cvData.flTrainLL];
% flTest = [cvData.flTestLL];
% figure;
% 
% plot(1:N, nbTrain,'--', 1:N, bplTrain, '--', 1:N, flTrain, '--');
% hold on;
% plot(1:N, nbTest, 1:N, bplTest, 1:N, flTest);
% 
% %%
% logL_vals = [];
% model_group = {};
% session_group = [];
% 
% for indSession = 1:10
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indCont = 1:length(cvContrast)
%         cvData = cvContrast(indCont).data;
%         for indRun = 1:length(cvData)
%             data = cvData(indRun);
%             vals = [data.nbTestLL data.bplTestLL, data.flTestLL];
%             vals = vals - mean(vals);
%             logL_vals = cat(2, logL_vals, vals);
%             model_group = cat(2,model_group, {'nb','bpl', 'fl'});
%             session_group = cat(2,session_group, indSession * ones(size(vals)));
%         end
%         
%     end
% end
% 
% p = anovan(logL_vals, {model_group, session_group});
% nbInd = strcmp(model_group, 'nb');
% nbVals = logL_vals(nbInd);
% bplInd = strcmp(model_group, 'bpl');
% bplVals = logL_vals(bplInd);
% 
% [h, p] = ttest2(nbVals, bplVals)
% 
% %%
% logL_vals = [];
% model_group = {};
% session_group = [];
% 
% for indSession = 1:17
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indCont = 1:length(cvContrast)
%         cvData = cvContrast(indCont).data;
%         for indRun = 1:length(cvData)
%             data = cvData(indRun);
%             vals = [data.nbTestLL data.bplTestLL];% data.flTestLL];
%             logL_vals = cat(2, logL_vals, vals);
%             model_group = cat(2,model_group, {'nb','bpl'});% 'fl'});
%             session_group = cat(2,session_group, indSession * ones(size(vals)));
%         end
%         
%     end
% end
% 
% p = anovan(logL_vals, {model_group, session_group});
% %%
% nbInd = strcmp(model_group, 'nb');
% nbVals = logL_vals(nbInd);
% bplInd = strcmp(model_group, 'bpl');
% bplVals = logL_vals(bplInd);
% 
% [h, p] = ttest2(nbVals, bplVals)
% 
% 
% 
% 
% %% paired t-test based approach
% nbVals = [];
% bplVals = [];
% flVals = [];
% sessionInd = [];
% nSession = 20;
% for indSession = 1:20
%     cvContrast = sessionData(indSession).cvResults.cvContrast;
%     for indCont = 1:length(cvContrast)
%         cvData = cvContrast(indCont).data;
%         nbVals = cat(2, nbVals, mean([cvData.nbTestLL]));
%         bplVals =cat(2, bplVals, mean([cvData.bplTestLL]));
%         flVals =cat(2,flVals, mean([cvData.flTestLL]));
%         sessionInd = cat(2, sessionInd, indSession);
%     end
% end
% allData = [nbVals; bplVals; flVals];
% allData = bsxfun(@minus, allData, mean(allData,1));
% shortData = [];
% for ind =1:nSession
%     pos = sessionInd == ind;
%     shortData=cat(2,shortData,mean(allData(:,pos),2))
% end
% 
% 
% figure;
% hold on;
% plot(sessionInd, allData(1,:),'ro');
% plot(sessionInd, allData(2,:),'go');
% plot(sessionInd, allData(3,:),'bo');
% hold on;
% plot(1:nSession, shortData(1,:),'r');
% plot(1:nSession, shortData(2,:),'g');
% plot(1:nSession, shortData(3,:),'b');
% 
% legend({'Gaussian-peak', 'Gaussian-peak-and-width', 'Full-likelihood'});
% 
% [h, p] = ttest(nbVals, bplVals)
% fprintf('nb vs bpl %f', p)
% 
% [h, p] = ttest(nbVals, flVals)
% fprintf('nb vs fl %f', p)
% 
% labels = [repmat({'nb'}, size(nbVals)), repmat({'fl'}, size(flVals))];
% [h, p] = anovan([nbVals, bplVals], {[sessionInd, sessionInd], labels})