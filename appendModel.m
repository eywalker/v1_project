%% Change this part!
model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC(3, 15, 270, 'NewModel!');

%%
for indSession = 1:20
    cvResults = sessionData(indSession).cvResults;
    decodeOri = cvResults.decodeOri;
    N = cvResults.N;
    cvContrast = cvResults.cvContrast;
    for indContrast = 1:length(cvContrast)
        contInfo = cvContrast(indContrast);
        contrast = contInfo.contrast;
        data = contInfo.data; % cross validation structure
        for indCV = 1:length(data)
            cvRun = data(indCV);
            trainSet = cvRun.trainSet
            testSet = cvRun.testSet
            modelStruct = cvRun.models;
            nModels = length(modelStruct);
            
            % check if the model already exists
            modelNames = {modelStruct.modelName};
            if any(strcmp(modelName, model.modelName))
                pos = find(strcmp(modelName, model.modelName)); %if there, plan to over-write it
            else
                pos = nModels+1; %if not, then add it to the end of the model list
            end
            
            
            
            %% Change this part
            %train model and add result to the structure
            
            %test model and add result to the structure
            
            
            % update structure
            cvRun.models = modelStruct;
            data(indCV) = cvRun;
        end
        contInfo.data = data;
        cvContrast(indContrast) = contInfo;
    end
    cvResults.cvContrast = cvContrast;
    sessionData(indSession).cvResults = cvResults;
end