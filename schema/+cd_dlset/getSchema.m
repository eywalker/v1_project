function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'cd_dlset', 'edgar_cd_dlset');
end
obj = schemaObject;
end
