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
            if ~isstruct(keys)
                keys = fetch(keys - keys & self);
            end
            fields = {'dec_trainset_owner', 'dec_trainset_hash',...
                'lc_trainset_owner', 'lc_trainset_hash'};
            tuples = dj.struct.pro(keys, fields{:});
%             if count(self & tuple)
%                 % pair already exists, skip!
%                 return;
%             end
%             fprintf('Registering decoder_trainset_id=%d and lc_trainset_id=%d...\n', decoderTrainsetID, lcTrainsetID);
            for tuple = tuples'
                fprintf('Registering a decoder trainset in %s with a lc trainset in %s...\n',...
                    tuple.dec_trainset_owner,...
                    tuple.lc_trainset_owner);
                inserti(self, tuple);
            end
            %inserti(self, tuples);
        end
    end
end