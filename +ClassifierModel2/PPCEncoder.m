classdef PPCEncoder < handle
    %PPCENCODER Summary of this class goes here
    %   Detailed explanation goes here
    

    methods (Abstract)
        [spikeCounts]=encode(stimulus,contrast)
        logL=train(stimulus,contrast,spikeCounts)
    end
    
end

