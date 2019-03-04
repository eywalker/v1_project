function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_ml3', 'edgar_cd_ml3');
end
obj = schemaObject;
end
