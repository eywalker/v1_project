function dataSet=prepareDataSet(dataSet, decoder, key)
%     decoder = getDecoder(cd_decoder.TrainedDecoder & key);
%     dataSet = fetchDataSet(cd_lc.LCTrainSets & key);


    dataSet.decoder = decoder; % store the decoder
    dataSet.goodUnits = decoder.unitFilter(:);
    dataSet.totalCounts = sum(dataSet.counts, 1);
    dataSet.goodTotalCounts = dataSet.goodUnits' * dataSet.counts;
%     if isprop(decoder, 'decodeOri')
%         decodeOri = decoder.decodeOri;
%     else
%         decodeOri = linspace(220, 320, 1000);
%     end
    decodeOri = linspace(200, 340, 8000);
    L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
    dataSet.decodeOri = decodeOri;
    dataSet.likelihood = L;
    
    if nargin >= 3
        dataSet.key = key;
    end
end