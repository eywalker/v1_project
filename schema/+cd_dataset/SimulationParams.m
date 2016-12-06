%{
cd_dataset.SimulationParams (lookup) # my newest table
simulation_seed      : int              # seed for simulation
%}

classdef SimulationParams < dj.Relvar
    methods
        function self=SimulationParams(varargin)
            self.restrict(varargin{:});
        end
     
    end
end