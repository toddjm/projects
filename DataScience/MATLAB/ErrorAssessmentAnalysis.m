% Script created to get statistics from user assessments with an ERROR status. Uses pre-parsed sweep files saved on Google Drive.
% N. Rajan and P. Silveira, Sep. 2015
% BSX Proprietary

%% Initializations

clear all
close all
global LEGACY_DEVID HW_DEFAULT      % legacy device ID and hardware version. Declare as global so it can be used by getAllCnt and getCurrents

LEGACY_DEVID = 'Legacy';    % legacy device id
HW_DEFAULT = '255';    % default hardware version (before current increase)
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)

% User entered query parameters
STATUS = 'ERROR';    % assessment status (and sub-folder where to save results)
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
SWEEP_DIR = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\LT Assessments\' STATUS '\']; % path were results are saved at the end
EXCLUDED_USERS = {'492'};
%EXCLUDED_ASSESSMENTS = {'5571525607c519f0048b457f' '558095a007c519650f8b45ce' '55cb59b1adac1824688b4585' '553ce8e0adac18f20e8b5306' '5523eda6adac18f10e8b4e3f' '552ba83dadac18db278b50aa' '552c6bf3adac18f10e8b5025' '552db8c3adac18f20e8b5128' '55379b24adac18f10e8b51a3' '553dba3cadac18f20e8b5314' '553e6fb8adac18f20e8b531c' '5581e5a6adac1856048b461e' '559f677aadac18d00e8b4665' '55a736a007c5190e7e8b4581' '55c8147f07c5190e7e8b466d' '55dd03bf07c519cf748b4569' '55e4ec7fadac185a4b8b457e' '55e670b907c519ba098b45bf' '55640aceadac18f20e8b55d1' '556FA3CE07C519F1048B4573' '557e1d0d07c519650f8b45b3' '54d8db8fadac18f10e8b4a3a', '5548f027adac18f10e8b52fb', '5534f1d8adac18f10e8b5147', '552828d4adac18f10e8b4f64', '5527f24aadac18f20e8b4ff2', '5526d19aadac18f20e8b4fb3','55204442adac18db278b4e82', '5523b4dbadac18db278b4ee8', '5522fc64adac18db278b4ed5', '55228e7fadac18f20e8b4eb8', '55157c8aadac18db278b4d23', '54e49349adac18db278b4b79','54e469c5adac18f20e8b4b76', '54dcb6ffadac18f20e8b4b1d', '54dba24fadac18db278b4b07', '55546d8dadac18f10e8b53e0','553fbc52adac18f10e8b523c', '553360aaadac18db278b520e', '552712a3adac18f20e8b4fd0'};    % list of assessments to be excluded
EXCLUDED_DEVICES = {'0CEFAF81097F' '0CEFAF81097C' '0CEFAF810970' '0CEFAF81097C' '0CEFAF810047'};
INCLUDED_HW_VERSION = {'255'}; % hw versions to be included in analysis

% Other parameters
ST_RANGE = [75:175];  % starting range (15s to 35s)
END_RANGE = [900:1100];    % end range (180s to 220s)
PERCENTILE = 10;    % percentile used to remove outliers on trimmean calculations
PP_THR = 10;    % post-processing threshold (counts) USING LOWER VALUE THAN USED FOR ALARMS
AMB_THR = 0; % ambient light threshold (counts)
BODY_PART = 'calf';
PPTDIR = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\LT Assessments\'];  % initial path for saving PowerPoint file with intermediate results
PPT_EXT = '.ppt';   % PowerPoint file extension
PPTFILEN = 'ErrorAssesssment_Analysis_plots';    % default filename of PowerPoint file with intermediate results
SAVE_RESULTS = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\LT Assessments\ErrorAssessment_Analysis_results']; % path and start of file name were results are saved at the end of analysis
TISSUE_FILTER_LENGTH = 2;    % length of filter (seconds)
UPDATE_RATE = 1;    % update rate (Hz)
BASELINE_RANGE = [20:40];   % baseline range (seconds)

% Other system parameters
DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format used by server in queries
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
% Filename of powerPoint file with intermediate plots characterizing each assessment. Comment out if this option is not desired.
FONTSIZE = 11;  % size of fonts used in plots
[wavel leds]  = getLeds; % wavel = LED centroid wavelengths. leds = led nominal wavelengths
MU = 'mu_a';    % pseudo-inverse method
jj = 0; % valid assessment counter
usr_idx = 0;    % user index

query = questdlg('Would you like to save intermediate results?');
PPT_FLAG = strcmp(query,'Yes'); % generate flag for saving intermediate PowerPoint results
if PPT_FLAG
    PPTDIR = uigetdir(PPTDIR);  % confirm directory
    PPT_PATH = [PPTDIR '\' PPTFILEN '_' date PPT_EXT]
    ppt = saveppt2(PPT_PATH, 'init');    % open file for saving
end

%% Process data

assessmentList = dir([SWEEP_DIR '*' SWEEP_SUFFIX]);
num_tot_assessments = length(assessmentList);   % total number of assessments to be processed
fprintf('%d assessments to be processed.\n', num_tot_assessments)

if PPT_FLAG
    saveppt2('ppt', ppt, 'textbox', ['Analysis date: ' date '\n Processing ' num2str(num_tot_assessments) ' assessments.\n PP_THR = ' num2str(PP_THR) '\nAMB_THR = ' num2str(AMB_THR) '\nBODY_PART = ' BODY_PART])
    figure(1);  % prepare figure with intermediate results
    set(1, 'Position', [830 247 907 420]);
end

% Retrieve assessments
for ii = 3:num_tot_assessments  % skip first two ('.' and '..')
    fprintf('Processing assessment %d/%d: ', ii-2, num_tot_assessments-2);
    load([SWEEP_DIR assessmentList(ii).name]);   % load sweep, assessment and device structures
    if exist('EXCLUDED_USERS', 'var') && any(strcmpi(assessment.user_id, EXCLUDED_USERS)), % ignore test users
        fprintf('Excluding assessment performed by user %s.\n', assessment.user_id);
        continue
    end
    if exist('EXCLUDED_ASSESSMENTS', 'var') && any(strcmpi(assessment.alpha__id, EXCLUDED_ASSESSMENTS)), % ignore anomalous assesments
        fprintf('Excluding assessment %s.\n', assessment.alpha__id);
        continue
    end
    szct = size(sweep.count15);
    if szct(1) < END_RANGE(end)
        fprintf('File too short (%d samples). Skipping.\n', szct(1))
        continue    % skip short assessments
    end
    try     % don't stop because of a bug
        if ~exist('device', 'var')  % it should exist, but just in case...
            device = getDevice(sweep.device_id);    % get device data
        end
        if exist('EXCLUDED_DEVICES', 'var') && any(strcmpi(sweep.device_id, EXCLUDED_DEVICES)), % ignore test devices
            fprintf('Excluding assessment performed using device %s.\n', sweep.device_id);
            continue
        end
        if exist('INCLUDED_HW_VERSION', 'var') && ~any(strcmpi(device.hw_version, INCLUDED_HW_VERSION)), % ignore devices with incorrect hardware versions
            fprintf('Excluding assessment performed using device hw_version = %s.\n', device.hw_version);
            continue
        end
        [AllCnt,invC15,invC27,lookup_current,diag] = getAllCnt( device, 1 ); % get most recent device calibration data
        if isfield(diag, 'CalibrationStatus') && diag.CalibrationStatus     % check for non-zero device calibration status
            fprintf(2, 'Non-zero device calibration status = %d on device %s. Skipping.\n', diag.CalibrationStatus, sweep.device_id);
            continue
        end
    catch err
        fprintf(2, '%s. Skipping assessment.\n', err.message)
        continue
    end
    [OD15, OD27] = processCounts(sweep, AllCnt, lookup_current, PP_THR, AMB_THR);
    ODDiff = OD27-OD15; % differential OD
    [SmO2, R, mu_eff, HbF, Pk, mu_s, mu_a] = calc_SmO2(ODDiff, MU, BODY_PART);   % calculate SmO2, Residuals, mu_eff and total hemoglobin
    process.SmO2 = processSmO2(SmO2);    % process SmO2 signals using default values
    pH2O = Pk(:,3); % water index
    HbConc = 5e4*HbF./pH2O; % hemoglobin concentration
    process.HbF = avgfiltNaN(HbF, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % LPF total hemoglobin
    process.pH2O = avgfiltNaN(pH2O, TISSUE_FILTER_LENGTH*sweep.samp_rate);
    process.HbConc = avgfiltNaN(HbConc, TISSUE_FILTER_LENGTH*sweep.samp_rate);
    %    [process.tissueTF, process.tissue] = istissue(HbF,HbConc);     % optical tissue detection
    
    jj = jj + 1;    % checked all exceptions. Ok to increase valid assessment counter
    assessment_id{jj} = assessment.alpha__id; % keep track of successfully accepted assessment IDs, in case we need to go back to an individual one for more analysis.
    device_id(:,jj) = device.device_id;
    user_id{jj} = assessment.user_id;  % keep track of unique users
    mu_eff_Start(:,jj)  = trimmean(mu_eff(ST_RANGE,:), PERCENTILE, 1); % store one mu_eff value for every user
    mu_eff_End(:,jj) = trimmean(mu_eff(END_RANGE,:), PERCENTILE, 1);
    count15Start(:,jj) = trimmean(sweep.count15(ST_RANGE,:), PERCENTILE, 1);
    count15End(:,jj) = trimmean(sweep.count15(END_RANGE,:), PERCENTILE, 1);
    count27Start(:,jj) = trimmean(sweep.count27(ST_RANGE,:), PERCENTILE, 1);
    count27End(:,jj) = trimmean(sweep.count27(END_RANGE,:), PERCENTILE, 1);
    ccode15End(:,jj) = trimmean(sweep.ccode15(END_RANGE,:), PERCENTILE, 1);
    ccode27End(:,jj) = trimmean(sweep.ccode27(END_RANGE,:), PERCENTILE, 1);
    pH2OStart(:,jj) = trimmean(pH2O(ST_RANGE,:), PERCENTILE);
    pH2OEnd(:,jj) = trimmean(pH2O(END_RANGE,:), PERCENTILE);
    HbFStart(:,jj) = trimmean(HbF(ST_RANGE,:), PERCENTILE);
    HbFEnd(:,jj) = trimmean(HbF(END_RANGE,:), PERCENTILE);
    HbConcStart(:,jj) = trimmean(HbConc(ST_RANGE,:), PERCENTILE);
    HbConcEnd(:,jj) = trimmean(HbConc(END_RANGE,:), PERCENTILE);
 
    assessmentMatrix(jj) = getAssessmentFields(assessment); % deal relevant assessment fields, Handles incomplete structures
    assessments{jj} = assessment;   % save all assessment data
    stat.SmO2(jj) = baselineStats(process.SmO2, BASELINE_RANGE*sweep.samp_rate);
    stat.HR(jj) = baselineStats(sweep.HR, BASELINE_RANGE*sweep.samp_rate);
    stat.pH2O(jj) = baselineStats(process.pH2O, BASELINE_RANGE*sweep.samp_rate);
    stat.HbConc(jj) = baselineStats(process.HbConc, BASELINE_RANGE*sweep.samp_rate);
    stat.HbF(jj) = baselineStats(process.HbF, BASELINE_RANGE*sweep.samp_rate);
    for kk = 1:numel(leds)
        stat.MuEff(jj,kk) = baselineStats(mu_eff(:,kk), BASELINE_RANGE*sweep.samp_rate);
        stat.OD15(jj,kk) = baselineStats(OD15(:,kk), BASELINE_RANGE*sweep.samp_rate);
        stat.OD27(jj,kk) = baselineStats(OD27(:,kk), BASELINE_RANGE*sweep.samp_rate);
    end
    [process.tissueTF process.tissue] = istissue(process.HbF, process.HbConc);  % calculate tissue detection parameters using default method
    if PPT_FLAG     % save plots to PowerPoint
        generateAssessmentPlot(sweep, process, OD15, OD27)
        saveppt2('ppt', ppt, 'fig', 1, 'stretch', 'off', 'textbox', ['Assessment ' assessment_id{jj} ' from user ' user_id{jj} ' completed on ' assessment.completed_on])
    end
    fprintf('Successfully processed assessment #%d from user %s performed on %s.\n', jj, assessment.user_id, assessment.completed_on)
    clear('sweep', 'assessment', 'device');  % clean up
end
numAssessments = jj;    % number of successfully processed assessments
[uniqueUsers, uid_idx] = unique(user_id);
fprintf('%d optical files successfully processed from %d unique users.\n', numAssessments, length(uniqueUsers));
if PPT_FLAG     % close PowerPoint file, if ppt filename is defined
    clf
    saveppt2('ppt', ppt, 'textbox', [num2str(numAssessments) ' optical files successfully processed from ' num2str(length(uniqueUsers)) ' unique users.\n'])
    saveppt2(PPT_PATH, 'ppt', ppt, 'close');
end

%% Data analysis

% Create arrays from stat structures
MuEff = [stat.MuEff];
HbF = [stat.HbF];
HbConc = [stat.HbConc];
pH2O = [stat.pH2O];
OD15 = [stat.OD15];
OD27 = [stat.OD27];

% Find min and max mu_eff using fences
[min_mu_eff_Start, max_mu_eff_Start] = fences(mu_eff_Start);
[min_mu_eff_End, max_mu_eff_End] = fences(mu_eff_End);
uif_mu_eff = max([max_mu_eff_Start max_mu_eff_End], [], 2);
lif_mu_eff = min([min_mu_eff_Start min_mu_eff_End], [], 2);
uif_mu_a = calc_mu_a(uif_mu_eff', mu_s);
lif_mu_a = calc_mu_a(lif_mu_eff', mu_s);
[max_mu_eff, max_mu_eff_idx] = max(mu_eff_End,[],2);
[min_mu_eff, min_mu_eff_idx] = min(mu_eff_Start,[],2);
tmax = table(leds', uif_mu_eff, uif_mu_a', max_mu_eff, char(user_id(max_mu_eff_idx)), {assessment_id{max_mu_eff_idx}}', 'VariableNames', {'LED', 'UIF_mu_eff', 'UIF_mu_a', 'Max_mu_eff', 'User_id', 'Assessment_id'});
tmin = table(leds', lif_mu_eff, lif_mu_a',min_mu_eff, char(user_id(min_mu_eff_idx)), {assessment_id{min_mu_eff_idx}}', 'VariableNames', {'LED', 'LIF_mu_eff', 'LIF_mu_a', 'Min_mu_eff', 'User_id', 'Assessment_id'});

% Find min and max HbF using fences
[min_HbF, max_HbF] = fences(HbFStart);  % Need to know indeces before start of exercise. Use start values.
[min_pH2O, max_pH2O] = fences(pH2OStart);
[min_HbConc, max_HbConc] = fences(HbConcStart);
% [max_HbF, max_HbF_idx] = max(HbFStart,[],2);
% [min_HbF, min_HbF_idx] = min(HbFStart,[],2);
% [max_pH2O, max_pH2O_idx] = max(pH2OStart,[],2);
% [min_pH2O, min_pH2O_idx] = min(pH2OStart,[],2);
% [max_HbConc, max_HbConc_idx] = max(HbConcStart,[],2);
% [min_HbConc, min_HbConc_idx] = min(HbConcStart,[],2);

% This script takes a long time to run, so let's make sure to save results.
savepath = [SAVE_RESULTS '_' date '.mat'];
save(savepath);
fprintf('Results saved to file %s\n', savepath)

%% Display results

tmax
tmin

fprintf('HbF: \tLower inner fence = %5E \tUpper inner fence = %5E\n', min_HbF, max_HbF)
fprintf('pH2O: \tLower inner fence = %5g \tUpper inner fence = %5g\n', min_pH2O, max_pH2O)
fprintf('HbConc: \tLower inner fence = %5g \tUpper inner fence = %5g\n', min_HbConc, max_HbConc)

figure(1)
set(gcf, 'Position', [807 -7 560 728]);
subplot(2,1,1)
boxplot(mu_eff_Start', leds)
grid
ylabel('\mu_{eff} (1/mm)', 'FontSize', FONTSIZE)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
title('\mu_{eff} at beginning of assessment', 'FontSize', FONTSIZE)
subplot(2,1,2)
boxplot(mu_eff_End', leds)
grid
ylabel('\mu_{eff} (1/mm)', 'FontSize', FONTSIZE)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
title('\mu_{eff} 15min into assessment', 'FontSize', FONTSIZE)

figure
set(gcf, 'Position', [807 -7 560 728]);
subplot(2,1,1)
boxplot(count15Start',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Counts')
title('15mm LEDs at beginning of assessment', 'FontSize', FONTSIZE)
grid
subplot(2,1,2)
boxplot(count15End',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Counts', 'FontSize', FONTSIZE)
title('15mm LEDs 15min into assessment', 'FontSize', FONTSIZE)
grid

figure
set(gcf, 'Position', [807 -7 560 728]);
subplot(2,1,1)
boxplot(count27Start',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Counts', 'FontSize', FONTSIZE)
title('27mm LEDs at beginning of assessment', 'FontSize', FONTSIZE)
grid
subplot(2,1,2)
boxplot(count27End',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Counts', 'FontSize', FONTSIZE)
title('27mm LEDs 15min into assessment', 'FontSize', FONTSIZE)
grid

figure
set(gcf, 'Position', [807 -7 560 728]);
subplot(2,1,1)
boxplot((ccode15End*1000)',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Currents (mA)')
title('15mm LEDs 15min into assessment', 'FontSize', FONTSIZE)
grid
subplot(2,1,2)
boxplot((ccode27End*1000)',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Currents (mA)', 'FontSize', FONTSIZE)
title('27mm LEDs 15min into assessment', 'FontSize', FONTSIZE)
grid

figure
set(gcf, 'Position', [576 -179 560 872]);
subplot(3,1,1)
boxplot([HbFStart' HbFEnd'], {'HbFStart' 'HbFEnd'})
grid
ylabel('Hemoglobin index', 'FontSize', FONTSIZE)
title('Optical tissue indices', 'FontSize', FONTSIZE)
subplot(3,1,2)
boxplot([pH2OStart' pH2OEnd'], {'pH2OStart' 'pH2OEnd'})
grid
ylabel('Hydration index', 'FontSize', FONTSIZE)
subplot(3,1,3)
boxplot([HbConcStart' HbConcEnd'], {'HbConcStart' 'HbConcEnd'})
grid
ylabel('Hemoglobin Conc. (g/dL)', 'FontSize', FONTSIZE)
%title('Hb conc. at beginning of assessment', 'FontSize', FONTSIZE)

figure
plot([HbConc.baseline], [HbF.baseline], 'k.')
grid
xlabel('Hemoglobin Conc. (g/dL)', 'FontSize', FONTSIZE)
ylabel('HbF')

figure
set(gcf, 'Position', [628 -110 667 893]);
subplot(3,1,1)
boxplot(reshape([MuEff.baseline],size(MuEff)),{leds}, 'notch', 'on')
ylabel('\mu_{eff} (1/mm)')
grid
title('Distribution of \mu_{eff} baseline values')
subplot(3,1,2)
boxplot(reshape([MuEff.max_prctile],size(MuEff)),{leds}, 'notch', 'on')
ylabel('\mu_{eff} (1/mm)')
grid
title('Distribution of \mu_{eff} 99-percentile values')
subplot(3,1,3)
boxplot(reshape([MuEff.min_prctile],size(MuEff)),{leds}, 'notch', 'on')
ylabel('\mu_{eff} (1/mm)')
grid
title('Distribution of \mu_{eff} 1-percentile values')

figure
set(gcf, 'Position', [628 -110 667 893]);
subplot(3,1,1)
boxplot(reshape([OD15.baseline],size(OD15)),{leds}, 'notch', 'on')
ylabel('OD')
grid
title('Distribution of OD @ 15mm, baseline values')
subplot(3,1,2)
boxplot(reshape([OD15.max_prctile],size(OD15)),{leds}, 'notch', 'on')
ylabel('OD')
grid
title('Distribution of OD @ 15mm, 99-percentile values')
subplot(3,1,3)
boxplot(reshape([OD15.min_prctile],size(OD15)),{leds}, 'notch', 'on')
ylabel('OD')
grid
title('Distribution of OD @ 15mm, 1-percentile values')

figure
set(gcf, 'Position', [628 -110 667 893]);
subplot(3,1,1)
boxplot(reshape([OD27.baseline],size(OD27)),{leds}, 'notch', 'on')
ylabel('OD')
grid
title('Distribution of OD @ 27mm, baseline values')
subplot(3,1,2)
boxplot(reshape([OD27.max_prctile],size(OD27)),{leds}, 'notch', 'on')
ylabel('OD')
grid
title('Distribution of OD @ 27mm, 99-percentile values')
subplot(3,1,3)
boxplot(reshape([OD27.min_prctile],size(OD27)),{leds}, 'notch', 'on')
ylabel('OD')
grid
title('Distribution of OD @ 27mm, 1-percentile values')

for jj = 1:numAssessments, for ii = 1:numel(leds), blOD15(jj,ii) = OD15(jj,ii).baseline; end; end
for jj = 1:numAssessments, for ii = 1:numel(leds), blOD27(jj,ii) = OD27(jj,ii).baseline; end; end

figure
%set(gcf, [840 241 668 420])
plot3( wavel, blOD15, blOD27, 'k.')
grid; axis tight
xlabel('Wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('OD @ 15mm', 'FontSize', FONTSIZE)
zlabel('OD @ 27mm', 'FontSize', FONTSIZE)
title(['Baseline OD distribution for ' num2str(numAssessments) ' assessments'], 'FontSize', FONTSIZE)

% Generate box plots of statistics
fld = fields(stat);
genBoxPlots(stat, {fld{1:end-3}});    % leave out last three fields

reply = questdlg('Save figures to PowerPoint file?');
if strcmp(reply,'Yes')
    saveAssessmentPPT([SAVE_RESULTS '_' date PPT_EXT], ['Analysis of completed assessments' '\n# of assessments = ' num2str(numAssessments) '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART]);
end

