data = fetch(cd_analysis.BinaryReadout, '*');

for idx=1:length(data)
    waitbar(idx/length(data));
    d = data(idx);
    insert(cd_analysis.BinaryReadout2, d);
end