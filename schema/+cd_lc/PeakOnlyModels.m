%{
cd_lc.PeakOnlyModels (computed) # my newest table
-> cd_lc.TrainedLC
-----
prior_a     : float     # prior over class A
alpha       : float     # exponent factor over posterior
lapse_rate  : float     # lapse rate
peak_extractor : varchar(255)   # method of peak extraction
lc_train_mu_logl : float  # mean log likelihood fit on train set
%}

classdef PeakOnlyModels < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_lc.TrainedLC & 'lc_label like "Peak - %"';
	end

	methods(Access=protected)

		function makeTuples(self, key)
            model = fetch(cd_lc.TrainedLC & key);
            tuple = key;
            tuple.prior_a = model.priorA;
            tuple.alpha = model.alpha;
            tuple.lapse_rate = model.lapseRate;
            tuple.peak_extractor = func2str(model.pointExtractor);
            tuple.lc_train_mu_logl = fetch1(cd_lc.TrainedLC & key, 'lc_train_mu_logl');
            self.insert(tuple);
		end
	end

end