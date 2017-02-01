% Script used to process data from Limb Elevation characterization study
%
% P. Silveira, Dec. 2015
% BSX Proprietary

%% Initialization

clear
close all

SWEEP_SUFFIX = '_sweep.mat';    % suffix of .mat files with sweep structure
PAUSE_BIT = 6;  % Alert bit used to indicate data collection pause.
EVENTS_CALF = {'Standing' 'Supine' 'Standing' 'Supine' 'Standing' 'End'};
EVENTS_CALF_TIMES_EXCEPTION = [0 180 360 540 720 900]; % used in the first 3 trials
EVENTS_CALF_TIMES = [0 240 480 720 960 1200];
TRIAL_EXCEPTION = {'01' '02' '03'}; % list of trials with different times
% CALF_BL = 5;    % baseline event number
THB_FILTER_LENGTH = 15; % length of tHb filter (samples)
USERPATH = getenv('USERPROFILE');
inpath = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\tHb\Calf elevation\'];
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
    if moxyLen > 1
        warning([num2str(moxyLen) ' moxy laps found. Assuming first moxy laps to be invalid!'])
        moxy = moxy(end);
    end
end

sweepFile = [inpath 'InsightCalf' SWEEP_SUFFIX];    % check whether sweep file already exists
if exist(sweepFile, 'file')
    load(sweepFile);
%    sweep_calf = sweep;
else
    sweep = getSweep([inpath 'InsightCalf.optical']);
end

%% Data processing and analysis

if any(strcmp(trialNum, TRIAL_EXCEPTION))   % change event timing during trials that are part of exception list
    EVENTS_CALF_TIMES = EVENTS_CALF_TIMES_EXCEPTION;
end

[calf.SmO2.array, calf.HbF] = sweep2SmO2(sweep);
[calf.tHb.array] = calc_tHb(calf.HbF, THB_FILTER_LENGTH);

%pauseTimeCalf = sweep.time(end) - EVENTS_CALF_TIMES(end);    % count time backwards from last event

% Find plateaus and calculate transitions and baseline differences
%[calf.tHb.transition, calf.tHb.plateau] = transition(calf.tHb.array, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], sweep.time, TIME_WINDOW, PERC_EXCL);
%[calf.SmO2.transition, calf.SmO2.plateau] = transition(calf.SmO2.array, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], sweep.time, TIME_WINDOW, PERC_EXCL);
[calf.tHb.transition, calf.tHb.plateau] = transition(calf.tHb.array, EVENTS_CALF_TIMES, sweep.time, TIME_WINDOW, PERC_EXCL);
[calf.SmO2.transition, calf.SmO2.plateau] = transition(calf.SmO2.array, EVENTS_CALF_TIMES, sweep.time, TIME_WINDOW, PERC_EXCL);

if exist('moxy', 'var')
%    [moxyCalf.tHb.transition, moxyCalf.tHb.plateau] = transition(moxy(1).THb, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], moxy(1).time, TIME_WINDOW, PERC_EXCL);
%    [moxyCalf.SmO2.transition, moxyCalf.SmO2.plateau] = transition(moxy(1).SmO2Avg, [EVENTS_CALF_TIMES EVENTS_CALF_TIMES+pauseTimeCalf], moxy(1).time, TIME_WINDOW, PERC_EXCL);
    [moxyCalf.tHb.transition, moxyCalf.tHb.plateau] = transition(moxy(1).THb, EVENTS_CALF_TIMES, moxy(1).time, TIME_WINDOW, PERC_EXCL);
    [moxyCalf.SmO2.transition, moxyCalf.SmO2.plateau] = transition(moxy(1).SmO2Avg, EVENTS_CALF_TIMES, moxy(1).time, TIME_WINDOW, PERC_EXCL);
else
    moxyCalf.tHb.plateau = NaN*ones(size(calf.tHb.plateau));
    moxyCalf.SmO2.plateau = NaN*ones(size(calf.SmO2.plateau));
end

% Calculate heme concentrations
[HbO2, Hhb] = calc_hemes(calf.SmO2.array, calf.tHb.array);
[moxy.HbO2, moxy.Hhb] = calc_hemes(moxy.SmO2Avg, moxy.THb);

%% Plot results

figure(1)
set(gcf, 'Position', [962        -188         958        1052])
subplot(2,1,1)
plot(sweep.time, calf.tHb.array, 'r')
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
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES, [calf.tHb.plateau ; moxyCalf.tHb.plateau]);
%showEvents(EVENTS_CALF, EVENTS_CALF_TIMES+pauseTimeCalf, [calf.tHb.plateau(end-CALF_BL+1:end) NaN ; moxyCalf.tHb.plateau(end-CALF_BL+1:end) NaN]); % pad last plateau with NaN);

subplot(2,1,2)
plot(sweep.time, sweep.SmO2, 'r')
if exist('moxy', 'var')
    hold on
    plot(moxy(1).time, moxy(1).SmO2Avg, 'k')
    legend('Insight', 'Comparative', 'Location', 'Best')
end
grid
xlabel('time (s)')
ylabel('SmO2 (%)')
axis tight
hold off
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES, [calf.SmO2.plateau ; moxyCalf.SmO2.plateau]);
%showEvents(EVENTS_CALF, EVENTS_CALF_TIMES+pauseTimeCalf, [calf.SmO2.plateau(end-CALF_BL+1:end) NaN ; moxyCalf.SmO2.plateau(end-CALF_BL+1:end) NaN]); % pad last plateau with NaN);

figure(2)
set(gcf, 'Position', [962        -188         958        1052])
subplot(2,1,1)
plot(sweep.time, HbO2, 'b')
hold on
plot(sweep.time, Hhb, 'r')
grid
xlabel('time (s)')
ylabel('Concentration (mmol/L)')
axis tight
title(['Trial #' trialNum ' - BSXInsight'])
hold off
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES);
legend('HbO2', 'Hhb', 'Location', 'Best')
subplot(2,1,2)
plot(moxy.time, moxy.HbO2, 'b')
hold on
plot(moxy.time, moxy.Hhb, 'r')
grid
xlabel('time (s)')
ylabel('Concentration (mmol/L)')
axis tight
title(['Trial #' trialNum ' - Comparative'])
hold off
showEvents(EVENTS_CALF, EVENTS_CALF_TIMES);
legend('HbO2', 'Hhb', 'Location', 'Best')

calf_plateaus = table(calf.tHb.plateau', moxyCalf.tHb.plateau', calf.SmO2.plateau', moxyCalf.SmO2.plateau', 'VariableNames', {'BSX_tHb', 'Comp_tHb', 'BSX_SmO2', 'Comp_SmO2'})
%thenar_plateaus = table(thenar.tHb.plateau', moxyThenar.tHb.plateau', thenar.SmO2.plateau', moxyThenar.SmO2.plateau', 'VariableNames', {'BSX_tHb', 'BSX_SmO2', 'Comp_tHb', 'Comp_SmO2'})

max(calf.tHb.array(100:end-100)) - min(calf.tHb.array(100:end-100))
max(moxy.THb(10:end-10)) - min(moxy.THb(10:end-10))

%% Wrapup

temp = questdlg('Save output to PNG file?');
if strcmp(temp, 'Yes')
    figure(1)
    print([inpath 'Trial' trialNum 'Calf.png'],'-dpng')   % save plot
    figure(2)
    print([inpath 'Trial' trialNum 'Hemes.png'],'-dpng')   % save plot
    fprintf('Plots saved to folder %s\n', inpath) 
end





