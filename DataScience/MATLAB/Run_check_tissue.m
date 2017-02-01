% Script used to analyze LT assessment run from a CSV or binary files
% P. Silveira, July 2015
% Last modified: July 2015.
% BSX Athletics Proprietary
%

%% Initialize
clear all
close all

% System parameters
[temp, leds] = getLeds; % get LED centroid wavelengths
FONTSIZE = 11;  % size of fonts used in plots

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Tissue detection'];
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];

% Processing parameters
AVG_RANGE = [20:40]*5;  % use first 20 to 40s (tissue data) to calculate averaged ratios. Assumes 5Hz sampling ratio.
BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'
PP_THR = 1;    % post-processing threshold (counts). Make it very low to avoid NaNs
AMB_THR = 40000; % ambient light threshold (counts). Make it very high to avoid NaNs
MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
%IP_METHOD = 'pseudo-H2O';   % inner-product method. Choose between 'cosine', 'vector projection', 'pseudo-inverse' and 'pseudo-H2O'
GAIN = 1.6;   % scaling function gain factor
MAP_METHOD = 'softsig';  % mapping method
%DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
FILTER_LENGTH = 10;    % length of filter (samples)
%UPDATE_RATE = 5;    % update rate (Hz)

%% Data input
assessment_ID = input('Enter assessment ID number (blank for file): ', 's');
if isempty(assessment_ID)  % file input selected
[filename, pathname, filterind] = uigetfile({'*.csv'; '*.bin'; '*.optical'}, 'Pick file with assessment data', FILE_PATH, 'MultiSelect', 'off');
sweep = getSweep([pathname filename], TEMP_CSV);  % get sweep data, save csv file to temporary file
else    % url selected
    assessment = getAssessment(assessment_ID)
    sweep = getSweep(assessment.links.optical, TEMP_CSV); % get sweep data, save csv file to temporary file
end
try
    device = getDevice(sweep.Device_id);    % get device data
    [AllCnt,invC15,invC27,diag] = getAllCnt( device, 1 ); % get most recent device calibration data
    currents = getCurrents; % get 25 nominal current values (Amps)
catch err
    if strcmp(err.identifier, 'Response stream is undefined')
        warning(['Device ' sweep.device ' not found on server. Using generic calibration instead!']);
        [temp currents] = getCurrents; % get 256 nominal current values (Amps)
        AllCnt = csvread('C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\AllCnt-8wv.csv');
        invC = csvread('C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\invC.csv');
        invC15 = [0.0017 -0.0003 -0.0005 0; -0.0018 0.0035 0.0046 -0.0019];
        invC27 = invC15;
    else
        rethrow(err);
    end
%end
end

%% Data processing and Analysis

time = sweep.time;
sweep.count15(sweep.count15<=PP_THR) = PP_THR;    % Get rid of zeros or negative values
sweep.count27(sweep.count27<=PP_THR) = PP_THR;
[OD15, OD27] = processCounts(sweep, AllCnt, currents, PP_THR, AMB_THR);
for ii = 1:numel(leds)  % pre-filter counts to avoid spurious results 
    sweep.count15(:,ii) = avgfiltNaN(sweep.count15(:,ii), FILTER_LENGTH);
    sweep.count27(:,ii) = avgfiltNaN(sweep.count27(:,ii), FILTER_LENGTH);
    OD15(:,ii) = avgfiltNaN(OD15(:,ii), FILTER_LENGTH);
    OD27(:,ii) = avgfiltNaN(OD27(:,ii), FILTER_LENGTH);
end
ODDiff = OD27-OD15; % differential OD
[ SmO2, R, mu_eff, HbF, Pk ] = calc_SmO2(ODDiff);
%mu_eff = calc_mu_eff(ODDiff); % calculate effective attenuation index
mu_s = calc_mu_s(leds, BODY_PART); % if second argument is not set, calc_mu_s assumes we are monitoring a calf
mu_a = calc_mu_a(mu_eff,repmat(mu_s, numel(time),1)); % mu_eff.^2 ./ (3*repmat(mu_s, numel(time),1));   % absorption coefficient (1/mm)
switch MU
    case '\mu_eff'
        mu = mu_eff;
    case '\mu_a'
         mu = mu_a;
end

% Re-calculate Hb concentrations
cHb15 = OD15 * invC15';
cHb27 = OD27 * invC27';
    
% Spatially-resolved projection calculations
pHhb = Pk(:,1);
pHbO2 = Pk(:,2);
pH2O = Pk(:,3);

% Total Hemoglobin calculations
sweep.tHb_15 = sum(cHb15,2);   % from re-calculated concentrations
sweep.tHb_27 = sum(cHb27,2);
HbF = pHbO2+pHhb;
HbConc = 5e4*HbF./pH2O; % hemoglobin concentration

% SmO2 calculations
sweep.SmO2_15 = cHb15(:,2) ./ sweep.tHb_15;   % using re-calculated concentrations
sweep.SmO2_27 = cHb27(:,2) ./ sweep.tHb_27;
pSmO2 = pHbO2 ./ HbF;   % pseudo-inverse with H2O

ppSmO2 = processSmO2(pSmO2, MAP_METHOD, GAIN);   % post-process
%ppSmO2 = processSmO2(pSmO2, MAP_METHOD, GAIN, FILTER_LENGTH);   % post-process
%ppSmO2 = ppSmO2(1:sweep.samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
if isfield(sweep, 'SmO2')
    temp = sweep.SmO2;  % also process SmO2 value calculated by firmware
    temp(temp > 100) = NaN;  % replace 0x3FF and 0x3FE values with NaN
    sweep.SmO2 = temp;
end
dec_time = linspace(time(1), time(end), length(ppSmO2));    % decimated time
% HbF = avgfiltNaN(HbF, FILTER_LENGTH);   % LPF total hemoglobin
% pH2O = avgfiltNaN(pH2O, FILTER_LENGTH);
% pHhb = avgfiltNaN(pHhb, FILTER_LENGTH);
% pHbO2 = avgfiltNaN(pHbO2, FILTER_LENGTH);
% HbConc = avgfiltNaN(pH2O, FILTER_LENGTH);
% sweep.tHb_15 = avgfiltNaN(sweep.tHb_15, FILTER_LENGTH);
% sweep.tHb_27 = avgfiltNaN(sweep.tHb_27, FILTER_LENGTH);
% %OD15 = avgfiltNaN(OD15, FILTER_LENGTH);
% %OD27 = avgfiltNaN(OD27, FILTER_LENGTH);
% %ODDiff = avgfiltNaN(ODDiff, FILTER_LENGTH);
% %mu_eff = avgfiltNaN(mu_eff, FILTER_LENGTH);
% %mu_a = avgfiltNaN(mu_a, FILTER_LENGTH);
% cHb15 = avgfiltNaN(cHb15, FILTER_LENGTH);
% cHb27 = avgfiltNaN(cHb27, FILTER_LENGTH);
% sweep.SmO2_15 = avgfiltNaN(sweep.SmO2_15, FILTER_LENGTH);
% sweep.SmO2_27 = avgfiltNaN(sweep.SmO2_27, FILTER_LENGTH);
% % Residual calculation
% %R = mu - Pk * fMat';
% %R = sum(R.^2,2);  % calculate modulus over all wavelengths
% R = avgfiltNaN(R,FILTER_LENGTH);  % filter Residuals, using a faster filter so we don't miss spurious events

count15Ratio = avg_ratio(sweep.count15, AVG_RANGE);
count27Ratio = avg_ratio(sweep.count15, AVG_RANGE);
H2ORatio = avg_ratio(pH2O, AVG_RANGE);
RRatio = avg_ratio(R, AVG_RANGE);
mu_aRatio = avg_ratio(mu_a, AVG_RANGE);
HbFRatio = avg_ratio(HbF, AVG_RANGE);
HbConcRatio = avg_ratio(HbConc, AVG_RANGE);

%% Plot results

fprintf('Average SmO2 = %2.2f\n', mean(ppSmO2(isfinite(ppSmO2))));
fprintf('Baseline SmO2 = %2.2f\n', prctile(ppSmO2(100:200),10));
fprintf('Average Residual = %s. Max. Residual = %s\n', mean(R(isfinite(R))), max(R(isfinite(R)))); 

figure
set(gcf, 'Position', [636 0 791 1025]);
subplot(3,1,1)
plot(time, count15Ratio)
grid; axis([time(1) time(end) 0 3])
legend({num2str(leds')},'Location', 'Best')
xlabel('time(s)','FontSize', FONTSIZE)
ylabel('15mm count ratio','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, count27Ratio)
grid; axis([time(1) time(end) 0 3])
xlabel('time(s)','FontSize', FONTSIZE)
ylabel('27mm count ratio','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, RRatio)
grid; axis([time(1) time(end) 0 10])
xlabel('time(s)','FontSize', FONTSIZE)
ylabel('Residual ratio','FontSize', FONTSIZE)

figure
set(gcf, 'Position', [636 0 791 1025]);
subplot(3,1,1)
plot(time, H2ORatio)
grid; axis([time(1) time(end) 0 3])
xlabel('time(s)','FontSize', FONTSIZE)
ylabel('Hydration index ratio','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, HbFRatio)
grid; axis([time(1) time(end) 0 3])
xlabel('time(s)','FontSize', FONTSIZE)
ylabel('Hb fraction ratio','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, HbConcRatio)
grid; axis([time(1) time(end) 0 3])
xlabel('time(s)','FontSize', FONTSIZE)
ylabel('Hb conc. ratio','FontSize', FONTSIZE)

Run_check_plot  % plot results






