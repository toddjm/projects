% Script used to process data from Limb Elevation characterization study
%
% P. Silveira, Dec. 2015
% BSX Proprietary

%% Initialization

clear all
close all

SWEEP_SUFFIX = '_sweep.mat';    % suffix of .mat files with sweep structure
PAUSE_BIT = 6;  % Alert bit used to indicate data collection pause.
EVENTS_CALF = {'Standing' 'Sitting' 'Supine' 'Legs up' 'Standing' 'End'};
EVENTS_CALF_TIMES = [0 120 240 360 480 600];
EVENTS_THENAR = {'Heart level' 'Arms up' 'Arms dropped' 'Heart level' 'End'};
EVENTS_THENAR_TIMES = [0 120 240 360 480];
CALF_BL = 5;    % baseline event number
THENAR_BL = 4;
THB_FILTER_LENGTH = 15; % length of tHb filter (samples)
USERPATH = getenv('USERPROFILE');
inpath = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\tHb\Limb elevations\'];
inpath = uigetdir(inpath, 'Select Trial to be processed');
inpath = [inpath '\'];
temp = strfind(inpath, 'Trial');
trialNum = inpath(temp+5:temp+6);   % get trial number string
fprintf('Trial # %s\n', trialNum)
TIME_WINDOW = 10;   % time window to avoid between events (s)
PERC_EXCL = 10;     % percentage of data to be excluded from trimmean

%% File input

moxyfile = dir([inpath '*Moxy*.csv']);

if ~isempty(moxyfile)            
    moxy = getMoxy([inpath moxyfile.name]);
    % If the moxy structure has more than numSteps, assume that initial steps are invalid
    moxyLen = length(moxy);
    if moxyLen > 2
        warning([num2str(moxyLen) ' moxy laps found. Assuming first moxy laps to be invalid!'])
        moxy = moxy(end-1:end);
    end
end

sweepFile = [inpath 'InsightThenar' SWEEP_SUFFIX];    % check whether sweep file already exists
if exist(sweepFile, 'file')
    load(sweepFile);
    sweep_thenar = sweep;
else
    sweep_thenar = getSweep([inpath 'InsightThenar.optical']);
end
sweepFile = [inpath 'InsightCalf' SWEEP_SUFFIX];    % check whether sweep file already exists
if exist(sweepFile, 'file')
    load(sweepFile);
    sweep_calf = sweep;
else
    sweep_calf = getSweep([inpath 'InsightCalf.optical']);
end

%% Data processing and analysis

[thenar.SmO2.array, thenar.HbF] = sweep2SmO2(sweep_thenar);
[calf.SmO2.array, calf.HbF] = sweep2SmO2(sweep_calf);
[thenar.tHb.array] = calc_tHb(thenar.HbF, THB_FILTER_LENGTH);
[calf.tHb.array] = calc_tHb(calf.HbF, THB_FILTER_LENGTH);

%if any(strcmp(trialNum, TRIAL_EXCEPTION))    % check whether this is one of the trials in exception list
pauseTimeThenar = sweep_thenar.time(end) - EVENTS_THENAR_TIMES(end);    % count time backwards from last event
pauseTimeCalf = sweep_calf.time(end) - EVENTS_CALF_TIMES(end);    % count time backwards from last event
% else    % use pause bit
%     ln = numel(sweep_thenar.time);
%     temp = findPauseEnd(sweep_thenar.Alert(round(ln/3):round(3*ln/4),PAUSE_BIT));
%     pauseTimeThenar = (temp + round(ln/3)-1)/sweep_thenar.samp_rate;
%     ln = numel(sweep_calf.time);
%     temp = findPauseEnd(sweep_calf.Alert(round(ln/3):round(3*ln/4),PAUSE_BIT));
%     pauseTimeCalf = (temp + round(ln/3)-1)/sweep_calf.samp_rate;
% end

% Find plateaus and calculate transitions and baseline differences
[thenar.tHb.transition, thenar.tHb.plateau] = transition(thenar.tHb.array, [EVENTS_THENAR_TIMES EVENTS_THENAR_TIMES+pauseTimeThenar], sweep_thenar.time, TIME_WINDOW, PERC_EXCL);
[thenar.SmO2.transition, thenar.SmO2.plateau] = transition(thenar.SmO2.array, [EVENTS_THENAR_TIMES EVENTS_THENAR_TIMES+pauseTimeThenar], sweep_thenar.time, TIME_WINDOW, PERC_EXCL);
% thenar.SmO2.BLdiff(1) = thenar.SmO2.plateau(THENAR_BL) - thenar.SmO2.plateau(1);
% thenar.SmO2.BLdiff(2) = thenar.SmO2.plateau(end) - thenar.SmO2.plateau(end-THENAR_BL+1);
% thenar.tHb.BLdiff(1) = thenar.tHb.plateau(THENAR_BL) - thenar.tHb.plateau(1);
% thenar.tHb.BLdiff(2) = thenar.tHb.plateau(end) - thenar.tHb.plateau(end-THENAR_BL+1);

[calf.tHb.transition, calf.tHb.plateau] = transition(calf.tHb.array, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], sweep_calf.time, TIME_WINDOW, PERC_EXCL);
[calf.SmO2.transition, calf.SmO2.plateau] = transition(calf.SmO2.array, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], sweep_calf.time, TIME_WINDOW, PERC_EXCL);
% calf.tHb.BLdiff(1) = calf.tHb.plateau(CALF_BL) - calf.tHb.plateau(1);
% calf.tHb.BLdiff(2) = calf.tHb.plateau(end) - calf.tHb.plateau(end-CALF_BL+1);
% calf.SmO2.BLdiff(1) = calf.SmO2.plateau(CALF_BL) - calf.SmO2.plateau(1);
% calf.SmO2.BLdiff(2) = calf.SmO2.plateau(end) - calf.SmO2.plateau(end-CALF_BL+1);

if exist('moxy', 'var')
    [moxyCalf.tHb.transition, moxyCalf.tHb.plateau] = transition(moxy(1).THb, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], moxy(1).time, TIME_WINDOW, PERC_EXCL);
    [moxyCalf.SmO2.transition, moxyCalf.SmO2.plateau] = transition(moxy(1).SmO2Avg, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], moxy(1).time, TIME_WINDOW, PERC_EXCL);
    [moxyThenar.tHb.transition, moxyThenar.tHb.plateau] = transition(moxy(2).THb, [EVENTS_THENAR_TIMES EVENTS_THENAR_TIMES+pauseTimeThenar], moxy(2).time, TIME_WINDOW, PERC_EXCL);
    [moxyThenar.SmO2.transition, moxyThenar.SmO2.plateau] = transition(moxy(2).SmO2Avg, [EVENTS_THENAR_TIMES EVENTS_THENAR_TIMES+pauseTimeThenar], moxy(2).time, TIME_WINDOW, PERC_EXCL);
else
    moxyThenar.tHb.plateau = NaN*ones(size(thenar.tHb.plateau));
    moxyCalf.tHb.plateau = NaN*ones(size(calf.tHb.plateau));
    moxyThenar.SmO2.plateau = NaN*ones(size(thenar.SmO2.plateau));
    moxyCalf.SmO2.plateau = NaN*ones(size(calf.SmO2.plateau));
end
% moxyCalf.tHb.BLdiff(1) = moxyCalf.tHb.plateau(CALF_BL) - moxyCalf.tHb.plateau(1);
% moxyCalf.tHb.BLdiff(2) = moxyCalf.tHb.plateau(end) - moxyCalf.tHb.plateau(end-CALF_BL+1);
% moxyCalf.SmO2.BLdiff(1) = moxyCalf.SmO2.plateau(CALF_BL) - moxyCalf.SmO2.plateau(1);
% moxyCalf.SmO2.BLdiff(2) = moxyCalf.SmO2.plateau(end) - moxyCalf.SmO2.plateau(end-CALF_BL+1);
% moxyThenar.tHb.BLdiff(1) = moxyThenar.tHb.plateau(THENAR_BL) - moxyThenar.tHb.plateau(1);
% moxyThenar.tHb.BLdiff(2) = moxyThenar.tHb.plateau(end) - moxyThenar.tHb.plateau(end-THENAR_BL+1);
% moxyThenar.SmO2.BLdiff(1) = moxyThenar.SmO2.plateau(THENAR_BL) - moxyThenar.SmO2.plateau(1);
% moxyThenar.SmO2.BLdiff(2) = moxyThenar.SmO2.plateau(end) - moxyThenar.SmO2.plateau(end-THENAR_BL+1);

%% Plot results

figure(1)
set(gcf, 'Position', [ 2        -188         958        1052])
subplot(2,1,1)
plot(sweep_thenar.time, thenar.tHb.array, 'r')
if exist('moxy', 'var')
    hold on
    plot(moxy(2).time, moxy(2).THb, 'k')
    legend('Insight', 'Comparative', 'Location', 'Best')
end
grid
xlabel('time (s)')
ylabel('tHb (g/dL)')
axis tight
title(['Trial #' trialNum ' - Thenar data'])
hold off
for ii = 1:length(thenar.tHb.transition)
end
showEvents(EVENTS_THENAR, EVENTS_THENAR_TIMES, [thenar.tHb.plateau(1:THENAR_BL+1) ; moxyThenar.tHb.plateau(1:THENAR_BL+1)]);
showEvents(EVENTS_THENAR, EVENTS_THENAR_TIMES+pauseTimeThenar, [thenar.tHb.plateau(end-THENAR_BL+1:end) NaN ; moxyThenar.tHb.plateau(end-THENAR_BL+1:end) NaN]); % pad last plateau with NaN

subplot(2,1,2)
plot(sweep_thenar.time, thenar.SmO2.array, 'r')
if exist('moxy', 'var')
    hold on
    plot(moxy(2).time, moxy(2).SmO2Avg, 'k')
    legend('Insight', 'Comparative', 'Location', 'Best')
end
grid
xlabel('time (s)')
ylabel('SmO2 (%)')
axis tight
hold off
showEvents(EVENTS_THENAR, EVENTS_THENAR_TIMES, [thenar.SmO2.plateau(1:THENAR_BL+1) ; moxyThenar.SmO2.plateau(1:THENAR_BL+1)]);
showEvents(EVENTS_THENAR, EVENTS_THENAR_TIMES+pauseTimeThenar, [thenar.SmO2.plateau(end-THENAR_BL+1:end) NaN ; moxyThenar.SmO2.plateau(end-THENAR_BL+1:end) NaN]); % pad last plateau with NaN);

figure(2)
set(gcf, 'Position', [962        -188         958        1052])
subplot(2,1,1)
plot(sweep_calf.time, calf.tHb.array, 'r')
if exist('moxy', 'var')
    hold on
    plot(moxy(1).time, moxy(1).THb, 'k')
    legend('Insight', 'Comparative', 'Location', 'Best')
end
grid
xlabel('time (s)')
ylabel('tHb (g/dL)')
axis tight
title(['Trial #' trialNum ' - Calf data'])
hold off
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES, [calf.tHb.plateau(1:CALF_BL+1) ; moxyCalf.tHb.plateau(1:CALF_BL+1)]);
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES+pauseTimeCalf, [calf.tHb.plateau(end-CALF_BL+1:end) NaN ; moxyCalf.tHb.plateau(end-CALF_BL+1:end) NaN]); % pad last plateau with NaN);

subplot(2,1,2)
plot(sweep_calf.time, calf.SmO2.array, 'r')
if exist('moxy', 'var')
    hold on
    plot(moxy(1).time, moxy(1).SmO2Avg, 'k')
    legend('Insight', 'Comparative', 'Location', 'Best')
end
grid
xlabel('time (s)')
ylabel('SmO2 (%)')
axis tight; ax = axis;
hold off
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES, [calf.SmO2.plateau(1:CALF_BL+1) ; moxyCalf.SmO2.plateau(1:CALF_BL+1)]);
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES+pauseTimeCalf, [calf.SmO2.plateau(end-CALF_BL+1:end) NaN ; moxyCalf.SmO2.plateau(end-CALF_BL+1:end) NaN]); % pad last plateau with NaN);

calf_plateaus = table(calf.tHb.plateau', moxyCalf.tHb.plateau', calf.SmO2.plateau', moxyCalf.SmO2.plateau', 'VariableNames', {'BSX_tHb', 'Comp_tHb', 'BSX_SmO2', 'Comp_SmO2'})
thenar_plateaus = table(thenar.tHb.plateau', moxyThenar.tHb.plateau', thenar.SmO2.plateau', moxyThenar.SmO2.plateau', 'VariableNames', {'BSX_tHb', 'BSX_SmO2', 'Comp_tHb', 'Comp_SmO2'})

%% Wrapup

temp = questdlg('Save output to PNG file?');
if strcmp(temp, 'Yes')
    figure(1)
    print([inpath 'Trial' trialNum 'Thenar.png'],'-dpng')   % save plot
    figure(2)
    print([inpath 'Trial' trialNum 'Calf.png'],'-dpng')   % save plot
    fprintf('Plots saved to folder %s\n', inpath) 
end





