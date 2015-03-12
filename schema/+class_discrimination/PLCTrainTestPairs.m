%{
class_discrimination.PLCTrainTestPairs (lookup) # valid pairs of trainset and testset for the likelihood classifiers
-> class_discrimination.PLCTrainSets
-> class_discrimination.PLCTestSets
%}

classdef PLCTrainTestPairs < dj.Relvar
    methods
        function self=PLCTrainTestPairs(varargin)
            self.restrict(varargin{:});
        end
        
        function registerPair(self, plcTrainsetID, plcTestsetID)
            tuple.plc_trainset_id = plcTrainsetID;
            tuple.plc_testset_id = plcTestsetID;
            fprintf('Registering plc_trainset_id=%d and plc_testset_id=%d...\n', plcTrainsetID, plcTestsetID);
            inserti(self, tuple);
        end
    end
end