%{
cd_lc.PrevFitLC (computed) # mirror of the previous trained lc models
->cd_decoder.TrainedDecoder
->cd_lc.LCModels
->cd_lc.LCTrainSetPairs
-----
lc_class    : varchar(255)   # class name for the likelihood classifier
lc_label='' : varchar(255)   # descriptor for the model
lc_trained_config   : longblob       # structure for configuring the model
lc_train_mu_logl   : double          # mean log likelihood
lc_trainset_size : int                  # size of the trainset
%}

classdef PrevFitLC < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_lc.TrainedLC;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = fetch(cd_lc.TrainedLC & key, '*');
            self.insert(tuple);
		end
    end
    
    methods

        function model=getLC(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.lc_class);
            model.setModelConfigs(info.lc_trained_config);
        end
    end
end