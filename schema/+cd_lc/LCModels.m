%{
cd_lc.LCModels (manual)        # list of likelihood classifer models
lc_id       : int              # unique id for the likelihood classifier
---
lc_class    : varchar(255)     # class name for the likelihood classifier
lc_label='' : varchar(255)     # descriptor for the model
lc_config   : longblob         # structure for configuring the model
%}

classdef LCModels < dj.Relvar
    methods
        function self=LCModels(varargin)
            self.restrict(varargin{:});
        end
        
        function new_id = registerLC(self, label, model, config, new_id)
            if nargin < 4
                config = getModelConfigs(model);
            end
            
            if nargin < 5
                last_id = max(fetchn(cd_lc.LCModels, 'lc_id'));
                if isempty(last_id)
                    last_id = 0;
                end
                new_id = last_id + 1;
            end
            if ~ischar(model) % if owner given as an object
                model = class(model);
            end

            tuple.lc_id = new_id;
            tuple.lc_class = model;
            tuple.lc_config = config;
            tuple.lc_label = label;
            insert(self, tuple);
        end
        
        function model=getLC(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.lc_class);
            model.setModelConfigs(info.lc_config);
        end
    end
end