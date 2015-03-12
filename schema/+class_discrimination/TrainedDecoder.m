%{
class_discrimination.TrainedDecoder (computed) # set of trained decoder
-> class_discrimination.DecoderTrainSets
-> class_discrimination.DecoderModels
-----
decoder_class    : varchar(255)        # class name for the decoder model
decoder_label='' : varchar(255)        # descriptor for the model
decoder_trained_config   : longblob            # structure for configuring the model
%}

classdef TrainedDecoder < dj.Relvar & dj.AutoPopulate

	properties
		popRel = class_discrimination.DecoderTrainSets * class_discrimination.DecoderModels;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            decoder_info = fetch(class_discrimination.DecoderModels & key ,'*');
            tuple.decoder_class = decoder_info.decoder_class;
            tuple.decoder_label = decoder_info.decoder_label;
            
            decoder = getDecoder(class_discrimination.DecoderModels & key);
            dataSet = fetchDataSet(class_discrimination.DecoderTrainSets & key);
            decoder.train(dataSet);
            tuple.decoder_trained_config = decoder.getModelConfigs();
            
			self.insert(tuple)
		end
    end
    
    methods
        function model=getDecoder(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.decoder_class);
            model.setModelConfigs(info.decoder_trained_config);
        end
    end

end