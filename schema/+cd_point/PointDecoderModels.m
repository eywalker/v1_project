%{
cd_point.PointDecoderModels (manual)      # list of point decoder models
ptdec_id       : int                 # unique id for the point decoder model
-----
ptdec_class    : varchar(255)        # class name for the point decoder model
ptdec_label='' : varchar(255)        # descriptor for the point decoder model
ptdec_config   : longblob            # structure for configuring the point decoder model
%}

classdef PointDecoderModels < dj.Relvar
    methods
        function self = PointDecoderModels(varargin)
            self.restrict(varargin{:});
        end
        
        function new_id = registerPointDecoder(self, model, label, config)
            if nargin < 4
                config = model.getModelConfigs();
            end
            
            last_id = max(fetchn(cd_point.PointDecoderModels, 'ptdec_id'));
            if isempty(last_id)
                last_id = 0;
            end
            new_id = last_id + 1;
            if ~ischar(model) % if owner given as an object
                model = class(model);
            end
            
            tuple.ptdec_id = new_id;
            tuple.ptdec_class = model;
            tuple.ptdec_config = config;
            tuple.ptdec_label = label;
            insert(self, tuple);
        end
            
        function model=getPointDecoder(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.ptdec_class);
            model.setModelConfigs(info.ptdec_config);
        end
        
        function models=getPointDecoders(self)
            keys = fetch(self);
            models = [];
            for keyIdx = length(keys):-1:1
                model = getPointDecoder(self & keys(keyIdx));
                models(keyIdx) = model;
            end
        end
    end
end