%{
cd_lc.LCModelEvaluation (computed) # my newest table
-> cd_lc.TrainedLC
-> cd_lc.LCTrainTestPairs
-----
lc_test_mu_logl  : float  # mean loglikelihood
lc_test_total_logl : float  # total loglikelihood
lc_testset_size  : int    # size of the testset
lc_test_logl     : longblob  # individual trial log likelihood
lc_model_choice                : longblob                      # binary readout of a trial from the model
lc_model_correct               : longblob                      # indicates whether model choice was correct
lc_prop_correct                : float                         # proportion of correct trials
%}

classdef LCModelEvaluation < dj.Relvar & dj.AutoPopulate

	properties
		popRel  = cd_lc.TrainedLC * cd_lc.LCTrainTestPairs
    end
    
    methods
        function self = LCModelFits(varargin)
            self.restrict(varargin{:});
        end
        
        function [dataSet, decoder] = getTrainSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [dataSet, decoder] = getDataSet(cd_lc.TrainedLC & key);
        end
        
        function [dataSet, decoder] = getTestSet(self, key)
            if nargin < 2
                key = fetch(self);
            end
            decoder = getDecoder(cd_decoder.TrainedDecoder & key);
            dataSet = fetchDataSet(cd_lc.LCTestSets & key);
            dataSet = prepareDataSet(dataSet, decoder, key);
        end
        
        function [trainset, testset, decoder, model]=getAll(self, key)
            if nargin < 2
                key = fetch(self);
            end
            [trainset, decoder] = getTrainSet(self, key);
            [testset, ~] = getTestSet(self, key);
            model = getLC(cd_lc.TrainedLC & key);
        end
        
        function dataset=getResult(self)
            assert(length(self)==1, 'Can only get one result at a time');
            result = fetch(self, '*');
            dataset = getTestSet(self);
            dataset.test_logl = result.lc_test_logl;
            dataset.model_choice = result.lc_model_choice;
            dataset.model_correct = result.lc_model_correct;
        end
        
            
    end

	methods(Access=protected)

		function makeTuples(self, key)
            [trainset, testset, decoder, model] = getAll(self, key);
            [muLL, logLList] = model.getLogLikelihood(testset);
            key.lc_test_mu_logl = muLL;
            key.lc_testset_size = length(logLList);
            key.lc_test_total_logl = sum(logLList);
            key.lc_test_logl = logLList;
            
            
            modelChoice = model.pRespA(testset) > 0.5;
            actualChoice = strcmp(testset.selected_class, 'A');
            correctChoice = modelChoice == actualChoice';
            pCorrect = mean(correctChoice);
            
            key.lc_model_choice = modelChoice;
            key.lc_model_correct = correctChoice;
            key.lc_prop_correct = pCorrect;
			self.insert(key)
            
		end
	end

end