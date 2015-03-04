%{
class_discrimination.CVParams (lookup) # stupid params for CV
cv_seed: int         # seed for rng
cv_n   : int         # n-way cross validation
%}

classdef CVParams < dj.Relvar
    methods
        function self=CVParams(varargin)
            self.restrict(varargin{:});
        end
    end
end