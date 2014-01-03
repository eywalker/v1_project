function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    sort.getSchema();
    schemaObject = dj.Schema(dj.conn, 'v1', 'v1_bayes');
end
obj = schemaObject;
