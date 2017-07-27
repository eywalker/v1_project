function [adj_counts, corrected] = spikeFA(data)
    

    all_counts = [data.counts];
    all_contrasts = [data.contrast];
    u_cont = unique(all_contrasts);

    all_ori = [data.orientation];
    
    % whether adjusted count computed with correction
    corrected = zeros(size(all_counts, 2), 1);

    adj_counts = zeros(size(all_counts));

    for i=1:length(u_cont)
        correction = false;
        cont = u_cont(i);
        pos = all_contrasts == cont;

        % use square root of counts as described by Yu et al 2008
        counts = sqrt(all_counts(:, pos))';
        
        ori = all_ori(pos);

        edges = prctile(ori, linspace(0,100, 11));
        % extend edges to be completely inclusive
        edges(1) = edges(1) - 1;
        edges(end) = edges(end) + 1;
        hit = bsxfun(@le, ori(:), edges);
        loc = diff(hit, [], 2);
        ns = sum(loc, 1)';

        mu = bsxfun(@rdivide, loc' * counts, ns);

        mu_t = loc * mu;

        c_adj = counts - mu_t;
        
        % ensure that matrix is full rank, if not perform correction
        [U, S, V] = svd(c_adj);
        valid_s = find(abs(diag(S)) > 1e-12);
        n_valid = length(valid_s);
        if n_valid < size(c_adj, 2)
            correction = true;
            corrected(pos) = 1;
            U = U(:, valid_s);
            S = S(valid_s, valid_s);
            V = V(:, valid_s);
            c_adj = U * S;
        end
        

        sigma = std(c_adj, [] ,1);
        c_norm = bsxfun(@rdivide, c_adj, sigma);
        
        [L, PSI, T, STATS, F] = factoran(c_norm, 1, 'Delta', 0.0000005);
        
        norm_res = c_norm - F * L';
        shifted_res = bsxfun(@times, norm_res, sigma);
        
        if correction
            shifted_res = shifted_res * V';
        end
        
        res = shifted_res + mu_t;
        
        adj_counts(:, pos) = (res').^2;
    end
    
    % convert to boolean matrix
    corrected = (corrected == 1);

    % round to the nearest integer for spike counts
    adj_counts = round(adj_counts);
end