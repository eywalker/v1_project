function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_ml2', 'edgar_cd_ml2_updated');
end
obj = schemaObject;
end
