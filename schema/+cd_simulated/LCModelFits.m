%{
# results on testset
-> cd_simulated.TrainedLC
-----
lc_test_mu_logl  : float  # mean loglikelihood
lc_test_logl     : longblob # logl values for all trials
lc_testset_size  : int    # size of the testset
model_choice                : longblob                      # binary readout of a trial from the model
model_correct               : longblob                      # indicates whether model choice was correct
subj_choice                 : longblob                      # subject choice
prop_correct                : float                         # proportion of correct trials
orientation                 : longblob                      # orientation
%}

classdef LCModelFits < dj.Computed
    methods        
        function [dataSet, decoder] = getTrainSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getDataSet(cd_simulated.TrainedLC & key);
        end
        
        function [dataSet, decoder] = getTestSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getDataSet(cd_dlset.DLSet & key);
            simDataSet = getSimulatedDataSet(cd_simulated.TrainedLC, key);
            
            % transfer over simulated responses
            dataSet.selected_class = simDataSet.selected_class;
            dataSet.correct_response = simDataSet.correct_response;
            dataSet.selected_direction = simDataSet.selected_direction;
            
            test_indices = fetch1(cd_dlset.CVSetMember & key, 'test_indices');
            dataSet = selectData(dataSet, test_indices, {'decoder', 'goodUnits', 'decodeOri', 'key'});
        end
        
        function [trainset, testset, decoder, model]=getAll(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [trainset, decoder] = getTrainSet(self, key);
            [testset, ~] = getTestSet(self, key);
            model = getLC(cd_simulated.TrainedLC & key);
        end
            
    end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            
            lc_model = getLC(cd_simulated.TrainedLC & key);
            dataSet = self.getTestSet(key);
            
            [muLL, logl] = lc_model.getLogLikelihood(dataSet);
            modelChoice = lc_model.pRespA(dataSet) > 0.5;
            actualChoice = strcmp(dataSet.selected_class, 'A');
            correctChoice = modelChoice(:) == actualChoice(:);
            pCorrect = mean(correctChoice);
            
            fprintf('%s model fit mu_logl = %.3f\n', lc_model.modelName, muLL);
            tuple.lc_test_mu_logl = muLL;
            tuple.lc_test_logl = logl;
            tuple.lc_testset_size = length(logl);
            tuple.model_choice = modelChoice;
            tuple.model_correct = correctChoice;
            tuple.prop_correct = pCorrect;
            tuple.subj_choice = actualChoice;
            tuple.orientation = dataSet.orientation;
            
			self.insert(tuple)
		end
	end

end