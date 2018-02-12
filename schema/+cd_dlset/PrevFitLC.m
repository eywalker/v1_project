%{
# mirror of the previous trained lc models
-> cd_lc.LCModels
-> cd_dlset.DLSet
-> cd_dlset.CVSetMember
-----
lc_trained_config   : longblob       # structure for configuring the model
lc_train_mu_logl    : double         # mean log likelihood
lc_train_logl       : longblob       # logl value for all trials
lc_trainset_size : int               # size of the trainset
%}

classdef PrevFitLC < dj.Computed

	properties
		popRel = (cd_lc.LCModels * cd_dlset.DLSet * cd_dlset.CVSetMember) & pro(cd_dlset.TrainedLC);
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = fetch(cd_dlset.TrainedLC & key, '*');
            self.insert(tuple);
		end
    end
    
    methods

        function model=getLC(self)
            assert(count(self)==1, 'You can only retrieve one model at a time');
            info = fetch(self, '*');
            model = getLC(cd_lc.LCModels & self);
            model.setModelConfigs(info.lc_trained_config);
        end
    end
end