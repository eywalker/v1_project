%{
cd_decoder.TrainedDecoder (computed) # set of trained decoder
-> cd_decoder.DecoderTrainSets
-> cd_decoder.DecoderModels
-----
decoder_class    : varchar(255)                # class name for the decoder model
decoder_label='' : varchar(255)                # descriptor for the model
decoder_trained_config   : longblob            # structure for configuring the model
%}

classdef TrainedDecoder < dj.Relvar & dj.AutoPopulate

	properties
		popRel = cd_decoder.DecoderTrainSets * cd_decoder.DecoderModels;
	end

	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            decoder_info = fetch(cd_decoder.DecoderModels & key ,'*');
            tuple.decoder_class = decoder_info.decoder_class;
            tuple.decoder_label = decoder_info.decoder_label;
            
            decoder = getDecoder(cd_decoder.DecoderModels & key);
            dataSet = fetchDataSet(cd_decoder.DecoderTrainSets & key);
            decoder.train(dataSet);
            tuple.decoder_trained_config = decoder.getModelConfigs();
            
			self.insert(tuple)
		end
    end
    
    methods
        function self= TrainedDecoder(varargin)
            self.restrict(varargin{:});
        end
        
        function model=getDecoder(self)
            assert(count(self)==1, 'You can only retrieve one decoder at a time');
            info = fetch(self, '*');
            model = eval(info.decoder_class);
            model.setModelConfigs(info.decoder_trained_config);
        end
    end

end