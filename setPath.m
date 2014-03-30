function setPath
    
    base = fileparts(mfilename('fullpath'));
    addpath(base)
    addpath(fullfile(base, 'analysis'))
    addpath(fullfile(base, 'data'))
end

