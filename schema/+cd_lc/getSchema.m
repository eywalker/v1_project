function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    acq.getSchema();
    schemaObject = dj.Schema(dj.conn, 'cd_lc', 'edgar_cd_lc2');
end
obj = schemaObject;
