% %% prepare stim and eye trace files
% session = fetch(acq.Sessions & 'subject_id = 21' & 'session_datetime like "2015-12-24%"' & acq.Stimulation('exp_type like "ClassDisc%"'));
% stim = getStim(acq.Stimulation & session, 'Synched');
% eyeTrace = getFile(acq.BehaviorTraces & session);
% eyeStartTime = getHardwareStartTime(acq.BehaviorTraces & session);
% eyeTime = eyeStartTime + [0:length(eyeTrace)-1]/2000*1000;

%%
import draw.*;
% prepare stim data
condNum = [stim.params.trials.condition];
condLookup = stim.params.conditions;
conditions = condLookup(condNum);

orientations = {stim.params.trials.trialDirection}; % has to be cell array because some entries will be empty
check = cellfun(@isempty, orientations);
[orientations{check}] = deal(NaN);
orientations = [orientations{:}];

contrasts = [conditions.contrast];
cueClass = [conditions.cueClass]; % cueClass = 2 -> narrow, red, cueClass = 1 -> wide, green. I know, WTF James...
targetSetup = [conditions.targetSetup]; % target setup: 1 = red left green right, 2 = green left red right


constants = stim.params.constants;
width = constants.resolution(1);
height = constants.resolution(2);
xc = constants.monitorCenter(1);
yc = constants.monitorCenter(2);
bgColor = constants.bgColor / 255;
targetRadius = constants.targetDiameter / 2; % radius of target in pixels
targetOffset = constants.targetOffset;
targetAColor = constants.targetAColor / 255; % class A - narrower class - red
targetBColor = [0, 0, 1]; %constants.targetBColor / 255; % class B - wider class - green
fixSpotX = constants.fixSpotLocation(1) + xc;
fixSpotY = constants.fixSpotLocation(2) + yc;
fixSpotRadius = constants.fixSpotSize / 2;
fixSpotColor = constants.fixSpotColor / 255;
stimRadius = constants.diskSize / 2; % radius of the stimulus circle
stimX = xc;%constants.location(1) + xc;
stimY = yc;%constants.location(2) + yc;
spatialFreq = constants.spatialFreq; % radians per pixel
speed = constants.speed; % degrees per second

eyeRadius = 35; % radius of accepted fix distance

eventLookup = stim.eventTypes;

% trial selectors
valid = [stim.params.trials.validTrial] == 1;
correct = [stim.params.trials.correctResponse] == 1;
%find(correct & valid & abs(orientations - 270) < 10 & contrast==4)

%% compute stimulus related timings
stimOffTime = constants.cueTime;
targetOnTime = stimOffTime + constants.targetDelayTime;
targetOffTime = targetOnTime + constants.targetTime;
allowSaccadeTime = targetOnTime + constants.targetTime + constants.targetMemoryTime;

%% prepare screen and necessary parameters

bg = draw.flatImage(width, height, bgColor);

%% Look at only a specific trial

trialNum = 2089;
fps = 120;
showFig = false;
scale = 0.6;
red = (1 - scale)/2;
xl = round([red * width, (1-red) * width]);
yl = round([red * height, (1-red) * height]);

% find out specific event times
events = stim.events(trialNum);
eventNames = eventLookup(events.types);

% get eye calibration params
calib = stim.params.trials(trialNum).eyeParams;

showStimulusTime = events.times(strcmp(eventNames, 'showStimulus'));

% represent others in relative to showStimulusTime
startTrialTime = events.times(strcmp(eventNames, 'startTrial')) - showStimulusTime;
showFixSpotTime = events.times(strcmp(eventNames, 'showFixSpot')) - showStimulusTime;
responseTime = events.times(strcmp(eventNames, 'response')) - showStimulusTime;
endStimulusTime = events.times(strcmp(eventNames, 'endStimulus')) - showStimulusTime;


% get stimulus config
ori = orientations(trialNum);
cont = contrasts(trialNum);
target = targetSetup(trialNum);
cue = cueClass(trialNum);

% movie config

phaseStep = 3 * 2 * pi / 1000; %speed * pi / 180 / 1000; % speed expressed in radians per millisecond
postStim = 1000;

% prepare eye trace
relEyeTime = (eyeTime - showStimulusTime);

%pos = find(relEyeTime > (startTrialTime) & relEyeTime < (endStimulusTime + postStim));

pos = find(relEyeTime > (-50) & relEyeTime < (endStimulusTime + postStim));
posStart = min(pos);
posEnd = max(pos);

steps = round(2000 / fps);
points = posStart:steps:posEnd; % downsample to fps
ts = relEyeTime(points);
vx = eyeTrace(points, 1);
vy = eyeTrace(points, 2);

%calib = [-210, 460, -150, 280];
xs = vx * calib(2) + calib(1);
ys = vy * calib(4) + calib(3);
%figure;plot(ys);hold on;plot(xs,'r');
%%

if showFig
    figure(1);
end
clear M;
for f = 1:length(ts)
    t = ts(f);
    xe = xs(f);
    ye = ys(f);
    im = bg;
    if t < 100000
        
            % show grating stimulus
            if t >= 0 & t < stimOffTime
                grating = draw.drawGratings(width, height, stimX, stimY, (ori - 90) * pi / 180, spatialFreq /(2*pi), t * phaseStep);
                % apply contrast scaling to grating
                grating = min(1, cont/100)*(grating - 0.5) + 0.5;

                mask = draw.circularMask(width, height, stimX, stimY, stimRadius) .* draw.gaussianMask(width, height, stimX, stimY, 0.6*stimRadius);
                im = draw.overlayImagesWithAlpha(im, grating, mask);
            end

            % show saccade targets
            if t >= 0 & t < targetOffTime
                % target setup: 2 = red left green right, 1 = green left red right
                if target == 2
                    leftColor = targetAColor;
                    rightColor = targetBColor;
                else
                    leftColor = targetBColor;
                    rightColor = targetAColor;
                end
                im = draw.drawCircle(im, fixSpotX - targetOffset, fixSpotY, targetRadius, leftColor);
                im = draw.drawCircle(im, fixSpotX + targetOffset, fixSpotY, targetRadius, rightColor);
            end
            
            if t >= 1500
                if cue == target
                    offset = -targetOffset;
                else
                    offset = targetOffset;
                end
                inner = draw.circularMask(width, height, fixSpotX + offset, fixSpotY, targetRadius * 1.4);
                outer = draw.circularMask(width, height, fixSpotX + offset, fixSpotY, targetRadius * 1.7);
                rim = outer .* (1 - inner);
                clr = draw.flatImage(width, height, [1,1,1]);
                im = draw.overlayImagesWithAlpha(im, clr, rim);
            end
%             
%             if t > showFixSpotTime & t < allowSaccadeTime
%                 % draw fixation spot
%                 im = draw.drawCircle(im, fixSpotX, fixSpotY, fixSpotRadius, fixSpotColor);
%             end
        end
        % drawing eye trace
        %im = draw.drawCircle(im, xe + xc, ye + yc, eyeRadius, 1, 0.3);
        if scale < 1
            im = im(yl(1)+1:yl(2),xl(1)+1:xl(2),:);
        end
   
    M(f) = im2frame(im);
    if showFig
        imshow(im);
    end
        
end

%%
%fileName = input('Enter file name: ', 's')
fileName = sprintf('trial_%d', trialNum);
writer = VideoWriter(['movies/' fileName '.mp4'], 'MPEG-4');
%%
writer.FrameRate = fps/2;
writer.open();
writer.writeVideo(M);
writer.close();