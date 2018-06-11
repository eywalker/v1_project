function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_sim', 'edgar_cd_sim');
end
obj = schemaObject;
end
