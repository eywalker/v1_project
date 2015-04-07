keys = fetch(class_discrimination.FullSessionDataSet);
data = fetchDataSet(class_discrimination.FullSessionDataSet & keys(1), false);
for i = 2:length(keys)
    dataNew = fetchDataSet(class_discrimination.FullSessionDataSet & keys(i), false);
    data = [data; dataNew];
end

data = packData(data);

%%
dataSet = struct();
ra = respA(valid);
rr = {};
[rr{ra}] = deal('A');
[rr{~ra}] = deal('B');
dataSet.selected_class = rr;
dataSet.contrast = contrasts(valid);
dataSet.orientation = ori(valid);