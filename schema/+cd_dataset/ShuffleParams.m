%{
cd_dataset.ShuffleParams (lookup) # my newest table
shuffle_method    : varchar(255)     # shuffling function
shuffle_seed      : int              # seed for randomization
shuffle_binwidth  : float            # width of the bin
---
shuffle_method_description=''   : varchar(255)  # brief description of the shuffle method
%}

classdef ShuffleParams < dj.Relvar
    methods
        function self=ShuffleParams(varargin)
            self.restrict(varargin{:});
        end
        
        function makeNew(self, method, binwidth, description, n)
            if nargin < 4
                n = 1;
            end
            seeds = randi(1000000, n, 1);
            tuple.shuffle_method = method;
            tuple.shuffle_binwidth = binwidth;
            tuple.shuffle_method_description = description;
            
            for i=1:n
                tuple.shuffle_seed = seeds(i);
                insert(self, tuple);
            end
        end
    end
end