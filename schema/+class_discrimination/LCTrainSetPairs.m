%{
class_discrimination.LCTrainSetPairs (lookup) # valid pairs of decoder and lc trainsets
-> class_discrimination.DecoderTrainSets
-> class_discrimination.LCTrainSets
%}

classdef LCTrainSetPairs < dj.Relvar
    methods
        function self=LCTrainSetPairs(varargin)
            self.restrict(varargin{:});
        end
        
        function registerPair(self, decoderTrainsetID, lcTrainsetID)
            tuple.decoder_trainset_id = decoderTrainsetID;
            tuple.lc_trainset_id = lcTrainsetID;

            fprintf('Registering decoder_trainset_id=%d and lc_trainset_id=%d...\n', decoderTrainsetID, lcTrainsetID);
            inserti(self, tuple);
        end
    end
end