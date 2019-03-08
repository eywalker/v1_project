%{
# my newest table
-> cd_decoder.DecoderTrainSets
-> cd_decoder.DecoderModels
# add additional attributes
%}

classdef FixedLikelihoodFiller < dj.Computed
    properties
        popRel = (cd_decoder.DecoderModels * cd_decoder.DecoderTrainSets & 'decoder_id in (14)' & proj(cd_dataset.CleanContrastSessionDataSet & cd_ml3.BestFixedLikelihood, 'dataset_hash -> dec_trainset_hash')) - pro(cd_decoder.TrainedDecoder)
    end

	methods(Access=protected)

		function makeTuples(self, key)
		%!!! compute missing fields for key here
            keyOrig = key;
            if key.decoder_id == 15
                restr = 'bin_counts = 91 and selection_objective="mse"';
            elseif key.decoder_id == 14
                restr = 'bin_counts = 91 and selection_objective="ce"';
            else
                return;
            end
            model_info = (cd_ml3.BestFixedLikelihood * cd_ml3.BinConfig & restr) * cd_dataset.CleanContrastSessionDataSet & (cd_dataset.DataSets * cd_decoder.DecoderTrainSets & key);
            if count(model_info)==0
               fprintf('No matching entry...');
               return
            end
            decoder_info = fetch(cd_decoder.DecoderModels & key, '*');
            [binw, binc] = fetchn(cd_ml3.BinConfig & pro(model_info), 'bin_width', 'bin_counts');
            low = -floor(binc / 2);
            high = low + binc - 1;
            decodeOri = low:high;
            decodeOri = decodeOri * binw + 270;
            
            model_config = fetch1(model_info, 'model');
            decoder = getDecoder(cd_decoder.DecoderModels & key);
            
            if isfield(model_config, 'hiddens.layer0.weight')
                decoder.w1 = double(model_config.('hiddens.layer0.weight'));
                decoder.b1 = double(model_config.('hiddens.layer0.bias'));
            else
                decoder.w1 = 1;
                decoder.b1 = 0;
            end
            
            if isfield(model_config, 'hiddens.layer1.weight')
                decoder.w2 = double(model_config.('hiddens.layer1.weight'));
                decoder.b2 = double(model_config.('hiddens.layer1.bias'));
            else
                decoder.w2 = 1;
                decoder.b2 = 0;
            end
            decoder.wo = double(model_config.('mu_ro.weight'));
            decoder.bo = double(model_config.('mu_ro.bias'));
            decoder.likelihood = squeeze(double(model_config.('likelihood')))';
            decoder.decodeOri = decodeOri;
            
            key.decoder_class = decoder_info.decoder_class;
            key.decoder_label = decoder_info.decoder_label;
            key.decoder_trained_config = decoder.getModelConfigs();
            
            insert(cd_decoder.TrainedDecoder, key);
            
            insert(self, keyOrig);
		end
	end

end