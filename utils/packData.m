function packedData = packData(dataSet)
    % given a structure array, will "pack" field contents into a single
    % element structure array with stacked field elements
    if length(dataSet) == 1
        packedData = dataSet;
        return;
    end
    packedData = struct();
    for x = fields(dataSet)'
        f = x{:};
        if ischar(dataSet(1).(f))
            packedData.(f) = {dataSet.(f)};
        else
            packedData.(f) = [dataSet.(f)];
        end
    end
end