%{
# 
-> `edgar_cd_dlset`.`__d_l_set_info`
---
contrasts                   : longblob                      # 
orientation                 : longblob                      # 
mu_likelihood               : longblob                      # 
sigma_likelihood            : longblob                      # 
mean_sigma                  : float                         # 
max_ori                     : longblob                      # 
%}


classdef LikelihoodStats < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			 self.insert(key)
		end
	end

end