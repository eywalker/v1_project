%{
class_discrimination.DecoderTrainSet (computed) # trainset for decoder
decoder_trainset_id       : int           # id for decoder trainset
-----
-> class_discrimination.DataSets
%}

classdef DecoderTrainSet < dj.Relvar & dj.AutoPopulate

	properties
		popRel = pro(class_discrimination.DataSets, 'dataset_id -> decoder_trainset_id');
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            key.dataset_id = tuple.decoder_trainset_id;
            self.insert(tuple)
		end
	end

end