drop(test.Cell);
drop(test.CellPair);
N = 5;
for i=1:N
    cell.cell_id=i;
    insert(test.Cell, cell);
end

combo = N*(N-1)/2;
k=1;
for f=1:N
    for s=f:N
        pair.pair_id = k;
        insert(test.CellPair, pair);
        role.pair_id = k;
        role.role_id = 1;
        role.cell_id = f;
        insert(test.CellPairRole, role);
        role.role_id = 2;
        role.cell_id = s;
        insert(test.CellPairRole, role);
        fprintf('Registered pair for %d and %d\n', f, s);
        k = k+1;
    end
    
end