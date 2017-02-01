% Script created to generate file with data from assessments included in
% regression list.
% See also
% Run_calib.m
%
% P. Silveira, July 2015
% BSX Proprietary

%% Initializations

clear all
close all
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)

%UNIQUE = 1; % set to one to select a unique assessment per user;

% User entered parameters
%EXCLUDED_USERS = {'492'};
%EXCLUDED_ASSESSMENTS = {'55640aceadac18f20e8b55d1' '556FA3CE07C519F1048B4573' '557e1d0d07c519650f8b45b3' '54d8db8fadac18f10e8b4a3a', '5548f027adac18f10e8b52fb', '5534f1d8adac18f10e8b5147', '552828d4adac18f10e8b4f64', '5527f24aadac18f20e8b4ff2', '5526d19aadac18f20e8b4fb3','55204442adac18db278b4e82', '5523b4dbadac18db278b4ee8', '5522fc64adac18db278b4ed5', '55228e7fadac18f20e8b4eb8', '55157c8aadac18db278b4d23', '54e49349adac18db278b4b79','54e469c5adac18f20e8b4b76', '54dcb6ffadac18f20e8b4b1d', '54dba24fadac18db278b4b07', '55546d8dadac18f10e8b53e0','553fbc52adac18f10e8b523c', '553360aaadac18db278b520e', '552712a3adac18f20e8b4fd0'};    % list of assessments to be excluded
ST_RANGE = [75:1075];  % starting range (15s to 215s)
END_RANGE = [4500:5500];    % end range (900s to 1100s)
PERCENTILE = 10;    % percentile used to remove outliers on trimmean calculations
PP_THR = 10;    % post-processing threshold (counts)
AMB_THR = 10000; % ambient light threshold (counts)
BODY_PART = 'calf';
INDIR = 'C:\Users\paulobsx\Documents\BSXprotocol\tests\files';  % path with list of assessments
PPTDIR = INDIR; %[USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\User_assessments'];  % initial path for saving PowerPoint file with intermediate results
PPTFILEN = 'Assesssment_Analysis_plots';    % default filename of PowerPoint file with intermediate results
SAVE_RESULTS = INDIR; %[USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\User_assessments\Assessment_Analysis_results']; % path were results are saved at the end

% Other system parameters
DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format used by server in queries
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
% Filename of powerPoint file with intermediate plots characterizing each assessment. Comment out if this option is not desired.
PPT_EXT = '.ppt';   % PowerPoint file extension
FONTSIZE = 11;  % size of fonts used in plots
leds = getLeds; % LED centroid wavelengths
currents = getCurrents; % get 25 nominal current values (Amps)end
MU = 'mu_a';    % pseudo-inverse method
mu_s = calc_mu_s(leds, BODY_PART)/10; % if second argument is not set, calc_mu_s assumes we are monitoring a calf
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
fileList = dir([INDIR '\*.oxy']);  % get list of assessments
num_tot_assessments = length(fileList);   % total number of assessments to be processed

fprintf('%d assessments to be processed.\n', num_tot_assessments)

if PPT_FLAG
    saveppt2('ppt', ppt, 'textbox', ['Analysis date: ' date '\n Processing ' num2str(num_tot_assessments) ' assessments.\n PP_THR = ' num2str(PP_THR) '\nAMB_THR = ' num2str(AMB_THR) '\nBODY_PART = ' BODY_PART])
    figure(1);  % prepare figure with intermediate results
    set(1, 'Position', [830 247 907 420]);
end

% Retrieve assessments
for ii = 1:num_tot_assessments
    fprintf('Processing assessment %d: ', ii);
    assessment = getAssessment(fileList(ii).name(1:24));
    if exist('EXCLUDED_ASSESSMENTS', 'var') && any(strcmpi(assessment.alpha__id, EXCLUDED_ASSESSMENTS)), % ignore anomalous assesments
        fprintf('Excluding assessment %s.\n', assessment.alpha__id);
        continue
    end
    if ~isfield(assessment, 'links') || ~isfield(assessment.links, 'optical')    % scan only through assessment which have a valid optical file
        fprintf('No optical file. Skipping.\n');
        continue
    end
    if exist('EXCLUDED_USERS', 'var') && any(strcmpi(assessment.user_id, EXCLUDED_USERS)), % ignore test users
        fprintf('Excluding assessment performed by user %s.\n', assessment.user_id);
        continue
    end
    try
        sweep = getSweep(assessment.links.optical, TEMP_CSV); % get sweep data, save csv file to temporary file
    catch
        fprintf('Defective sweep file. Skipping.\n')
        continue    % skip defective sweeps
    end
    szct = size(sweep.count15);
    if szct(1) < END_RANGE(end)
        fprintf('File too short (%d samples). Skipping.\n', szct(1))
        continue    % skip short assessments
    end
    device = getDevice(sweep.Device_id);    % get device data
    [AllCnt,invC15,invC27,diag] = getAllCnt( device, 1 ); % get most recent device calibration data
%     if isfield(diag, 'CalibrationStatus') && diag.CalibrationStatus     % check for non-zero device calibration status
%         fprintf('Non-zero device calibration status = %d on device %s. Skipping.\n', diag.CalibrationStatus, sweep.Device_id);
%         continue
%     end
    [OD15, OD27] = processCounts(sweep, AllCnt, currents, PP_THR, AMB_THR);
    cHb15 = OD15 * invC15';
    cHb27 = OD27 * invC27';
    sweep.tHb_15 = sum(cHb15,2);   % total hemoglobin from re-calculated concentrations
    sweep.tHb_27 = sum(cHb27,2);
    sweep.SmO2_15 = cHb15(:,2) ./ sweep.tHb_15;   % using re-calculated concentrations
%    sweep.SmO2_15 = processSmO2(sweep.SmO2_15, 'softsig', 1.6, 75, 1);  %
    sweep.SmO2_27 = cHb27(:,2) ./ sweep.tHb_27;
    ODDiff = OD27-OD15; % differential OD
    [SmO2, R, mu_eff, HbF] = calc_SmO2(ODDiff, MU, BODY_PART);   % calculate SmO2, Residuals, mu_eff and total hemoglobin
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
    current15End(:,jj) = trimmean(sweep.current15(END_RANGE,:), PERCENTILE, 1);
    current27End(:,jj) = trimmean(sweep.current27(END_RANGE,:), PERCENTILE, 1);
    if PPT_FLAG     % save plots to PowerPoint
        generateAssessmentPlot(sweep, SmO2, R, HbF)
        saveppt2('ppt', ppt, 'fig', 1, 'stretch', 'off', 'textbox', ['Assessment ' assessment_id{jj} ' from user ' user_id{jj} ' completed on ' assessment.completed_on])
    end
    fprintf('Successfully processed assessment from user %s performed on %s.\n', assessment.user_id, assessment.completed_on)
end
numAssessments = jj;    % number of successfully processed assessments
[uniqueUsers, uid_idx] = unique(user_id);
fprintf('%d optical filess successfully processed from %d unique users.\n', numAssessments, length(uniqueUsers));
if PPT_FLAG     % close PowerPoint file, if ppt filename is defined
    clf
    saveppt2('ppt', ppt, 'textbox', [num2str(numAssessments) ' optical files successfully processed from ' num2str(length(uniqueUsers)) ' unique users.\n'])
    saveppt2(PPT_PATH, 'ppt', ppt, 'close');
end

%% Data analysis

delta_mu_eff = mu_eff_End - mu_eff_Start;
delta_count15 = count15End - count15Start;
delta_count27 = count27End - count27Start;

% Find minimum counts fence values
min15 = min([fences(count15Start), fences(count15End)],[],2);
min27 = min([fences(count27Start), fences(count27End)],[],2);
med15 = median(count15Start,2);
med27 = median(count27Start,2);
newMed15 = (2000-min15)+med15;
newMed27 = (2000-min27)+med27;

% Find min and max mu_eff using fences
[min_mu_eff_Start, max_mu_eff_Start] = fences(mu_eff_Start);
[min_mu_eff_End, max_mu_eff_End] = fences(mu_eff_End);
uif_mu_eff = max([max_mu_eff_Start max_mu_eff_End], [], 2);
lif_mu_eff = min([min_mu_eff_Start min_mu_eff_End], [], 2);
uif_mu_a = calc_mu_a(uif_mu_eff', mu_s);
lif_mu_a = calc_mu_a(lif_mu_eff', mu_s);
[max_mu_eff, max_mu_eff_idx] = max(mu_eff_End,[],2);
[min_mu_eff, min_mu_eff_idx] = min(mu_eff_Start,[],2);
tmax = table(leds', uif_mu_eff, uif_mu_a', max_mu_eff, char(user_id(max_mu_eff_idx)), {assessment_id{max_mu_eff_idx}}', 'VariableNames', {'LED', 'UIF_mu_eff', 'UIF_mu_a', 'Max_mu_eff', 'User_id', 'Assessment_id'})
tmin = table(leds', lif_mu_eff, lif_mu_a',min_mu_eff, char(user_id(min_mu_eff_idx)), {assessment_id{min_mu_eff_idx}}', 'VariableNames', {'LED', 'LIF_mu_eff', 'LIF_mu_a', 'Min_mu_eff', 'User_id', 'Assessment_id'})

% This script takes a long time to run, so let's make sure to save results.
save([SAVE_RESULTS '_' date '.mat']);
fprintf('Results saved to file %s\n', [SAVE_RESULTS '.mat'])

%% Display results

figure(1)
set(gcf, 'Position', [807 -7 560 728]);
subplot(2,1,1)
boxplot(mu_eff_Start', leds)
grid
ylabel('\mu_{eff} (1/cm)', 'FontSize', FONTSIZE)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
title('\mu_{eff} at beginning of assessment', 'FontSize', FONTSIZE)
subplot(2,1,2)
boxplot(mu_eff_End', leds)
grid
ylabel('\mu_{eff} (1/cm)', 'FontSize', FONTSIZE)
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
boxplot((current15End*1000)',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Currents (mA)')
title('15mm LEDs 15min into assessment', 'FontSize', FONTSIZE)
grid
subplot(2,1,2)
boxplot((current27End*1000)',leds)
xlabel('LED centroid wavelengths (nm)', 'FontSize', FONTSIZE)
ylabel('Currents (mA)', 'FontSize', FONTSIZE)
title('27mm LEDs 15min into assessment', 'FontSize', FONTSIZE)
grid

%reply = input('Save figures to PowerPoint file (Y/N)?','s');
reply = questdlg('Save figures to PowerPoint file?');
if strcmp(reply,'Yes')
    saveAssessmentPPT([SAVE_RESULTS '_' date PPT_EXT], ['Analysis of completed assessments' '\n# of assessments = ' num2str(numAssessments) '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART]);
end

