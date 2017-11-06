function setPath
    base = fileparts(mfilename('fullpath'));
    addpath(base)
    addpath(fullfile(base, 'analysis'))
    addpath(fullfile(base, 'schema'))
    addpath(fullfile(base, 'misc_code'))
    addpath(fullfile(base, 'recipes'))
    addpath(fullfile(base, 'figures'));
    addpath(fullfile(base, 'utils'));
    addpath(fullfile(base, 'scripts'));
end

