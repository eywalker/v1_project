function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_cross_sim', 'edgar_cd_cross_sim');
end
obj = schemaObject;
end
