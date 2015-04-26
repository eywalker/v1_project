function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    acq.getSchema();
    schemaObject = dj.Schema(dj.conn, 'cd_dataset', 'edgar_cd_dataset');
end
obj = schemaObject;
