%{
cd_lc.LCTrainSetPairs (lookup) # valid pairs of decoder and lc trainsets
-> cd_decoder.DecoderTrainSets
-> cd_lc.LCTrainSets
%}

classdef LCTrainSetPairs < dj.Relvar
    methods
        function self=LCTrainSetPairs(varargin)
            self.restrict(varargin{:});
        end
        
        function registerPair(self, keys)
            
            tuple.decoder_trainset_id = decoderTrainsetID;
            tuple.lc_trainset_id = lcTrainsetID;
            if count(self & tuple)
                % pair already exists, skip!
                return;
            end
            fprintf('Registering decoder_trainset_id=%d and lc_trainset_id=%d...\n', decoderTrainsetID, lcTrainsetID);
            inserti(self, tuple);
        end
    end
end