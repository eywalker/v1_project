function  dataSet = selectData(dataSet, filter)
    for x = fields(dataSet)'
        f = x{:};
        vals = dataSet.(f);
        dataSet.(f) = vals(:, filter);
    end
end

