% Script used to analyze LT assessments and generate calibration table
% P. Silveira, Aug. 2015
% BSX Athletics Proprietary
%

%% Initialize
clear all
close all

% System parameters
[cent_wavel leds] = getLeds; % get LED nominal wavelengths

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Insight2.0\SmO2 and FW alerts\Development\Calibration\Assessments\'];
%TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
% Table with assessments to be used in calibration
CALIB_TABLE = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Insight2.0\SmO2 and FW alerts\Development\Calibration\Calibration_Table-Adjusted_Aug2015.xlsx'];
PPTDIR = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Insight2.0\SmO2 and FW alerts\Development\Calibration\'];  % initial path for saving PowerPoint file with intermediate results
SAVE_MAT = PPTDIR;  % path were to save .mat files with sweep structure
PPTFILEN = 'Calibration Assessment plots';
PPT_EXT = '.ppt';
SWEEP_EXT = '_sweep.mat';   % sweep file extension
PROC_EXT = '_process.mat';  % processed file extension

% Processing parameters
% BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'
% PP_THR = 10;    % post-processing threshold (counts)
% AMB_THR = 10000; % ambient light threshold (counts)
% MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
%GAIN = 1.6;   % scaling function gain factor
%MAP_METHOD = 'softsig';  % mapping method
%DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
FILTER_LENGTH = 15;    % length of filter (samples)
%UPDATE_RATE = 1;    % update rate (Hz)
numAssessment = 0; % assessment counter

%% Data input

[temp, pathN] = xlsread(CALIB_TABLE, 'Revised Set', 'A2:B205');
num_tot_assessments = length(pathN); %number of assessments

query = questdlg('Would you like to save intermediate results?');
PPT_FLAG = strcmp(query,'Yes'); % generate flag for saving intermediate PowerPoint results
if PPT_FLAG
    PPTDIR = uigetdir(PPTDIR);  % confirm directory
    PPT_PATH = [PPTDIR '\' PPTFILEN '_' date PPT_EXT]
    ppt_plot = saveppt2(PPT_PATH, 'init');    % open file for saving
    saveppt2('ppt', ppt_plot, 'textbox', ['Analysis date: ' date '\n Processing ' num2str(num_tot_assessments) ' assessments.\n'])
    
end

for ii=1:num_tot_assessments
    if isempty(pathN{ii,1})
        continue    % skip blank paths
    end
    [temp, fileN, ext] = fileparts(pathN{ii,2});
    filename = [USERPATH pathN{ii,1} '\' fileN '.csv'];
    sweepFile = [USERPATH pathN{ii,1} '\' fileN SWEEP_EXT]; % sweep file name
    fprintf('Processing file %d of %d. Name = %s\n', ii, num_tot_assessments, filename)
    %   try % continue execution even if there are errors
    if exist(sweepFile,'file')
        fprintf('Loading previously save sweep file.\n')
        load(sweepFile);
    else
        sweep = getSweep(filename);
    end
    device = getDevice(sweep.device_id);    % get device data
    [AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent device calibration data
    process.assessment = sweep.assessment;  % assessment is the field that links both structures
    [OD15, OD27] = processCounts(sweep, AllCnt, lookup_current);
    ODDiff = OD27-OD15; % differential OD
    [ process.SmO2, R, mu_eff, HbF, process.Pk ] = calc_SmO2(ODDiff);
    mu_s = calc_mu_s(cent_wavel)/10; % if second argument is not set, calc_mu_s assumes we are monitoring a calf
    process.mu_a = calc_mu_a(mu_eff,repmat(mu_s, numel(sweep.time),1));  % absorption coefficient (1/mm)
    % Re-calculate Hb concentrations
    process.cHb15 = OD15 * invC15';
    process.cHb27 = OD27 * invC27';
    
    % Spatially-resolved projection calculations
    pHhb = process.Pk(:,1);
    pHbO2 = process.Pk(:,2);
    pH2O = process.Pk(:,3);
    
    % Total Hemoglobin calculations
    sweep.tHb_15 = sweep.cHbO2_15mm + sweep.cHhb_15mm;   % from device-calculated concentrations
    sweep.tHb_27 = sweep.cHbO2_27mm + sweep.cHhb_27mm;
    process.tHb_15 = sum(process.cHb15,2);   % from re-calculated concentrations
    process.tHb_27 = sum(process.cHb27,2);
    HbConc = 5e4*HbF./pH2O; % hemoglobin concentration
    
    % SmO2 calculations
    process.SmO2_15 = 100*process.cHb15(:,2) ./ process.tHb_15;   % using re-calculated concentrations
    process.SmO2_27 = 100*process.cHb27(:,2) ./ process.tHb_27;
    sweep.SmO2_15 = 100*sweep.cHbO2_15mm ./ sweep.tHb_15;   % using device-calculated concentrations
    sweep.SmO2_27 = 100*sweep.cHbO2_27mm ./ sweep.tHb_27;
    pSmO2 = pHbO2 ./ HbF;   % pseudo-inverse with H2O
    
    process.ppSmO2 = processSmO2(pSmO2);   % post-process, using default parameters
    %ppSmO2 = ppSmO2(1:sweep.samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
    if isfield(sweep, 'SmO2')
        temp = sweep.SmO2;  % also process SmO2 value calculated by firmware
        temp(temp > 100) = NaN;  % replace 0x3FF and 0x3FE values with NaN
        sweep.SmO2 = temp;
    end
    dec_time = linspace(sweep.time(1), sweep.time(end), length(process.ppSmO2));    % decimated time
    process.HbF = avgfiltNaN(HbF, FILTER_LENGTH);   % LPF total hemoglobin
    process.pH2O = avgfiltNaN(pH2O, FILTER_LENGTH);
    process.HbConc = avgfiltNaN(HbConc, FILTER_LENGTH);
    [process.tissueTF, process.tissue] = istissue(process.HbF,process.HbConc);     % optical tissue detection
    
    % Extract SmO2 range
    len_SmO2 = length(process.ppSmO2);
    baseLine = [20*sweep.samp_rate:40*sweep.samp_rate];     % baseline time period
    firstStage = [60*sweep.samp_rate:120*sweep.samp_rate];   % time period in the middle of 1st stage
    secondHalf = [round(len_SmO2/2):len_SmO2];
    process.baselineSmO2 = mean(process.ppSmO2(baseLine));    % baseline SmO2
    temp = process.ppSmO2(firstStage);
    temp2 = temp(isfinite(temp));       % exclude NaNs
    process.firstStageSmO2 = mean(temp2);   % Average SmO2 in the middle of 1st stage
    process.exhaustionSmO2 = prctile(process.ppSmO2(secondHalf),0.25);     % exhaustion SmO2
    
    %% Plot results
    
    %      Run_calib_plot  % plot results
    
    if PPT_FLAG     % save plots to PowerPoint
        figure(1);  % prepare figure with intermediate results
        set(1, 'Position', [830 247 907 420]);
        generateCalibPlot(sweep, process)
        saveppt2('ppt', ppt_plot, 'fig', 1, 'stretch', 'off', 'textbox', ['File ' fileN])
    end
    
    if exist('SAVE_MAT', 'var')
        if ~exist(sweepFile,'file')
            save([USERPATH pathN{ii,1} '\' fileN SWEEP_EXT], 'sweep');  % save sweep structure in .mat file to expedite future processing
        end
        save([USERPATH pathN{ii,1} '\' fileN PROC_EXT], 'process');  % save process structure in .mat file to expedite future processing
    end
    
    numAssessment = numAssessment+1;    % assessment successfully processed. Increment counter
    baselineSmO2(numAssessment) = process.baselineSmO2;
    exhaustionSmO2(numAssessment) = process.exhaustionSmO2;
    firstStageSmO2(numAssessment) = process.firstStageSmO2;
    
    clear sweep process    % start anew
    
    %    catch err
    %            fprintf(2, '%s\n', err.message)
    %            continue
    %    end
end

fprintf('%d assessments processed.\n', numAssessment);
if PPT_FLAG     % close PowerPoint file, if ppt filename is defined
    clf
    saveppt2('ppt', ppt_plot, 'textbox', [num2str(numAssessment) ' optical files successfully processed.'])
    saveppt2(PPT_PATH, 'ppt', ppt_plot, 'close');
end


% This script takes a long time to run, so let's make sure to save results.
temp_filen = [SAVE_MAT 'Calibration_Results_' date '.mat'];
save(temp_filen);
fprintf('Results saved to file %s\n', temp_filen)

results = table([1:numAssessment]', baselineSmO2', exhaustionSmO2', baselineSmO2'-exhaustionSmO2',  firstStageSmO2', 'VariableNames', {'Number' 'Baseline' 'Exhaustion' 'Delta' 'FirstStage'})



