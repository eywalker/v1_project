%{
# parameters for spike cleanup
scu_id: int   # unique id
-----
zsteps: float # abs z-score for thresholding total spike counts
factor: float # correction factor for individual unit thresholding
fraction: float # fraction of total units that must be good to pass test
%}

classdef SpikesCleanupParams < dj.Lookup
    methods
        function fillContents(self)
            
            contents = [
                struct('scu_id', 0, ...
                       'zsteps', 4, ...
                       'factor', 1.5, ...
                       'fraction', 0.5)
            ];
            inserti(self, contents);
        end
    end
end