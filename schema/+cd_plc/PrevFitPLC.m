%{
cd_plc.PrevFitPLC (computed) # mirror of the previously trained plc models
-> cd_plc.PLCModels
-> cd_plc.PLCTrainSets
-----
plc_class    : varchar(255)     # class name for the likelihood classifier
plc_label='' : varchar(255)     # descriptor for the model
plc_trained_config   : longblob         # structure for configuring the model
plc_train_mu_logl   : double           # mean log likelihood after training
plc_trainset_size   : int             # size of the trainset
%}

classdef PrevFitPLC < dj.Relvar & dj.AutoPopulate

	properties
		popRel = (cd_plc.PLCModels * cd_plc.PLCTrainSets) & cd_plc.TrainedPLC;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = fetch(cd_plc.TrainedPLC & key, '*');
            self.insert(tuple);
		end
    end
    
    methods
        function model=getPLC(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.plc_class);
            model.setModelConfigs(info.plc_trained_config);
        end
    end

end
