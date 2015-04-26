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
    end
end