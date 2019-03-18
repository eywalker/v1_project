
%{
-> class_discrimination.ClassDiscriminationTrial
---
response_delay: float
orientation: float
contrast: float
%}

classdef ResponseDelay < dj.Computed
    properties
        popRel = class_discrimination.ClassDiscriminationExperiment & class_discrimination.SpikeCountSet
    end

    
    methods (Access=protected)        
        function makeTuples(self, key)
            % Get additional information for each trial
            tuple = key;
            sstim = proj(stimulation.StimTrialEvents & 'event_type="showStimulus"', 'event_time -> show_stim', 'event_type -> sstim_ev');
            resp = proj(stimulation.StimTrialEvents & 'event_type="response"', 'event_type -> resp_ev', 'event_time -> resp');
            trials = class_discrimination.ClassDiscriminationTrial & key;
            
            dt = fetch(proj(sstim * resp * trials, '(resp - show_stim) -> delta', 'contrast', 'orientation'), 'delta', 'contrast');
            
            for trial=dt'
                tuple.trial_num = trial.trial_num;
                tuple.response_delay = trial.delta;
                tuple.contrast = trial.contrast;
                tuple.orientation = trial.orientation;
                insert(self, tuple);
            end
        end
        
    end
end