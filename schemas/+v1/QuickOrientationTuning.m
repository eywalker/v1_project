%{
v1.QuickOrientationTuning (computed) # my newest table
-> ephys.Spikes
-> stimulation.MultiDimInfo
-----
lags                      : longblob   # the lags computed at
responses                 : longblob   # the individual responses
orientations              : longblob   # the orientation for those trials
mean_response             : longblob   # the orientaiton versus latency
ori_tun_p                 : double     # p-value for orientation tuning
%}

classdef QuickOrientationTuning < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('v1.QuickOrientationTuning')
        popRel = ephys.Spikes*stimulation.MultiDimInfo  % !!! update the populate relation
    end
    
    methods
        function self = QuickOrientationTuning(varargin)
            self.restrict(varargin)
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            tuple = key;
            
            % stimulus data
            [trial_num trial_params] = fetchn(stimulation.StimTrials('valid_trial=1') & key, 'trial_num', 'trial_params');
            trial_params = cat(1,trial_params{:});
            [condition_num, condition] = fetchn(stimulation.StimConditions & key, 'condition_num', 'condition_info');
            condition = cat(1,condition{:});
            assert(all(condition_num' == 1:length(condition)));
            
            spike_times = fetch1(ephys.Spikes & key, 'spike_times');
            
            lags = 20:5:150;
            
            orientations = [];
            bin_times = [];
            for i = 1:length(trial_params)
                subStim = fetch(stimulation.StimTrialEvents('event_type="showSubStimulus" OR event_type="endStimulus"') & setfield(key,'trial_num',trial_num(i)),'*');
                bin_times = [bin_times; double([subStim.event_time])'];
                orientations = [orientations; ...
                    cat(1,condition(trial_params(i).conditions).orientation); ...
                    NaN];
            end
            
            for i = 1:length(lags)
                tuple.responses(:,i) = histc(spike_times,bin_times + lags(i));
            end
            
            tuple.responses(isnan(orientations),:) = [];
            orientations(isnan(orientations)) = [];
            tuple.orientations = orientations;
            
            uo = unique(tuple.orientations);
            for j = 1:length(uo)
                tuple.mean_response(j,:) = mean(tuple.responses(tuple.orientations == uo(j),:),1);
            end
            
            tuple.lags = lags;
            
            % test orientation tuning by bootstrapping significance of
            % first Fourier component
            hash = dj.DataHash(key);
            rng(hex2dec(hash(1 : 5)))
            nIter = 10000;
            nOri = numel(uo);
            theta = uo / 90 * pi;
            v = exp(1i * theta);
            v = v / norm(v);
            ndx = ismember(lags, [40 50 60]);
            pj = zeros(nIter, sum(ndx));
            ri = tuple.mean_response(:, ndx);
            p = abs(v' * ri);
            for j = 1 : nIter
                pj(j, :) = abs(v' * ri(randperm(nOri), :));
            end
            tuple.ori_tun_p = min(mean(bsxfun(@gt, pj, p)));
            
            self.insert(tuple)
        end
    end
    
    methods

        function plot(self)
            qot = fetch(self,'*');
            N = ceil(sqrt(length(qot)));
            
            for i = 1:length(qot)
                subplot(N,N,i);
                idx = find(qot(i).lags > 30 & qot(i).lags < 50);
                t = mean(qot(i).mean_response(:,idx),2);
                plot(unique(qot(i).orientations),t);
            end
        end
        
    end
end
