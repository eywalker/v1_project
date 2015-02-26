%{
class_discrimination.ContrastSessionDataSet (computed) # my newest table
-> class_discrimination.SpikeCountSet
contrast    : varchar(255)           # contrast of the stimulus
-----
-> class_discrimination.DataSets
%}

classdef ContrastSessionDataSet < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.SpikeCountSet;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.dataset_id = registerDataSet(class_discrimination.DataSets, self, 'grouped by contrast');
			self.insert(tuple);
        end
    end
    methods
        function dataSet = fetchDataSet(self)
            assert(count(self)==1, 'Only can fetch one dataset at a time!');
            dataSet = fetch(class_discrimination.ClassDiscriminationTrial * class_discrimination.SpikeCountTrials & self, '*');
        end
	end

end