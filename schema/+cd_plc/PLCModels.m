%{
cd_plc.PLCModels (manual) # list of parameterized likelihood classifer models
plc_id       : int              # unique id for the parameterized likelihood classifier
---
plc_class    : varchar(255)     # class name for the likelihood classifier
plc_label='' : varchar(255)     # descriptor for the model
plc_config   : longblob         # structure for configuring the model
%}

classdef PLCModels < dj.Relvar
    methods
        function self=PLCModels(varargin)
            self.restrict(varargin{:});
        end
        
        function new_id = registerPLC(self, model, config, label)
            if nargin < 4
                label = '';
            end

            last_id = max(fetchn(cd_plc.PLCModels, 'plc_id'));
            if isempty(last_id)
                last_id = 0;
            end
            new_id = last_id + 1;
            if ~ischar(model) % if owner given as an object
                model = class(model);
            end

            tuple.plc_id = new_id;
            tuple.plc_class = model;
            tuple.plc_config = config;
            tuple.plc_label = label;
            insert(self, tuple);
        end
        
        function model=getPLC(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.plc_class);
            model.setModelConfigs(info.plc_config);
        end
    end
end