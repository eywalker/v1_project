%{
cd_analysis.Duplicate (computed) # analysis of binary classification
-> cd_lc.TrainedLC
%}

classdef Duplicate < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(cd_lc.TrainedLC)
	end

	methods(Access=protected)
		function makeTuples(self, key)
			self.insert(key)
		end
	end

end