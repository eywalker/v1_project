%{
v1.DecisionDecoder (computed) # my newest table
-> ephys.SpikesAlignedSet
-> class_discrimination.ClassDiscriminationExperiment
-----

%}

classdef DecisionDecoder < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('v1.DecisionDecoder')
        popRel = class_discrimination.ClassDiscriminationExperiment * ...
            ephys.SpikesAlignedSet;
    end
    
    methods
        function self = DecisionDecoder(varargin)
            self.restrict(varargin)
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            tuple = key;
            
            trials = fetch(class_discrimination.ClassDiscriminationTrial & key, '*');
            h=waitbar(0);
            for i = 1:length(trials)
                spikes = fetch(ephys.SpikesAlignedTrial & trials(i), 'spikes_aligned');
                trials(i).counts = arrayfun(@(x) sum(x.spikes_aligned > 0 & x.spikes_aligned < 500), spikes);
                waitbar(i/length(trials),h);
            end

            units = [1 2 3 7, ...
                11 13 14 15 17 18 19 21 24 29 30, ...
                41 44 46 47 51 52 53 54 55 56 57 58 61 62 63 64  66 67 68, ...
                73 74 75 80 82 84 85 86 89 91 92 93];

            a_trials = arrayfun(@(x) x.selected_class == 'A', trials);
            counts = cat(2,trials.counts)';                
            
            orientation = [trials.orientation];
            contrast = [trials.contrast];
            
            trials = find(contrast == 0.1);
            decode_ori = (240:0.5:310)';
            f = zeros(length(decode_ori),length(units));
            for i = 1:length(units)
                f(:,i) = gpSmooth(orientation(trials)',counts(trials,units(i)),decode_ori);
            end
            
            f(f(:) < 0) = 0.1;
            
            likelihood = zeros(length(decode_ori),length(trials));
            for i = 1:length(trials)
                observed = repmat(counts(trials(i),units),length(decode_ori),1);
                
                ll = observed .* log(f) - f - gammaln(observed+1);
                ll = sum(ll,2);
                ll = ll - max(ll);
                
                p = exp(ll); p = p / sum(p);
                
                likelihood(:,i) = p;
            end
            
            [answer,idx] = sort(orientation(trials));
            figure;
            imagesc(1:length(trials),decode_ori,likelihood(:,idx));
            set(gca,'CLim',[0 0.3]);
            hold on;
            plot(1:length(trials),answer,'k')
            
            [~,decoded] = max(likelihood,[],1);
            std(orientation(trials)-decode_ori(decoded)')
            
            keyboard
            
            orientations = find(histc([trials.orientation],1:361) > 20);
            for i = 1:length(orientations)
                idx = find(round([trials.orientation]) == orientations(i));
                
                chance(i) = mean(a_trials(idx));
                
                residual(idx,:) = bsxfun(@minus, counts(idx,:), ...
                    mean(counts(idx,:),1));
            end
            
            analyze = ismember(round([trials.orientation]),orientations);
            
            ori = [trials.orientation]'; ori = ori - mean(ori);
            counts1 = [ones(size(counts,1),1) bsxfun(@minus,counts,mean(counts))];
            
            
            [B, FitInfo] = lassoglm(counts1,ori,'normal','CV',10);
            lassoPlot(B,FitInfo,'PlotType','CV')
            b = B(:,FitInfo.IndexMinDeviance);
            
            idx = find(analyze);
            for i = 1:length(idx)
                jdx = setdiff(idx,idx(i));
                b = mnrfit(counts1(jdx,2:end),a_trials(jdx)+1);
                c(idx(i)) = counts1(idx(i),:)*b < 0;
            end
        end
        
        self.insert(tuple);
    end
end
