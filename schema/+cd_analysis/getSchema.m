function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_analysis', 'edgar_cd_analysis');
end
obj = schemaObject;
end
