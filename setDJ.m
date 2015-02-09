clear functions;


resp = input('Work in test environment?(Y/n):','s')
if ~isempty(resp) && ismember(strtrim(lower(resp)), {'n', 'no', 'nope', 'nada', 'nay'})
    % use production environment
    host = 'at-database.neusc.bcm.tmc.edu';
    user = 'eywalker';
    pass = 'edgar#1';
else
    % use test environment
    host = 'at-backupdb';
    user = 'eywalker';
    pass = '9ePra2EW';
end

setenv('DJ_HOST', host);
setenv('DJ_USER', user);
setenv('DJ_PASS', pass);

fprintf('Datajoint connection\n')
fprintf('--------------------\n')
fprintf('host: %s\n', host)
fprintf('user: %s\n\n', user)

conn = dj.conn();
    