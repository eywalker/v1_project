function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_simulated', 'edgar_cd_simulated');
end
obj = schemaObject;
end
