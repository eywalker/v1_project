%{
cd_dataset.CVParams (lookup) # stupid params for CV
cv_seed: int         # seed for rng
cv_n   : int         # n-way cross validation
%}

classdef CVParams < dj.Relvar
    methods
        function self=CVParams(varargin)
            self.restrict(varargin{:});
        end
        
        function makeNew(self, cv_n, n)
            if nargin < 4
                n = 1;
            end
            seeds = randi(1000000, n, 1);
            tuple.cv_n = cv_n;

            for i=1:n
                tuple.cv_seed = seeds(i);
                insert(self, tuple);
            end
        end
    end
end