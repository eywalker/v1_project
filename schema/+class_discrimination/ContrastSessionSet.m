%{
class_discrimination.ContrastSessionSet (computed) # data grouped by session and contrast
-> class_discrimination.ClassDiscriminationExperiment
contrast       :varchar(128)             # contrast used
-----
-> class_discrimination.DataSets
%}

classdef ContrastSessionSet < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.ClassDiscriminationExperiment & class_discrimination.SpikeCountSet;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            fetch(class_discrimination.ClassDiscriminationTrial & key, '*');
		end
	end

end