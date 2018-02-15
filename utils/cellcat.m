function S = cellcat(C, d, dim)
if nargin < 3
    dim = 1;
end

sz = size(C);
Cp = permute(C, [1:d-1, d+1:length(sz), d]);
psz = size(Cp);
Cp = reshape(Cp, [], sz(d));
n = size(Cp, 1);
Cc = cell(n, 1);
for i=1:n
    Cc{i,1} = cat(dim, Cp{i, :});
end

Cc = reshape(Cc, [psz(1:end-1), 1]);
S = permute(Cc, [1:d-1, length(sz), d:length(sz)-1]);

end