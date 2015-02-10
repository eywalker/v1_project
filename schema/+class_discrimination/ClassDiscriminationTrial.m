
%{
class_discrimination.ClassDiscriminationTrial (computed) # Contains information relavent for behavior classification

-> class_discrimination.ClassDiscriminationExperiment
-> stimulation.StimTrials
---
delay_time                  : int                           # The delay until the target
stimulus_class              : enum('A','B')                 # The stimulus class (A or B)
selected_class              : enum('A','B')                 # The selected stimulus class (A or B)
correct_response            : tinyint                       # True for a correct response
correct_direction           : enum('Left','Right')          # Direction for correct answer
selected_direction          : enum('Left','Right')          # Direction for correct answer
orientation                 : float                         # Orientation of the grating
posterior_a                 : float                         # Posterior probability of A
contrast                    : float                         # Contrast of stimulus
classdiscriminationtrial_ts=CURRENT_TIMESTAMP: timestamp    # automatic timestamp. Do not edit
%}

classdef ClassDiscriminationTrial < dj.Relvar
    properties(Constant)
        table = dj.Table('class_discrimination.ClassDiscriminationTrial');
    end
    
    methods 
        function self = ClassDiscriminationTrial(varargin)
            self.restrict(varargin{:})
        end
        
        function makeTuples(this, key)
            
	    valid_trials = fetch(stimulation.StimTrials(key, 'valid_trial=TRUE'));
	    if isempty(valid_trials)
		fprintf('No valid trials for this session...\n');
		return;
	    end
            tuples = dj.struct.join(key, valid_trials);
            
            tic
            trials = fetch((stimulation.StimTrialGroup * stimulation.StimTrials) ...
                & key & 'valid_trial=TRUE', 'stim_constants', 'trial_params');
            conditions = fetch(stimulation.StimConditions & key, 'condition_info');
            conditions = dj.struct.sort(conditions,'condition_num');            
            fprintf('Fetch time: %g seconds\n',toc);
            
            tic
            for data = trials'
                tuple = key;
                tuple.trial_num = data.trial_num;
                constants = data.stim_constants;
                params = data.trial_params;
                condition = conditions(params.condition).condition_info;
                
                if isfield(condition,'targetDelayTime')
                    tuple.delay_time = condition.targetDelayTime;
                else
                    tuple.delay_time = constants.targetDelayTime;
                end
                
                %% Determine cue class
                % cueClass 1: cue B
                % cueClass 2: cue A
                var = [condition.cueClass params.correctResponse];
                if isequal(var, [1 0])
                    tuple.stimulus_class = 'B';
                    tuple.selected_class = 'A';
                elseif isequal(var, [2 0])
                    tuple.stimulus_class = 'A';
                    tuple.selected_class = 'B';
                elseif isequal(var, [1 1])
                    tuple.stimulus_class = 'B';
                    tuple.selected_class = 'B';
                elseif isequal(var, [2 1])
                    tuple.stimulus_class = 'A';
                    tuple.selected_class = 'A';
                else
                    error('The cueClass has an invalid value');
                end
                
                %% Determine response direction
                % targetSetup 1: left target is B
                % targetSetup 2: left target is A
                % if cueClass is targetSetup then correct response on left
                var = [(condition.cueClass == condition.targetSetup) params.correctResponse];
                if isequal(var, [1 0])
                    tuple.correct_direction = 'Left';
                    tuple.selected_direction = 'Right';
                elseif isequal(var, [0 0])
                    tuple.correct_direction = 'Right';
                    tuple.selected_direction = 'Left';
                elseif isequal(var, [1 1])
                    tuple.correct_direction = 'Left';
                    tuple.selected_direction = 'Left';
                elseif isequal(var, [0 1])
                    tuple.correct_direction = 'Right';
                    tuple.selected_direction = 'Right';
                else
                    error('The cueClass has an invalid value');
                end
                
                %% Other things
                tuple.correct_response = params.correctResponse ~= 0;
                tuple.orientation = params.trialDirection; % Orientation of the grating
                if isfield(params, 'trialContrast')
                    % first see if that individual trial has a contrast
                    tuple.contrast = params.trialContrast;
                elseif isfield(condition, 'contrast')
                    % then see if it is for that condition
                    tuple.contrast = condition.contrast;
                else
                    % finally fall back to the global constant version
                    tuple.contrast = constants.contrast;
                    assert(length(constants.contrast) == 1, 'The contrast cannot be found properly')
                end
                
                dA = eval(['@(theta) ' constants.distributionA]);
                dB = eval(['@(theta) ' constants.distributionB]);
                theta = 0:.1:360;
                dA = interp1(theta, dA(theta), tuple.orientation);
                dB = interp1(theta, dB(theta), tuple.orientation);
                tuple.posterior_a = dA ./ (dA + dB);
                
                insert(this,tuple);
            end
            fprintf('Processed %d trials in %g seconds\n',length(trials),toc);
        end
    end
end
