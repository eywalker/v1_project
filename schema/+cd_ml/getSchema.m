function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_ml', 'edgar_cd_ml');
end
obj = schemaObject;
end
