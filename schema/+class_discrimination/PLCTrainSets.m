%{
class_discrimination.PLCTrainSets (computed) # trainset for PLC
plc_trainset_id       : int           # id for parameterized likelihood classifier trainset
-----
-> class_discrimination.ParameterizedLikelihoodSets
%}

classdef PLCTrainSets < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(class_discrimination.ParameterizedLikelihoodSets, 'plset_id -> plc_trainset_id');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            tuple.plset_id = tuple.plc_trainset_id;
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