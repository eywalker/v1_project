%{
class_discrimination.PLCTestSets (computed) # testset for PLC
plc_testset_id       : int           # id for parameterized likelihood classifier testset
-----
-> class_discrimination.ParameterizedLikelihoodSets
%}

classdef PLCTestSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(class_discrimination.ParameterizedLikelihoodSets, 'plset_id -> plc_testset_id');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.plset_id = tuple.plc_testset_id;
            self.insert(tuple)
		end
    end
    
    methods
        function plSet = fetchPLSet(self)
                assert(count(self)==1, 'Only can fetch one dataset at a time!');
                plSet = fetchPLSet(class_discrimination.ParameterizedLikelihoodSets & self);
        end
    end
end