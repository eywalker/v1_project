%{
cd_decoder.DecoderModels (manual)      # list of population decoder models
decoder_id       : int                 # unique id for the decoder model
-----
decoder_class    : varchar(255)        # class name for the decoder model
decoder_label='' : varchar(255)        # descriptor for the model
decoder_config   : longblob            # structure for configuring the model
%}

classdef DecoderModels < dj.Relvar
    methods
        function self= DecoderModels(varargin)
            self.restrict(varargin{:});
        end
        
        function new_id = registerDecoder(self, model, config, label)
            if nargin < 4
                label = '';
            end
            
            last_id = max(fetchn(cd_decoder.DecoderModels, 'decoder_id'));
            if isempty(last_id)
                last_id = 0;
            end
            new_id = last_id + 1;
            if ~ischar(model) % if owner given as an object
                model = class(model);
            end
            
            tuple.decoder_id = new_id;
            tuple.decoder_class = model;
            tuple.decoder_config = config;
            tuple.decoder_label = label;
            insert(self, tuple);
        end
            
        function model=getDecoder(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.decoder_class);
            model.setModelConfigs(info.decoder_config);
        end
        
        function models=getDecoders(self)
            keys = fetch(self);
            models = [];
            for keyIdx = length(keys):-1:1
                model = getDecoder(self & keys(keyIdx));
                models(keyIdx) = model;
            end
        end
    end
end