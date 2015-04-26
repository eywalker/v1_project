model = ClassifierModel.LikelihoodClassifier.PointPSLLC();
model.modelName = 'Gaussian Peak';
model.pointExtractor = @ClassifierModel.fitGaussToLikelihood;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Peak - Gaussian');

model = ClassifierModel.LikelihoodClassifier.PointPSLLC();
model.modelName = 'Mean Peak';
model.pointExtractor = @ClassifierModel.getMeanStd;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Peak - Mean Likelihood');

model = ClassifierModel.LikelihoodClassifier.PointPSLLC();
model.modelName = 'Max Peak';
model.pointExtractor = @ClassifierModel.getMaxStd;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Peak - Max Likelihood');

model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC();
model.modelName = 'Gaussian Peak Width';
model.pwExtractor = @ClassifierModel.fitGaussToLikelihood;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Peak Width - Gaussian');

model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC();
model.modelName = 'Mean Peak Width';
model.pwExtractor = @ClassifierModel.getMeanStd;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Peak Width - Mean Likelihood');

model = ClassifierModel.LikelihoodClassifier.PeakWidthPSLLC();
model.modelName = 'Max Peak Width';
model.pwExtractor = @ClassifierModel.getMaxStd;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Peak Width - Max Likelihood');

model = ClassifierModel.LikelihoodClassifier.FullPSLLC();
model.modelName = 'Full Likelihood';
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Full Likelihood');

model = ClassifierModel.LikelihoodClassifier.ScaledWidthPSLLC();
model.modelName = 'Scaled Width Mean Likelihood';
model.pwExtractor= @ClassifierModel.getMeanStd;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Scaled Width - Mean Likelihood');

model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC();
model.modelName = 'Stim Biased Gaussian Width';
model.pwExtractor = @ClassifierModel.fitGaussToLikelihood
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Stim Biased - Gaussian Width');

model = ClassifierModel.LikelihoodClassifier.PeakWidthSBPSLLC();
model.modelName = 'Stim Biased Likelihood Width';
model.pwExtractor = @ClassifierModel.getMeanStd
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Stim Biased - Likelihood Width');


model = ClassifierModel.LikelihoodClassifier.ScaledWidthSBPSLLC();
model.modelName = 'Stim Biased Scaled Likelihood Width';
model.pwExtractor = @ClassifierModel.getMeanStd;
registerLC(cd_lc.LCModels, model, model.getModelConfigs(), 'Stim Biased Scaled Width - Likelihood Width');