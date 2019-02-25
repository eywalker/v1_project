keys = fetch(cd_simulated.TrainedLC & 'decoder_id = 4' & 'lc_shuffle_id = 0');
[trainSet, testSet, dec, model] = getAll(cd_dlset.LCModelFits & keys(1));

%%
simTrain = model.simulateDataset(trainSet);

newModel = getLC(cd_lc.LCModels & 'lc_id = 32');
newModel2 = getLC(cd_lc.LCModels & 'lc_id = 38');

newModel.train(simTrain);
newModel2.train(simTrain);

model.getLogLikelihood(simTrain)
newModel.getLogLikelihood(simTrain)
newModel2.getLogLikelihood(simTrain)

%%
simTest = model.simulateDataset(testSet);

model.getLogLikelihood(simTest)
newModel.getLogLikelihood(simTest)
newModel2.getLogLikelihood(simTest)

%%
restr = 'csc_hash = "0ab391586f486b3f48e18f056a2b136480255965" and dataset_contrast = "0.08"';
%model_info = cd_ml.BestModelByBin * (cd_ml.BinConfig & restr) * cd_dataset.CleanContrastSessionDataSet & (cd_dataset.DataSets * cd_decoder.DecoderTrainSets & key);
model_info = cd_ml.BestPoissonLikeByBin * cd_ml.BinConfig * cd_dataset.CleanContrastSessionDataSet & restr;

if count(model_info)==0
   fprintf('No matching entry...');
   return
end
%decoder_info = fetch(cd_decoder.DecoderModels & key, '*');
[binw, binc] = fetchn(cd_ml.BinConfig & pro(model_info), 'bin_width', 'bin_counts');
low = -floor(binc / 2);
high = low + binc - 1;
decodeOri = low:high;
decodeOri = decodeOri * binw + 270;

model_config = fetch1(model_info, 'model');
%decoder = getDecoder(cd_decoder.DecoderModels & key);
decoder = ClassifierModel.CoderDecoder.MLPoissonLikeDecoder();
%%
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
%%
key.decoder_class = decoder_info.decoder_class;
key.decoder_label = decoder_info.decoder_label;
key.decoder_trained_config = decoder.getModelConfigs();

insert(cd_decoder.TrainedDecoder, key);
