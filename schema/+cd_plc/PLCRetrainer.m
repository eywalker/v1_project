%{
cd_plc.PLCRetrainer (computed) # retrains PLC models
-> cd_plc.TrainedPLC
-----
plc_class    : varchar(255)     # class name for the likelihood classifier
plc_label='' : varchar(255)     # descriptor for the model
plc_updated  : tinyint          # whether updated or not
%}

classdef PLCRetrainer < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_plc.TrainedPLC
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            plc_info = fetch(cd_plc.TrainedPLC & key ,'*');
            plc_model = getPLC(cd_plc.TrainedPLC & key);
            
            old_mu_logl = plc_info.plc_train_mu_logl;
            tuple.plc_class = plc_info.plc_class;
            tuple.plc_label = plc_info.plc_label;
            
            [new_mu_logl, ~] = train(cd_plc.TrainedPLC, plc_model, key, 50);
            
            if (new_mu_logl - old_mu_logl) > 0.001
                plc_trained_config = plc_model.getModelConfigs();
                update(cd_plc.TrainedPLC & key, 'plc_train_mu_logl', new_mu_logl);
                update(cd_plc.TrainedPLC & key, 'plc_trained_config', plc_trained_config);
                tuple.plc_updated = true;
                fprintf('Updated! %.3f -> %.3f\n', old_mu_logl, new_mu_logl);
            else
                fprintf('Not updated...\n');
                tuple.plc_updated = false;
            end
            
			self.insert(tuple)
		end
    end
    
end