function dataSet=prepareDataSet(dataSet, decoder, key, nori)
%     decoder = getDecoder(cd_decoder.TrainedDecoder & key);
%     dataSet = fetchDataSet(cd_lc.LCTrainSets & key);
    if nargin < 4 || isempty(nori)
        nori = 8000;
    end

    dataSet.decoder = decoder; % store the decoder
    dataSet.goodUnits = decoder.unitFilter(:);
    dataSet.totalCounts = sum(dataSet.counts, 1);
    dataSet.goodTotalCounts = dataSet.goodUnits' * dataSet.counts;
%     if isprop(decoder, 'decodeOri')
%         decodeOri = decoder.decodeOri;
%     else
%         decodeOri = linspace(220, 320, 1000);
%     end
    % :(  Dirty hack to restrict the dampening and renormalization only to
    % decoder_id = 1 case (Likelihood based on tuning curves + poisson
    % noise). Technically should be fine to apply to any other cases, but
    % putting this restriction "just in case"
    
    decodeOri = linspace(200, 340, nori);
    L = decoder.getLikelihoodDistr(decodeOri, dataSet.contrast, dataSet.counts);
    if key.decoder_id == 1
        damped = ones(length(decodeOri), 1);
        damped(decodeOri < 230 | decodeOri > 310) = 0;
        L = bsxfun(@times, damped, L);  % suppress responses outside of the reasonable domain
        L = bsxfun(@rdivide, L, sum(L, 1)); % renormalize the area under the likelihood function
    end
    dataSet.decodeOri = decodeOri;
    dataSet.likelihood = L;
    
    if nargin >= 3
        dataSet.key = key;
    end
end