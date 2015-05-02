%{
cd_plset.PLShuffleParams (lookup) # parameters for shuffling plsets
plshuffle_method     :  varchar(255)      # shuffling function
plshuffle_seed         :  int               # seed for randomization
plshuffle_binwidth     :  float             # width of the bin
---
plshuffle_method_description=''     :varchar(255)    # brief description of the shuffle method
%}

classdef PLShuffleParams < dj.Relvar
    methods
        function self=PLShuffleParams(varargin)
            self.restrict(varargin{:});
        end
        
        function makeNew(self, method, binwidth, description, n)
            if nargin < 4
                n = 1;
            end
            seeds = randi(1000000, n, 1);
            tuple.plshuffle_method = method;
            tuple.plshuffle_binwidth = binwidth;
            tuple.plshuffle_method_description = description;
            
            for i=1:n
                tuple.plshuffle_seed = seeds(i);
                insert(self, tuple);
            end
        
        end
    end
end