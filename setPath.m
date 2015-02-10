function setPath
    
    base = fileparts(mfilename('fullpath'));
    addpath(base)
    addpath(fullfile(base, 'analysis'))
    addpath(fullfile(base, 'schema'))
    addpath(fullfile(base, 'misc_code'))

end

