% Script used to analyze data from Optical Tissue Verification study
% P. Silveira, Sep. 2015
% BSX Athletics Proprietary
%

%% Initialize
clear all
close all
[cent_wavel leds] = getLeds; % get LED centroid and nominal wavelengths

% Path parameters
FONTSIZE = 11;  % size of fonts used in plots
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Tissue detection\Verification'];
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
%FILE_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Assessment Analysis';
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures

% Processing parameters
BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'
PP_THR = 66;    % post-processing threshold (counts)
AMB_THR = 10000; % ambient light threshold (counts)
%MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
GAIN = 1.6;   % scaling function gain factor
MAP_METHOD = 'softsig';  % mapping method
DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
FILTER_LENGTH = 3;  % length of filter used to calculate SmO2 (seconds)
TISSUE_FILTER_LENGTH = FILTER_LENGTH;    % length of filter (seconds)
UPDATE_RATE = 1;    % update rate (Hz)
BASELINE_RANGE = [20:40];   % baseline range (seconds)

%% Data input
assessment_ID = inputdlg('Enter assessment ID number (click on "Cancel" or press "Esc" twice to select a file instead)', 'Select assessment');
if isempty(assessment_ID)  % file input selected
    [filename, pathname, filterind] = uigetfile({['*' SWEEP_SUFFIX] 'MATLAB sweep file'; '*.csv' 'CSV'; '*.bin' 'Binary'; '*.optical' 'Binary'}, 'Pick file with assessment data', FILE_PATH, 'MultiSelect', 'off');
    if filename == 0    % no file selected
        fprintf('No file selected. Exiting.\n')
        return
    end
    [temp, file, fileExt] = fileparts(filename);   % get file extension
    switch fileExt
        case {'.bin' '.optical' '.csv'} % file types that can be handled by getSweep
            sweep = getSweep([pathname filename], TEMP_CSV);  % get sweep data, save csv file to temporary file
        case '.mat'
            file = filename(1:end-length(SWEEP_SUFFIX)); % find root
            load([pathname filename]);
        otherwise
            error(['Unsupported file extension = ' fileExt])
    end
else    % url selected
    fileExt = 'url';    % flag URL selection
    assessment = getAssessment(assessment_ID{1});
    if isfield(assessment, 'links')
        sweep = getSweep(assessment.links.optical, TEMP_CSV); % get sweep data, save csv file to temporary file
    else
        fprint('No optical files available in asessment! Exiting.\n')
        return
    end
end
device = getDevice(sweep.device_id);    % get device data
[AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent calibration pars
%[AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 2 ); % get most second recent calibration pars - recommended for some beta devices that were recalibrated


%% Data processing and Analysis

[OD15, OD27] = processCounts(sweep, AllCnt, lookup_current, PP_THR, AMB_THR);
ODDiff = OD27-OD15; % differential OD
[ SmO2, R, mu_eff, HbF, Pk] = calc_SmO2(ODDiff);
%mu_s = calc_mu_s(cent_wavel, BODY_PART); % if second argument is not set, calc_mu_s assumes we are monitoring a calf
%mu_a = calc_mu_a(mu_eff,repmat(mu_s, numel(sweep.time),1));  % absorption coefficient (1/mm)

% Re-calculate Hb concentrations
process.cHb15 = OD15 * invC15';
process.cHb27 = OD27 * invC27';

% Spatially-resolved projection calculations
pHhb = Pk(:,1);
pHbO2 = Pk(:,2);
pH2O = Pk(:,3);
% if exist('MELANIN', 'var')
%     pmelanin = projections(:,4);
% end

% Total Hemoglobin calculations
sweep.tHb_15 = sweep.cHbO2_15mm + sweep.cHhb_15mm;   % from device-calculated concentrations
sweep.tHb_27 = sweep.cHbO2_27mm + sweep.cHhb_27mm;
process.tHb_15 = sum(process.cHb15,2);   % from re-calculated concentrations
process.tHb_27 = sum(process.cHb27,2);
HbConc = 5e4*HbF./pH2O; % hemoglobin concentration

% SmO2 calculations
process.SmO2_15 = 100*process.cHb15(:,2) ./ process.tHb_15;   % using re-calculated concentrations
process.SmO2_27 = 100*process.cHb27(:,2) ./ process.tHb_27;
%sweep.SmO2_15 = 100*sweep.cHbO2_15mm ./ sweep.tHb_15;   % using device-calculated concentrations
%sweep.SmO2_27 = 100*sweep.cHbO2_27mm ./ sweep.tHb_27;
rawSmO2 = pHbO2 ./ HbF;   % pseudo-inverse with H2O

process.SmO2 = processSmO2(rawSmO2, MAP_METHOD, GAIN, FILTER_LENGTH*sweep.samp_rate, DIGITS);   % post-process
process.SmO2 = process.SmO2(1:sweep.samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
if isfield(sweep, 'SmO2')
    temp = sweep.SmO2;  % also process SmO2 value calculated by firmware
    temp(temp > 100) = NaN;  % replace 0x3FF and 0x3FE values with NaN
    sweep.SmO2 = temp;
end
process.dec_time = linspace(sweep.time(1), sweep.time(end), length(process.SmO2));    % decimated time
process.HbF = avgfiltNaN(HbF, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % LPF total hemoglobin
process.pH2O = avgfiltNaN(pH2O, TISSUE_FILTER_LENGTH*sweep.samp_rate);
process.HbConc = avgfiltNaN(HbConc, TISSUE_FILTER_LENGTH*sweep.samp_rate);
[process.tissueTF, process.tissue] = istissue(process.HbF,process.HbConc);     % optical tissue detection

% Calculate min, max, averages and baselines
process.stat.SmO2 = baselineStats(sweep.SmO2, BASELINE_RANGE*sweep.samp_rate);
process.stat.HR = baselineStats(sweep.HR, BASELINE_RANGE*sweep.samp_rate);
process.stat.pH2O = baselineStats(process.pH2O, BASELINE_RANGE*sweep.samp_rate);
process.stat.HbConc = baselineStats(process.HbConc, BASELINE_RANGE*sweep.samp_rate);
process.stat.HbF = baselineStats(process.HbF, BASELINE_RANGE*sweep.samp_rate);

%% Display results

reply = questdlg('Save output to PDF file?');
if strcmp(reply,'Yes')
    if strcmp(fileExt,'url') %~exist('pathname', 'var')   % need to pick a file
        pathname = uigetdir(FILE_PATH, 'Select directory where to save PDF file');
        FILE_PATH = pathname;   % make this the new default directory
        file = assessment_ID{1};
    end
    pdf_file = publish('Run_check_plot.m', 'outputDir', pathname, 'format', 'pdf','showCode', false);
    new_pdf_file = [pathname '\' file '.pdf'];
    movefile(pdf_file, new_pdf_file,'f'); % move pdf file to final destination, renaming it in the process
    fprintf('Saved PDF to file %s\n', new_pdf_file)
else
    Run_check_plot  % plot results
end

% Calculate and print median HbF and HbConc values for each range 
for ii = 1:round(sweep.time(end)/60)
    indRange = ([20:50]+60*(ii-1))*sweep.samp_rate;
    HbConcVal(ii) = prctile(process.HbConc(indRange),50);    % robust method to calculate median value within range
    HbFVal(ii) =  prctile(process.HbF(indRange),50);
    fprintf('%4.3f\t%4.4e\n', HbConcVal(ii), HbFVal(ii))
    for jj = 1:numel(leds)
        OD15Val(ii,jj) =  prctile(OD15(indRange,jj),50);
        OD27Val(ii,jj) =  prctile(OD27(indRange,jj),50);
    end
end
OD15Val     % print values
OD27Val

figure(11); % Bring index plot to the top




