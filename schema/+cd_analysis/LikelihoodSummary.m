%{
# 
-> `edgar_cd_dlset`.`__d_l_set_info`
-> cd_analysis.SummaryBinConfig
---
contrast                    : float                         # 
samples                     : longblob                      # 
likelihoods                 : longblob                      # 
centered_likelihoods        : longblob                      # 
%}


classdef LikelihoodSummary < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			 self.insert(key)
		end
	end

end