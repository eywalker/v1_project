%{
class_discrimination.ShuffleParams (lookup) # my newest table
shuffle_seed      : int       # seed for randomization
shuffle_binwidth  : float     # width of stimulus bin
%}

classdef ShuffleParams < dj.Relvar
    methods
        function self=ShuffleParams(varargin)
            self.restrict(varargin{:});
        end
    end
end