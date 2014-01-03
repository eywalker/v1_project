%{
v1.ReceptiveFields (computed) # my newest table
-> ephys.Spikes
-> acq.EphysStimulationLink
-> stimulation.StimTrialGroup
-----
rf    : longblob # the receptive field
lags  : longblob # the lags computed at
x_deg : longblob # the x coordinates
y_deg : longblob # the y coordinates
%}

classdef ReceptiveFields < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('v1.ReceptiveFields')
        popRel = ephys.Spikes * (acq.EphysStimulationLink * acq.Stimulation('exp_type="DotMappingExperiment"'));
    end
    
    methods
        function self = ReceptiveFields(varargin)
            self.restrict(varargin)
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            % Mani & AE
            % July-10-2008
            % Apri 23 2013 JC

            tuple = key;

            lags = -200:5:200;

            stim = getStim(acq.Stimulation & key, 'synched');
            spike_times = fetch1(ephys.Spikes & key, 'spike_times');

            % Get the valid trials
            v = [stim.params.trials.validTrial];
            vind = find(v);

            % Get stim params
            stimCenterX = stim.params.constants.stimCenterX;
            stimCenterY = stim.params.constants.stimCenterY;
            dotRangeX = stim.params.constants.dotNumX;
            dotRangeY = stim.params.constants.dotNumY;
            stimFrames = stim.params.constants.stimFrames;
            dotSize = stim.params.constants.dotSize;

            % Get scaling parameters
            pxToDegX = 1 / 65;
            pxToDegY = 1 / 65;
            
            stimCenter = [stimCenterX; stimCenterY];
            dotRange = [dotRangeX dotRangeY];

            dx = (1:dotRangeX); dx = dotSize * (dx - mean(dx));
            dy = (1:dotRangeY); dy = dotSize * (dy - mean(dy));
            tuple.x_deg = ((stimCenterX - stim.params.constants.monitorCenter(1)) + ...
               	dx) * pxToDegX;
            tuple.y_deg = ((stimCenterY - stim.params.constants.monitorCenter(2)) + ...
               	dy) * pxToDegY;
                
            dotColorBright = stim.params.constants.dotColor(2);
            dotColorDark = stim.params.constants.dotColor(1);

            % Get event types
            showStimulusId = find(strcmp(stim.eventTypes, 'showStimulus'));
            clearScreenId = find(strcmp(stim.eventTypes, 'clearScreen'));
            
            %--------------------------------------------------------------------------
            % Walk through each time lag
            for j = 1:length(lags)
                swaps = {};
                spikesByTrial = {};
                locs = {};
                colors = {};
                
                n = 0;
                for i = 1:length(vind)
                    onsetId = find(stim.events(vind(i)).types == showStimulusId);
                    offsetId = find(stim.events(vind(i)).types == clearScreenId, 1, 'first');

                    onset = stim.events(vind(i)).times(onsetId);
                    offset = stim.events(vind(i)).times(offsetId);
                    
                    spikeOnset = onset + lags(j); spikeOffset = offset + lags(j);
                    spikes = spike_times(spike_times > spikeOnset & spike_times < spikeOffset) - lags(j);

                    % Get the trials that had spikes during the stimulus time
                    if ~isempty(spikes)
                        n = n + 1;
                        spikesByTrial{n} = spikes';
                        %             tLoc = stim.params.trials(vind(i)).dotLocations;
                        % Here we expand the locations array and colors array according
                        % to the number of flips each frame was shown.
                        
                        % locs{n} = repmat(tLoc(1:stimFrames),1,stimFrames);
                        %             locs{n} = tLoc(1:stimFrames);
                        locs{n} = stim.params.trials(vind(i)).dotLocations;
                        %             tCols = stim.params.trials(vind(i)).dotColors;
                        %colors{n} = repmat(tCols(1:stimFrames),1,stimFrames);
                        %             colors{n} = tCols(1:stimFrames);
                        colors{n} = stim.params.trials(vind(i)).dotColors;
                        s = stim.params.trials(vind(i)).swapTimes;
                        % Get swap times for the stimulus
                        s = s(s>=onset & s<=offset)';
                        %             swaps{n} = s(1:stimFrames:(stimFrames*stimFrames));
                        N = length(colors{n});
                        swaps{n} = s((0:N-1)*stimFrames+1);
                    end
                end
                %----------------------------------------------------------------------
                % Here we construct the map
                % Collapse the parameters across trials
                allSpikes = [spikesByTrial{:}];
                allSwaps = [swaps{:}];
                allLocs = [locs{:}];
                
                counts = histc(allSpikes,allSwaps);
                spikedFrameInd = find(counts>0);
                
                countsSpiked = counts(spikedFrameInd);
                %     countsSpiked = num2cell(countsSpiked);
                % We need to apply each spike count to all the dots that gave raise
                % to that spike count.
                nDots = cellfun(@(x)size(x,2),allLocs(spikedFrameInd));
                countsSpiked = arrayfun(@(x,n)repmat(x,1,n),countsSpiked,nDots,'UniformOutput',false);
                %     countsSpiked = cellfun(@(x) repmat(x,[1 nDots]),countsSpiked,'UniformOutput',false);
                countsSpiked = [countsSpiked{:}];
                
                spikedLocs = allLocs(spikedFrameInd);
                spikedLocs = [spikedLocs{:}];
                spikedLocs = bsxfun(@plus,bsxfun(@minus,spikedLocs,stimCenter)/dotSize,(dotRange'+1)/2);
                locX = spikedLocs(1,:);
                locY = spikedLocs(2,:);
                
                allCols = [colors{:}];
                spikedColors = allCols(spikedFrameInd);
                
                allCols = [spikedColors{:}];
                allCols = allCols(1,:);
                
                brightInd = find(allCols==dotColorBright);
                darkInd = find(allCols==dotColorDark);
                
                
                % Separate according to dot color
                locXb = locX(brightInd);
                locYb = locY(brightInd);
                
                locXd = locX(darkInd);
                locYd = locY(darkInd);
                
                spikeCountBright = countsSpiked(brightInd);
                spikeCountDark = countsSpiked(darkInd);
                
                subsBright = {locYb locXb};
                subsDark = {locYd locXd};
                
                % Construct the map
                if ~isempty(spikeCountBright)
                    mapBright = accumarray(subsBright,spikeCountBright,fliplr(dotRange));
                else
                    mapBright = zeros(fliplr(dotRange));
                end
                if ~isempty(spikeCountDark)
                    mapDark = accumarray(subsDark,spikeCountDark,fliplr(dotRange));
                else
                    mapDark = zeros(fliplr(dotRange));
                end
                diffB = mapBright - mapDark;
                sumB = mapDark + mapBright;

                w = window(@gausswin,5);
                w = w * w';
                w = w / sum(w(:));
                
                mapBright = imfilter(mapBright-mean(mapBright(:)),w);
                mapDark = imfilter(mapDark-mean(mapDark(:)),w);
                diffB = imfilter(diffB-mean(diffB(:)),w);
                sumB = imfilter(sumB-mean(sumB(:)),w);
                
                %% Output
                res(j).mapBright = mapBright;
                res(j).mapDark = mapDark;
                res(j).range = [stimCenterX + [-1; 1] * dotRangeX / 2 * dotSize, ...
                    stimCenterY + [-1; 1] * dotRangeY / 2 * dotSize];
                
            end
            
            tuple.rf = res;
            tuple.lags = lags;
            self.insert(tuple)
        end
        
        %% subfunction cumputing on- and offset
        function [onset offset] = getonoff(stim,trial)
            types = stim.eventTypes;
            onind = strmatch('showStimulus',types);
            offind = strmatch('clearScreen',types);
            events = stim.events(trial).types;
            onind = events==onind;
            offind = find(events==offind, 1, 'first');
            %offind = offind(1);
            
            onset = stim.events(trial).times(onind);
            offset = stim.events(trial).times(offind);  
        end
    end
    
    methods
        function plot(this)
            dat = fetch(this,'*');
            N = ceil(sqrt(length(dat)));
            
            for i = 1:length(dat)
                idx = find(dat(i).lags == 40);
                subplot(N,N,i);
                imagesc(dat(i).x_deg,dat(i).y_deg,dat(i).rf(idx).mapBright+dat(i).rf(idx).mapDark);
                axis square
            end
        end
    end
end
