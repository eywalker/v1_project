%{
class_discrimination.TrainedPLC (computed) # all trained PLC
-> class_discrimination.PLCModels
-> class_discrimination.PLCTrainSets
-----
plc_class    : varchar(255)     # class name for the likelihood classifier
plc_label='' : varchar(255)     # descriptor for the model
plc_trained_config   : longblob         # structure for configuring the model
plc_mu_logl   : double           # mean log likelihood after training
%}

classdef TrainedPLC < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.PLCModels * class_discrimination.PLCTrainSets;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            plc_info = fetch(class_discrimination.PLCModels & key ,'*');
            tuple.plc_class = plc_info.plc_class;
            tuple.plc_label = plc_info.plc_label;
            
            
            plc_model = getPLC(class_discrimination.PLCModels & key);
            
            muLL = self.train(plc_model, key, 200);
            
            tuple.plc_mu_logl = muLL;
            tuple.plc_trained_config = plc_model.getModelConfigs();
			self.insert(tuple)
		end
    end
    
    methods
        function model=getPLC(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.plc_class);
            model.setModelConfigs(info.plc_trained_config);
        end
        
        function muLL = train(self, plc_model, key, n)
            
            plSet = fetchPLSet(class_discrimination.PLCTrainSets & key);
            muLL = plc_model.train(plSet, n);
        end
        
        function retrain(self, keys)
            if nargin < 2
                keys = [];
            end
            keys = fetch(self & keys);
            for i = 1:length(keys)
                key = keys(i);
                plc_model = getPLC(self & key);
                plc_mu_logl = self.train(plc_model, key, 100);
                plc_trained_config = plc_model.getModelConfigs();
                update(self & key, 'plc_mu_logl', plc_mu_logl);
                update(self & key, 'plc_trained_config', plc_trained_config);
            end 
        end
    end

end
