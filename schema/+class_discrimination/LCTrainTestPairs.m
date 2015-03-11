%{
class_discrimination.LCTrainTestPairs (lookup) # valid pairs of trainset and testset for the likelihood classifiers
-> class_discrimination.LCTrainSets
-> class_discrimination.LCTestSets
%}

classdef LCTrainTestPairs < dj.Relvar
    methods
        function self=LCTrainTestPairs(varargin)
            self.restrict(varargin{:});
        end
        
        function registerPair(self, lcTrainsetID, lcTestsetID)
            tuple.lc_trainset_id = lcTrainsetID;
            tuple.lc_testset_id = lcTestsetID;
            fprintf('Registering lc_trainset_id=%d and lc_testset_id=%d...\n', lcTrainsetID, lcTestsetID);
            inserti(self, tuple);
        end
    end
end