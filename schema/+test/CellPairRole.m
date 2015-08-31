%{
test.CellPairRole (manual) # my newest table
-> test.CellPair
role_id    :int      # identifier for the role
---
-> test.Cell
%}

classdef CellPairRole < dj.Relvar
end