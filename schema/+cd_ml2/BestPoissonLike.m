%{
# my newest table
# add primary key here
-----
# add additional attributes
%}

classdef BestPoissonLike < dj.Computed

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			 self.insert(key)
		end
	end

end