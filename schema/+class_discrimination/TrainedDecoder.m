%{
class_discrimination.TrainedDecoder (computed) # set of trained decoder
-> class_discrimination.DataSets
-> class_discrimination.DecoderModels
-----
decoder_class    : varchar(255)        # class name for the decoder model
decoder_label='' : varchar(255)        # descriptor for the model
decoder_config   : longblob            # structure for configuring the model
%}

classdef TrainedDecoder < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.DataSets * class_discrimination.DecoderModels
	end

	methods(Access=protected)

		function makeTuples(self, key)
            model = getModel(class_discrimination.DecoderModels & key);
            dataSet = fetchDataSet(class_discrimination.DataSets & key);
		%!!! compute missing fields for key here
			self.insert(key)
		end
	end

end