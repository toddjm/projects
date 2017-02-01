% Script used to analyze LT assessment run from a CSV or binary files
% P. Silveira, Feb. 2015
% Last modified: March 2015.
% BSX Athletics Proprietary
%

%% Initialize
clear all
close all

% System parameters
%leds = [665, 810, 850, 950];    % led peak wavelengths
%leds = [664  799  846  932];    % led centroid wavelengths
[temp leds] = getLeds; % get LED nominal wavelengths
%[HB,HBO2] = prahlhb(leds);   % get absorption spectra
%HB = HB/10;%*log(10); %change from cm-1 to mm-1
%HBO2 = HBO2/10;%*log(10); %change from cm-1 to mm-1
%WATER = WaterHaleQuerrySpectra(leds)/10; %change from cm-1 to mm-1
%MELANIN = melanosome_mu_a(leds)/10; % melanin. Comment out to ignore
% if exist('MELANIN', 'var')
%     fMat = [HB(:) HBO2(:) WATER(:) MELANIN(:)];   % spectral components of tissue absorption
% else
%     fMat = [HB(:) HBO2(:) WATER(:)];   % spectral components of tissue absorption
% end
%fInv = pinv(fMat); % pinv of the three major components
DEVICE_EXCEPTION = {'0CEFAF810086'};    % device exception list

% Path parameters
FONTSIZE = 11;  % size of fonts used in plots
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\'];
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
%FILE_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Assessment Analysis';

% Processing parameters
BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'
PP_THR = 10;    % post-processing threshold (counts)
AMB_THR = 10000; % ambient light threshold (counts)
MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
IP_METHOD = 'pseudo-H2O';   % inner-product method. Choose between 'cosine', 'vector projection', 'pseudo-inverse' and 'pseudo-H2O'
GAIN = 1.6;   % scaling function gain factor
MAP_METHOD = 'softsig';  % mapping method
DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
FILTER_LENGTH = 75;    % length of filter (samples)
UPDATE_RATE = 1;    % update rate (Hz)

%% Data input
assessment_ID = inputdlg('Enter assessment ID number (click on "Cancel" to select a file instead)', 'Select assessment');
if isempty(assessment_ID)  % file input selected
[filename, pathname, filterind] = uigetfile({'*.csv'; '*.bin'; '*.optical'}, 'Pick file with assessment data', FILE_PATH, 'MultiSelect', 'off');
sweep = getSweep([pathname filename], TEMP_CSV);  % get sweep data, save csv file to temporary file
else    % url selected
    assessment = getAssessment(assessment_ID{1})
    sweep = getSweep(assessment.links.optical, TEMP_CSV); % get sweep data, save csv file to temporary file
end
if any(strcmpi(sweep.Device_id , DEVICE_EXCEPTION))    % find exceptions (usually devices that are out of commission
    warning(['Device ' sweep.Device_id ' in device exception list! Using previously stored device calibration file.']);
    [AllCnt,invC15,invC27] = getDeviceFile(sweep.Device_id); % use stored file instead
    [currents currents256] = getCurrents(device.hw_version); % get 25 nominal current values (Amps)
else
%try
    device = getDevice(sweep.Device_id);    % get device data
    [AllCnt,invC15,invC27] = getAllCnt( device, 1 ); % get most recent device calibration data
    [currents currents256] = getCurrents(device.hw_version); % get 25 nominal current values (Amps)
% catch err
%     if strcmp(err.identifier, 'Response stream is undefined')
%         warning(['Device ' sweep.device ' not found on server. Using generic calibration instead!']);
%         [temp currents] = getCurrents(); % get 256 nominal current values (Amps). Using default values
%         AllCnt = csvread('C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\AllCnt-8wv.csv');
%         invC = csvread('C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\invC.csv');
%         invC15 = [0.0017 -0.0003 -0.0005 0; -0.0018 0.0035 0.0046 -0.0019];
%         invC27 = invC15;
%     else
%         rethrow(err);
%     end
% end
end
%new_invHHb = [0.00400283955548958; -0.000593449697335217; -0.00124874933665490; 4.18536243246937e-05];
%new_invHbO2 = [-0.00410502224987000; 0.00796584804147946; 0.0105951716991859; -0.00439645439487845];

%% Data processing and Analysis

time = sweep.time;
[OD15, OD27] = processCounts(sweep, AllCnt, device.lookup_current, PP_THR, AMB_THR);
ODDiff = OD27-OD15; % differential OD
[ SmO2, R, mu_eff, HbF, Pk ] = calc_SmO2(ODDiff);
%mu_eff = calc_mu_eff(ODDiff); % calculate effective attenuation index
mu_s = calc_mu_s(leds, BODY_PART)/10; % if second argument is not set, calc_mu_s assumes we are monitoring a calf
mu_a = calc_mu_a(mu_eff,repmat(mu_s, numel(time),1)); % mu_eff.^2 ./ (3*repmat(mu_s, numel(time),1));   % absorption coefficient (1/mm)
% switch MU
%     case '\mu_eff'
%         mu = mu_eff;
%     case '\mu_a'
%         mu = mu_a;
% end

% Re-calculate Hb concentrations
cHb15 = OD15 * invC15';
cHb27 = OD27 * invC27';
    
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
tHb_15 = sum(cHb15,2);   % from re-calculated concentrations
tHb_27 = sum(cHb27,2);
HbF = pHbO2+pHhb;
HbConc = 5e4*HbF./pH2O; % hemoglobin concentration

% SmO2 calculations
SmO2_15 = 100*cHb15(:,2) ./ tHb_15;   % using re-calculated concentrations
SmO2_27 = 100*cHb27(:,2) ./ tHb_27;
sweep.SmO2_15 = 100*sweep.cHbO2_15mm ./ sweep.tHb_15;   % using device-calculated concentrations
sweep.SmO2_27 = 100*sweep.cHbO2_27mm ./ sweep.tHb_27;
%A = (HBO2 * HB') / (HB * HB');
%B = (HBO2 * HBO2') / (HB * HB');
%pcSmO2 = (mu * HBO2') ./ (mu * (HBO2 + HB*B)');   % vector projection

pSmO2 = pHbO2 ./ HbF;   % pseudo-inverse with H2O


ppSmO2 = processSmO2(pSmO2, MAP_METHOD, GAIN, FILTER_LENGTH, DIGITS);   % post-process
ppSmO2 = ppSmO2(1:sweep.samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
if isfield(sweep, 'SmO2')
    temp = sweep.SmO2;  % also process SmO2 value calculated by firmware
    temp(temp > 100) = NaN;  % replace 0x3FF and 0x3FE values with NaN
    sweep.SmO2 = temp;
end
dec_time = linspace(time(1), time(end), length(ppSmO2));    % decimated time
HbF = medfiltNaN(HbF, FILTER_LENGTH);   % LPF total hemoglobin
pH2O = medfiltNaN(pH2O, FILTER_LENGTH);
HbConc = medfiltNaN(HbConc, FILTER_LENGTH);
% Residual calculation
% R = mu - projections * fMat';
% R = sum(R.^2,2);  % calculate modulus over all wavelengths
% R = avgfiltNaN(R,round(FILTER_LENGTH/10));  % filter Residuals, using a faster filter so we don't miss spurious events

%% Plot results

fprintf('Average SmO2 = %2.2f\n', mean(ppSmO2(isfinite(ppSmO2))));
if length(ppSmO2) >= 200
    fprintf('Baseline SmO2 = %2.2f\n', prctile(ppSmO2(100:200),10));
end
%fprintf('Average Residual = %s. Max. Residual = %s\n', mean(R(isfinite(R))), max(R(isfinite(R)))); 
SmO2_99p = prctile(ppSmO2, 99);
SmO2_1p = prctile(ppSmO2,1);
fprintf('SmO2 99-percentile = %2.2f. 1-percentile = %2.2f. Delta = %2.2f\n', SmO2_99p, SmO2_1p, SmO2_99p-SmO2_1p);




%% PDF saving option

if isempty(assessment_ID)   % input file selected
    [pathstr,name,ext] = fileparts(filename);
    if filterind ~= 1   % selected file was not originally a CSV
        movefile(TEMP_CSV, [pathname '\' name '.csv'],'f'); % move CSV file to final destination, renaming it in the process
    end
    reply = questdlg('Save figures to file?');
    if strcmp(reply,'Yes')
        pdf_file = publish('Run_check_plot_pdf.m', 'outputDir', pathname, 'format', 'pdf','showCode', false); % saveAssessmentPPT([pathname name '.ppt'], ['Assessment of file ' pathname filename '\nAssessment number ' sweep.assessment '\nSport: ' sweep.sport '\n\nDevice number: ' sweep.Device_id ' Firmware version: ' sweep.FW_version '\nAssessment Date: ' sweep.date ' Assessment Time: ' sweep.UTCtime '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART]);
        movefile(pdf_file, [pathname '\' name '.pdf'],'f'); % move pdf file to final destination, renaming it in the process
    else
        Run_check_plot_pdf
    end
else
    pathname = uigetdir(FILE_PATH, 'Pick output file path');
    if pathname     % only save a powerpoint if user selected a path
        orient landscape
        pdf_file = publish('Run_check_plot_pdf.m', 'outputDir', pathname, 'format', 'pdf','showCode', false); %saveAssessmentPPT([pathname '\' assessment_ID{1} '.ppt'], ['Assessment from server.\nAssessment number ' assessment.alpha__id '\nSport: ' assessment.sport '  User id: ' assessment.user_id '\n\nDevice number: ' sweep.Device_id ' Firmware version: ' sweep.FW_version '\nAssessment Date: ' sweep.date ' Assessment Time: ' sweep.UTCtime '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART]);
        movefile(pdf_file, [pathname '\' assessment_ID{1} '.pdf'],'f'); % move pdf file to final destination, renaming it in the process
        movefile(TEMP_CSV, [pathname '\' assessment_ID{1} '.csv'],'f'); % move CSV file to final destination, renaming it in the process
    else
    Run_check_plot_pdf    
    end
end

%Run_Filter_Compare  % compare different filter candidates





