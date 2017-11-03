%{
-> class_discrimination.SpikeCountSet
-> class_discrimination.SpikesCleanupParams
-----
total_trials_removed: int  # total number of trials removed
total_trials_left: int # total trials remaining after removal
removed_by_total_criteria: int  # number of units removed due to total counts based criteria
removed_by_unit_criteria: int # number of units removed due to unit based criteria
%}

classdef CleanSpikeCountSet < dj.Computed
    properties
        popRel = class_discrimination.SpikeCountSet * class_discrimination.SpikesCleanupParams;
    end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            trials = class_discrimination.SpikeCountTrials * class_discrimination.SpikesCleanupParams & key;
            data = fetch(trials, 'counts');
            n_trials = length(data);

            params = fetch(class_discrimination.SpikesCleanupParams, '*');

            % across units correction
            zval = params.zsteps;
            counts = [data.counts];
            totalCounts = sum(counts, 1);
            lowq = prctile(totalCounts, 25);
            med = prctile(totalCounts, 50);
            highq = prctile(totalCounts, 75);
            sigma = (highq - lowq) / 1.35;
            lowThr = med -  zval * sigma;
            highThr = med + zval * sigma;

            goodTrials = totalCounts > lowThr & totalCounts < highThr;

            % per unit correction
            lowv = prctile(counts, 25, 2);
            medv = prctile(counts, 50, 2);
            highv = prctile(counts, 75, 2);
            delta = (highv - lowv) / 50;
            factor = params.factor;
            fraction = params.fraction;
            hight = medv + factor * 50 * delta;
            lowt = medv - factor * 50 * delta;
            good = bsxfun(@ge, counts, lowt) & bsxfun(@le, counts, hight);
            goodUnitTrials = sum(good, 1) > fraction * size(good, 1);

            goodOverallTrials = goodTrials & goodUnitTrials;

            tuple.total_trials_left = sum(goodOverallTrials);
            tuple.total_trials_removed = n_trials - tuple.total_trials_left;
            tuple.removed_by_total_criteria = n_trials - sum(goodTrials);
            tuple.removed_by_unit_criteria = n_trials - sum(goodUnitTrials);
    
			self.insert(tuple);
            
            data = data(goodOverallTrials);
            data = rmfield(data, 'counts');
            
            makeTuples(class_discrimination.CleanSpikeCountTrials, data);
		end
	end

end