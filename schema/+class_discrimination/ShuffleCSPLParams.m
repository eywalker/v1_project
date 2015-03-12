%{
class_discrimination.ShuffleCSPLParams (lookup) # my newest table
shuffle_cspl_seed      : int       # seed for randomization
shuffle_cspl_binwidth  : float     # width of stimulus bin
%}

classdef ShuffleCSPLParams < dj.Relvar
    methods
        function self=ShuffleCSPLParams(varargin)
            self.restrict(varargin{:});
        end
    end
end