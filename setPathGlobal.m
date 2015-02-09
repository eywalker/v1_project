function setPath
    base = fileparts(mfilename('fullpath'));
    D = dir(base);
    subD = D(~ismember({D.name}, {'.', '..'}) & [D.isdir]);
    for d = subD'
        target = fullfile(base, d.name, 'setPath.m');
        if exist(target, 'file')
            run(target); 
        end
    end
end