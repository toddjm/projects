% Script used to process data from Baseline characterization study
%
% P. Silveira, Sep. 2015

%% Initialization

clear all
close all

trialNum = '01';    % trial being processed
SWEEP_SUFFIX = '_sweep.mat';    % suffix of .mat files with sweep structure
BASELINE_RANGE = [30,70];   % baseline range (seconds)
UPDATE_RATE = 1;    % update rate (Hz)
temp = questdlg('Save output to PNG file?');
PLOT_SAVE = strcmp(temp, 'Yes');    % save to pdf flag
USERPATH = getenv('USERPROFILE');
inpath = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Baseline characterization\'];
inpath = uigetdir(inpath, 'Select Trial to be processed');
inpath = [inpath '\'];
temp = strfind(inpath, 'Trial');
trialNum = inpath(temp+5:temp+6);   % get trial number string

%% File input

moxyfile = dir([inpath '*Moxy*.csv']);
if ~isempty(moxyfile)
    moxy = getMoxy([inpath moxyfile.name]);
end

insightFiles = dir([inpath '*nsight*.csv']);
numSteps = length(insightFiles);    % number of steps in trial
for ii = 1:numSteps
    [temp fname temp] = fileparts(insightFiles(ii).name);
    sweepFile = [inpath fname SWEEP_SUFFIX];    % check whether sweep file already exists
    if exist(sweepFile, 'file')
        load(sweepFile);
        sweepMat(ii) = sweep;
    else
        sweepMat(ii) = getSweep([inpath insightFiles(ii).name]);
    end
end

%% Data processing and analysis

if ~exist('moxy', 'var')    % only insight files are available. Use a "mock" moxy structure!
   for ii = 1:numSteps
    moxy(ii).SmO2Avg = NaN;
    moxy(ii).time = NaN;
   end
end

% If the moxy structure has more than numSteps, assume that initial steps are invalid
moxyLen = length(moxy);
if moxyLen > numSteps
    warning([num2str(moxyLen) ' moxy steps found versus ' num2str(numSteps) ' Insight files. Assuming first moxy steps to be invalid!'])
    moxy(1:numSteps) = moxy(end-numSteps+1:end);
end
if moxyLen < numSteps   % too few moxy steps. Something is wrong.
    warning([num2str(moxyLen) ' moxy steps found versus ' num2str(numSteps) ' Insight files.'])
end

figure
old_device_id = sweepMat(1).device_id;
device = getDevice(sweepMat(1).device_id);    % get device data
%device_id = '';
set(gcf, 'Position', [488 159 560 699])
for ii = 1:numSteps
    if ~strcmpi(sweepMat(ii).device_id, old_device_id)  % make sure they match
        warning(['Device ids do not match! Previous device = ' old_device_id '. New device = ' sweeMat(ii).device_id])
        device = getDevice(sweepMat(ii).device_id);
    end
    old_device_id = sweepMat(ii).device_id;
    %    [AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent device calibration data
    %    [OD15, OD27] = processCounts(sweepMat(ii), AllCnt, lookup_current);
    %    [rawSmO2, Resid, mu_eff, HbF, Pk] = calc_SmO2(OD27-OD15);
    %    insight.SmO2 = processSmO2(rawSmO2);   % post-process
    %    insight.SmO2 = insight.SmO2(1:sweepMat(ii).samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
    insight.SmO2 =  sweepMat(ii).SmO2(1:sweepMat(ii).samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
    insight.HbF = sweepMat(ii).cHHb_SmO2 + sweepMat(ii).cHHb_SmO2;
    insight.HbConc = 5e4 * insight.HbF ./ sweepMat(ii).cH2O_SmO2;
    insight.time = linspace(sweepMat(ii).time(1), sweepMat(ii).time(end), length(insight.SmO2));    % decimated time
    insightRange = findRange(insight.time, BASELINE_RANGE);
    sweepRange = findRange(sweepMat(ii).time, BASELINE_RANGE);
    subplot(2,1,1)
    if ~isempty(insightRange)  % deal with empty ranges
        stat.insight.SmO2(ii) = baselineStats(insight.SmO2(1:insightRange(end)), insightRange);
        stat.insight.HbF(ii) = baselineStats(insight.HbF(1:sweepRange(end)), sweepRange);
        stat.insight.HbConc(ii) = baselineStats(insight.HbConc(1:sweepRange(end)), sweepRange);
        plot(insight.time, insight.SmO2, 'k')
        grid
        axis ([0 insight.time(end) max([min(insight.SmO2) stat.insight.SmO2(ii).min*.97]) min([100 stat.insight.SmO2(ii).max*1.03])])
        xlabel('time (s)')
        ylabel('SmO_{2} (%)')
        title(['Insight baseline Trial ' trialNum ', step ' num2str(ii)], 'FontSize', 12)
        line([BASELINE_RANGE(1) BASELINE_RANGE(end)]./UPDATE_RATE,[stat.insight.SmO2(ii).baseline stat.insight.SmO2(ii).baseline ],'Color', [1 0 0], 'LineStyle', '--')
        line([BASELINE_RANGE(1)+BASELINE_RANGE(end) BASELINE_RANGE(1)+BASELINE_RANGE(end)]./(2*UPDATE_RATE),[stat.insight.SmO2(ii).min stat.insight.SmO2(ii).max ],'Color', [0 1 0], 'LineStyle', '--', 'LineWidth', 2)
        legend('SmO2', ['Baseline = ' num2str(stat.insight.SmO2(ii).baseline)], ['Delta = ' num2str(stat.insight.SmO2(ii).delta)], 'Location', 'Best')
    else
        stat.insight.SmO2(ii) = baselineStats(NaN);
        stat.insight.HbF(ii) = baselineStats(NaN);
        stat.insight.HbConc(ii) = baselineStats(NaN);
        plot(0);    % clear plot
    end
    subplot(2,1,2)
    moxyRange = findRange(moxy(ii).time, BASELINE_RANGE);
    if ~isempty(moxyRange)  % deal with empty ranges
        stat.moxy.SmO2(ii) = baselineStats(moxy(ii).SmO2Avg(1:moxyRange(end)), moxyRange);
        plot(moxy(ii).time, moxy(ii).SmO2Avg)
        grid
        axis ([moxy(ii).time(1) moxy(ii).time(end) ...
            max([min(double(moxy(ii).SmO2Avg)) double(stat.moxy.SmO2(ii).min)*.97]) ...
            min([max(double(moxy(ii).SmO2Avg)) double(stat.moxy.SmO2(ii).max)*1.1])])
        xlabel('time (s)')
        ylabel('SmO_{2} (%)')
        title(['Moxy baseline Trial ' trialNum ', step ' num2str(ii)], 'FontSize', 12)
        line(moxy(ii).time(1)+[BASELINE_RANGE(1) BASELINE_RANGE(end)],[stat.moxy.SmO2(ii).baseline stat.moxy.SmO2(ii).baseline ],'Color', [1 0 0], 'LineStyle', '--')
        line(moxy(ii).time(1)+[BASELINE_RANGE(1)+BASELINE_RANGE(end) BASELINE_RANGE(1)+BASELINE_RANGE(end)]/2,[stat.moxy.SmO2(ii).min stat.moxy.SmO2(ii).max ],'Color', [0 1 0], 'LineStyle', '--', 'LineWidth', 2)
        legend('SmO2', ['Baseline = ' num2str(stat.moxy.SmO2(ii).baseline)], ['Delta = ' num2str(stat.moxy.SmO2(ii).delta)], 'Location', 'Best')
    else
        stat.moxy.SmO2(ii) = baselineStats(NaN);
        plot(0);    % clear plot
    end
    drawnow
    % Save plot and sweep file
    [temp, fname, temp2] = fileparts(insightFiles(ii).name);
    if PLOT_SAVE
        print([inpath fname '.png'],'-dpng')   % save plot as png file
    end
    sweepFile = [inpath fname SWEEP_SUFFIX];
    if ~exist(sweepFile, 'file')
        sweep = sweepMat(ii);
        save(sweepFile, 'sweep', 'device');
    end
end

% for jj = 1:length(flds)
% %    fprintf('%2.2f\t\t', mean([st.(flds{jj})]))
%     insight_mean(jj) = mean([stat.insight.SmO2.(flds{jj})]);
%     insight_std(jj) = std([stat.insight.SmO2.(flds{jj})]);
%     insight_max(jj) = max([stat.insight.SmO2.(flds{jj})]);
%     insight_min(jj) = min([stat.insight.SmO2.(flds{jj})]);
%     moxy_mean(jj) = mean([stat.moxy.SmO2.(flds{jj})]);
%     moxy_std(jj) = std([stat.moxy.SmO2.(flds{jj})]);
%     moxy_max(jj) = max([stat.moxy.SmO2.(flds{jj})]);
%     moxy_min(jj) = min([stat.moxy.SmO2.(flds{jj})]);
% end
%
% insight_table = table(insight_mean', insight_std', insight_max', insight_min', 'RowNames', flds', 'VariableNames',{'Mean' 'Std' 'Max' 'Min'})
%
% moxy_table = table(moxy_mean', moxy_std', moxy_max', moxy_min', 'RowNames', flds', 'VariableNames',{'Mean' 'Std' 'Max' 'Min'})

insight_SmO2table = struct2table(stat.insight.SmO2)
moxy_SmO2table = struct2table(stat.moxy.SmO2)
% [(stat.insight.HbF.baseline)]'
% [(stat.insight.HbConc.baseline)]'
fprintf('HbF baseline values:\n')
fprintf('%2.3e\n', [(stat.insight.HbF.baseline)])
fprintf('HbConc baseline values:\n')
fprintf('%2.4g\n', [(stat.insight.HbConc.baseline)])
