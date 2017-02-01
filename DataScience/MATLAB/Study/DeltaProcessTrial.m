% Script used to process data from Delta SmO2 characterization study
%
% P. Silveira, Oct. 2015
% BSX Proprietary

%% Initialization

clear all
close all

SWEEP_SUFFIX = '_sweep.mat';    % suffix of .mat files with sweep structure
BASELINE_RANGE = [30,50];   % baseline range (seconds)
UPDATE_RATE = 1;    % update rate (Hz)
USERPATH = getenv('USERPROFILE');
inpath = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Delta SmO2 characterization\'];
inpath = uigetdir(inpath, 'Select Trial to be processed');
inpath = [inpath '\'];
temp = strfind(inpath, 'Trial');
trialNum = inpath(temp+5:temp+6);   % get trial number string
MOXY_NO_DELAY = {'01' '02' '03' '04' '07' '10' '13'};   % list of trials in which Moxy had no delay.
MOXY_DELAY = 30;    % moxy delay (seconds)
%trialNum = sprintf('%02d',temp);

%% File input

moxyfile = dir([inpath '*Moxy*.csv']);
moxy = getMoxy([inpath moxyfile.name]);

insightFile = dir([inpath '*Insight*.bin']);
[temp fname temp] = fileparts(insightFile.name);
sweepFile = [inpath fname SWEEP_SUFFIX];    % check whether sweep file already exists
if exist(sweepFile, 'file')
    load(sweepFile);
else
    sweep = getSweep([inpath insightFile.name]);
end

%% Data processing and analysis

% If the moxy structure has more than numSteps, assume that initial steps are invalid
moxyLen = length(moxy);
if moxyLen > 1
    warning([num2str(moxyLen) ' moxy laps found. Assuming first moxy laps to be invalid!'])
    moxy = moxy(end);
end

if ~any(strcmp(trialNum, MOXY_NO_DELAY))    % find trials that included moxy delayed start
    moxy = subStruct(moxy, findRange(moxy.time, MOXY_DELAY, 'end'));    % extract data captured before trial start
    moxy.time = moxy.time - MOXY_DELAY;     % reset time to zero
end

figure
set(gcf, 'Position', [962        -188         958        1052])
if ~exist('device', 'var')
    device = getDevice(sweep.device_id);    % get device data
end
insight.SmO2 = sweep.SmO2;
insight.SmO2(sweep.SmO2>100) = NaN;     % replace 102.3 and 102.2 with NaNs
%insight.SmO2 = sweep2SmO2(sweep);
insight.time = sweep.time;
insightRange = findRange(insight.time, BASELINE_RANGE);
out = baselineStats(insight.SmO2, insightRange); % use this until device-calculated SmO2 gets corrected
stat.insight.SmO2BL = out.baseline;
stat.insight.SmO2Avg = out.average;
stat.insight.SmO2std = single(out.std);
stat.insight.SmO2med = out.median;
stat.insight.SmO2min = out.min;
stat.insight.SmO2max = out.max;
stat.insight.SmO2pc1 = out.min_prctile;
stat.insight.SmO2pc99 = out.max_prctile;
out = baselineStats(sweep.HR, BASELINE_RANGE);
stat.insight.HRBL = out.baseline;
stat.insight.HRmax = out.max;
stat.insight.HRmin = out.min;
out = baselineStats(sweep.PacePower, BASELINE_RANGE);
stat.insight.Power99 = out.max_prctile;
[temp, temp2] = min(insight.SmO2(insightRange(1):end));   % find minimum position
stat.insight.minTime = insight.time(temp2) + BASELINE_RANGE(1);
[temp, temp2] = max(insight.SmO2(insightRange(1):end));   % find maximum position
stat.insight.maxTime = insight.time(temp2) + BASELINE_RANGE(1);
moxyRange = findRange(moxy.time, BASELINE_RANGE);
out = baselineStats(moxy.SmO2Avg, moxyRange);
stat.moxy.SmO2BL = out.baseline;
stat.moxy.SmO2Avg = out.average;
stat.moxy.SmO2std = single(out.std);
stat.moxy.SmO2med = out.median;
stat.moxy.SmO2min = out.min;
stat.moxy.SmO2max = out.max;
stat.moxy.SmO2pc1 = out.min_prctile;
stat.moxy.SmO2pc99 = out.max_prctile;
[temp, temp2] = min(moxy.SmO2Avg(moxyRange(1):end));   % find minimum position
stat.moxy.minTime = moxy.time(temp2) + BASELINE_RANGE(1);
[temp, temp2] = max(moxy.SmO2Avg(moxyRange(1):end));   % find maximum position
stat.moxy.maxTime = moxy.time(temp2) + BASELINE_RANGE(1);

%% Display results

fprintf('Insight filename = %s. Moxy filename = %s\nDevice = %s. FW = %s\n\n',insightFile.name, moxyfile.name, sweep.device_id, sweep.FW_version)
insight_table = struct2table(stat.insight)
moxy_table = struct2table(stat.moxy)

subplot(3,1,1)
plot(insight.time, insight.SmO2, 'k')
grid
axis ([0 insight.time(end) stat.insight.SmO2min stat.insight.SmO2max])
xlabel('time (s)')
ylabel('SmO_{2} (%)')
title(['Insight Delta SmO_{2} - Trial ' trialNum], 'FontSize', 10)
line([BASELINE_RANGE(1) BASELINE_RANGE(end)],[stat.insight.SmO2BL stat.insight.SmO2BL ],'Color', [1 0 0], 'LineStyle', '--', 'LineWidth', 2)
line([stat.insight.minTime stat.insight.minTime],[stat.insight.SmO2BL stat.insight.SmO2min ],'Color', [0 1 0], 'LineStyle', '--', 'LineWidth', 2)
line([stat.insight.maxTime stat.insight.maxTime],[stat.insight.SmO2BL stat.insight.SmO2max ],'Color', [0 0 1], 'LineStyle', '--', 'LineWidth', 2)
h = legend('SmO2', ['Baseline = ' num2str(stat.insight.SmO2BL)], ['Min = ' num2str(stat.insight.SmO2min)], ['Max = ' num2str(stat.insight.SmO2max)]);
set(h, 'FontSize', 7, 'Location', 'SouthEast');
subplot(3,1,2)
plot(moxy.time, moxy.SmO2Avg, 'k')
grid
axis ([0 moxy.time(end) stat.moxy.SmO2min stat.moxy.SmO2max])
%axis ([moxy.time(1) moxy.time(end) ...
%    max([min(double(moxy.SmO2Avg)) double(stat.moxy.SmO2.min)*.97]) ...
%    min([max(double(moxy.SmO2Avg)) double(stat.moxy.SmO2.max)*1.1])])
xlabel('time (s)')
ylabel('SmO_{2} (%)')
title(['Moxy Delta SmO_{2} - Trial ' trialNum], 'FontSize', 10)
line([BASELINE_RANGE(1) BASELINE_RANGE(end)],[stat.moxy.SmO2BL stat.moxy.SmO2BL ],'Color', [1 0 0], 'LineStyle', '--', 'LineWidth', 2)
line([stat.moxy.minTime stat.moxy.minTime],[stat.moxy.SmO2BL stat.moxy.SmO2min ],'Color', [0 1 0], 'LineStyle', '--', 'LineWidth', 2)
line([stat.moxy.maxTime stat.moxy.maxTime],[stat.moxy.SmO2BL stat.moxy.SmO2max ],'Color', [0 0 1], 'LineStyle', '--', 'LineWidth', 2)
h = legend('SmO2', ['Baseline = ' num2str(stat.moxy.SmO2BL)], ['Min = ' num2str(stat.moxy.SmO2min)], ['Max = ' num2str(stat.moxy.SmO2max)]);
set(h, 'FontSize', 7, 'Location', 'SouthEast');
%line(moxy.time(1)+[BASELINE_RANGE(1) BASELINE_RANGE(end)],[stat.moxy.SmO2.baseline stat.moxy.SmO2.baseline ],'Color', [1 0 0], 'LineStyle', '--', 'LineWidth', 2)
%line(moxy.time(1)+[BASELINE_RANGE(1)+BASELINE_RANGE(end) BASELINE_RANGE(1)+BASELINE_RANGE(end)]/2,[stat.moxy.SmO2.min stat.moxy.SmO2.max ],'Color', [0 1 0], 'LineStyle', '--', 'LineWidth', 2)
%legend('SmO2', ['Baseline = ' num2str(stat.moxy.SmO2.baseline)], ['Delta = ' num2str(stat.moxy.SmO2.delta)], 'Location', 'Best')
subplot(3,1,3)
plot(sweep.time, sweep.PacePower, 'k')
hold on
plot(sweep.time, sweep.HR, 'r')
hold off
%[hAx,hLine1,hLine2] = plotyy(sweep.time, sweep.PacePower, sweep.time, sweep.HR)
grid; axis tight
xlabel('time (s)')
ylabel('Power (W) / HR (bpm)')
h = legend('Power', 'HR');
set(h, 'FontSize', 7, 'Location', 'Best');
%ylabel(hAx(1), 'Power (W)')
%ylabel(hAx(2), 'HR (bpm)')
title(['Power and HR - Trial ' trialNum], 'FontSize', 10)
%set(hAx(1), 'XLim', [0 sweep.time(end)], 'YLim', [0 480]);
%set(hAx(2), 'XLim', [0 sweep.time(end)]);
%line([BASELINE_RANGE(1) BASELINE_RANGE(end)],[stat.insight.HR.baseline stat.insight.HR.baseline ],'Color', [1 0 0], 'LineStyle', '--', 'LineWidth', 2)

%% Cleanup

% Save plot and sweep file
[temp, fname, temp2] = fileparts(insightFile.name);
temp = questdlg('Save output to PNG file?');
if strcmp(temp, 'Yes')
    print([inpath 'Trial' trialNum '.png'],'-dpng')   % save plot
end
if ~exist(sweepFile, 'file')
    save(sweepFile, 'sweep', 'device');
end




