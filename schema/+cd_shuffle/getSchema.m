function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    acq.getSchema();
    schemaObject = dj.Schema(dj.conn, 'cd_shuffle', 'edgar_cd_shuffle2');
end
obj = schemaObject;
