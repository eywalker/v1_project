%{
cd_plc.TrainedPLC (computed) # all trained PLC
-> cd_plc.PLCModels
-> cd_plc.PLCTrainSets
-----
plc_class    : varchar(255)     # class name for the likelihood classifier
plc_label='' : varchar(255)     # descriptor for the model
plc_trained_config   : longblob         # structure for configuring the model
plc_train_mu_logl   : double           # mean log likelihood after training
plc_trainset_size   : int             # size of the trainset
%}

classdef TrainedPLC < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_plc.PLCModels * cd_plc.PLCTrainSets;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            plc_info = fetch(cd_plc.PLCModels & key ,'*');
            tuple.plc_class = plc_info.plc_class;
            tuple.plc_label = plc_info.plc_label;
            
            if count(cd_plc.PrevFitPLC & key) == 1
                plc_model = getPLC(cd_plc.PrevFitPLC & key);
            else
                plc_model = getPLC(cd_plc.PLCModels & key);
            end
            
            [muLL, logl] = self.train(plc_model, key, 60);
            tuple.plc_trainset_size = length(logl);
            tuple.plc_train_mu_logl = muLL;
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
        
        function [muLL, logl] = train(self, plc_model, key, n)
            
            plSet = fetchPLSet(cd_plc.PLCTrainSets & key);
            plc_model.train(plSet, n);
            [muLL, logl] = plc_model.getLogLikelihood(plSet);
        end
        
        function retrain(self, keys, N)
            if nargin < 3
                N = 50;
            end
            if nargin < 2
                keys = [];
            end
            keys = fetch(self & keys);
            for i = 1:length(keys)
                key = keys(i);
                plc_model = getPLC(self & key);
                plc_mu_logl = self.train(plc_model, key, N);
                plc_trained_config = plc_model.getModelConfigs();
                update(self & key, 'plc_train_mu_logl', plc_mu_logl);
                update(self & key, 'plc_trained_config', plc_trained_config);
            end 
        end
    end

end
