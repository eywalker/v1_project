%{
# my newest table
-> cd_decoder.DecoderTrainSets
-> cd_decoder.DecoderModels
# add additional attributes
%}

classdef PoissonLikeFiller < dj.Computed
    properties
        popRel = (cd_decoder.DecoderModels * cd_decoder.DecoderTrainSets & 'dec_trainset_owner = "cd_dataset.CleanContrastSessionDataSet"' & 'decoder_id in (6)') - pro(cd_decoder.TrainedDecoder)
    end

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here

            if key.decoder_id == 6
                restr = 'bin_counts = 91';
            else
                % only work on decoder_id = 6
                return;
            end
            model_info = cd_ml.BestPoissonLikeByBin * (cd_ml.BinConfig & restr) * cd_dataset.CleanContrastSessionDataSet & (cd_dataset.DataSets * cd_decoder.DecoderTrainSets & key);
            if count(model_info)==0
               fprintf('No matching entry...');
               return
            end
            decoder_info = fetch(cd_decoder.DecoderModels & key, '*');
            [binw, binc] = fetchn(cd_ml.BinConfig & pro(model_info), 'bin_width', 'bin_counts');
            low = -floor(binc / 2);
            high = low + binc - 1;
            decodeOri = low:high;
            decodeOri = decodeOri * binw + 270;
            
            model_config = fetch1(model_info, 'model');
            decoder = getDecoder(cd_decoder.DecoderModels & key);
            
            if isfield(model_config, 'hiddens.0.weight')
                decoder.w1 = double(model_config.('hiddens.0.weight'));
                decoder.b1 = double(model_config.('hiddens.0.bias'));
            else
                decoder.w1 = 1;
                decoder.b1 = 0;
            end
            
            if isfield(model_config, 'hiddens.3.weight')
                decoder.w2 = double(model_config.('hiddens.3.weight'));
                decoder.b2 = double(model_config.('hiddens.3.bias'));
            else
                decoder.w2 = 1;
                decoder.b2 = 0;
            end
            decoder.wo = double(model_config.('ro_layer.weight'));
            decoder.bo = double(model_config.('ro_layer.bias'));
            decoder.decodeOri = decodeOri;
            
            key.decoder_class = decoder_info.decoder_class;
            key.decoder_label = decoder_info.decoder_label;
            key.decoder_trained_config = decoder.getModelConfigs();
            
            insert(cd_decoder.TrainedDecoder, key);
		end
	end

end