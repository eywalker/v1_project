%{
cd_lc.LCTrainTestPairs (lookup) # valid pairs of trainset and testset for the likelihood classifiers
-> cd_lc.LCTrainSets
-> cd_lc.LCTestSets
%}

classdef LCTrainTestPairs < dj.Relvar
    methods
        function self=LCTrainTestPairs(varargin)
            self.restrict(varargin{:});
        end
        
        function registerPair(self, keys)
            if ~isstruct(keys)
                keys = fetch(keys - self);
            end
            fields = {'lc_trainset_owner', 'lc_trainset_hash',...
                'lc_testset_owner', 'lc_testset_hash'};
            tuples = dj.struct.pro(keys, fields{:});
            for tuple = tuples'
                fprintf('Registering a lc trainset in %s with a lc testset in %s...\n',...
                    tuple.lc_trainset_owner,...
                    tuple.lc_testset_owner);
                inserti(self, tuple);
            end
            
        end
    end
end