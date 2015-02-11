function setPath
    
    base = fileparts(mfilename('fullpath'));
    addpath(base)
    addpath(fullfile(base, 'lib'))

end

