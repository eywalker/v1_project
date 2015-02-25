%{
class_discrimination.SpikeCountParams (lookup) # parameters for spike counts
count_start     : int           # time in ms to start counting spikes
count_stop      : int           # time in ms to stop counting spikes
%}

classdef SpikeCountParams < dj.Relvar
    methods
        function self=SpikeCountParams(varargin)
            self.restrict(varargin{:});
        end
    end
end