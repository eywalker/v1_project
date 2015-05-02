%{
cd_plc.PLCTrainTestPairs (lookup) # valid pairs of trainset and testset for the parameterized likelihood classifiers
-> cd_plc.PLCTrainSets
-> cd_plc.PLCTestSets
%}

classdef PLCTrainTestPairs < dj.Relvar
    methods
        function self=PLCTrainTestPairs(varargin)
            self.restrict(varargin{:});
        end
        function registerPair(self, keys)
            if ~isstruct(keys)
                keys = fetch(keys - self);
            end
            fields = {'plc_trainset_owner', 'plc_trainset_hash',...
                'plc_testset_owner', 'plc_testset_hash'};
            tuples = dj.struct.pro(keys, fields{:});
            for tuple = tuples'
                fprintf('Registering a plc trainset in %s with a plc testset in %s...\n',...
                    tuple.plc_trainset_owner,...
                    tuple.plc_testset_owner);
                inserti(self, tuple);
            end
            
        end
    end
end