function  dataSet = selectData(dataSet, filter, exclusion)
    if nargin <  3
        exclusion = {};
    end
    for x = fields(dataSet)'
        f = x{:};
        if ismember(f, exclusion)
            continue
        end
        vals = dataSet.(f);
        dataSet.(f) = vals(:, filter);            
        
    end
end

