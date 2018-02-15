function v=aslice(m, d, pos)
    sz = size(m);
    idx = [repmat({':'}, 1, d-1), {pos}, repmat({':'},1, length(sz)-d)];
    v = m(idx{:});
end