function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    acq.getSchema();
    schemaObject = dj.Schema(dj.conn, 'class_discrimination', 'edgar_class_discrimination');
end
obj = schemaObject;
