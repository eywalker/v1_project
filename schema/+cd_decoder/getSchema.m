function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    acq.getSchema();
    schemaObject = dj.Schema(dj.conn, 'cd_decoder', 'edgar_cd_decoder');
end
obj = schemaObject;
