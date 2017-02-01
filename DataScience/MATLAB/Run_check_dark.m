% Script used to analyze data from dark sensors
% P. Silveira, Aug. 2015
% BSX Athletics Proprietary
%

%% Initialize
clear all
close all

% System parameters
[temp leds] = getLeds; % get LED nominal wavelengths
num_leds = length(leds)*2;
DEVICE_EXCEPTION = {'0CEFAF810086'};    % device exception list

% Path parameters
FONTSIZE = 11;  % size of fonts used in plots
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Ambient light with sleeve modifications\Ambient light with dark unit\'];
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
%FILE_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Assessment Analysis';

% Processing parameters
%BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'
%PP_THR = -32;    % post-processing threshold (counts)
%AMB_THR = 2^15-1; % ambient light threshold (counts)
AMB_DROP_THR = 0.1; %0.015; % threshold value for difference in ambient light signals. Difference in ambient counts > this threshold are dropped.
%MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
%IP_METHOD = 'pseudo-H2O';   % inner-product method. Choose between 'cosine', 'vector projection', 'pseudo-inverse' and 'pseudo-H2O'
%GAIN = 1.6;   % scaling function gain factor
%MAP_METHOD = 'softsig';  % mapping method
%DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
%FILTER_LENGTH = 75;    % length of filter (samples)
%UPDATE_RATE = 1;    % update rate (Hz)

%% Data input
[filename, pathname, filterind] = uigetfile({'*.csv'; '*.bin'; '*.optical'}, 'Pick file with assessment data', FILE_PATH, 'MultiSelect', 'off');
sweep = getSweep([pathname filename], TEMP_CSV);  % get sweep data, save csv file to temporary file
if any(strcmpi(sweep.Device_id , DEVICE_EXCEPTION))    % find exceptions (usually devices that are out of commission
    warning(['Device ' sweep.Device_id ' in device exception list! Using previously stored device calibration file.']);
    [AllCnt,invC15,invC27] = getDeviceFile(sweep.Device_id); % use stored file instead
    currents = getCurrents; % get 25 nominal current values (Amps)
else
try
    device = getDevice(sweep.Device_id);    % get device data
    [AllCnt,invC15,invC27,diag] = getAllCnt( device, 1 ); % get most recent device calibration data
    if isfield('device', 'hw_version')
        currents = getCurrents(device.hw_version); % get 25 nominal current values (Amps)
    else
        currents = getCurrents();    % use default values if HW version is not defined
    end
catch err
    if strcmp(err.identifier, 'Response stream is undefined')
        warning(['Device ' sweep.device ' not found on server. Using generic calibration instead!']);
        [temp currents] = getCurrents(); % get 256 nominal current values (Amps). Using default values
        AllCnt = csvread('C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\AllCnt-8wv.csv');
        invC = csvread('C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\invC.csv');
        invC15 = [0.0017 -0.0003 -0.0005 0; -0.0018 0.0035 0.0046 -0.0019];
        invC27 = invC15;
    else
        rethrow(err);
    end
end
end

%% Data processing and Analysis

time = sweep.time;


%% Ambient light analysis

count15_drop = sweep.count15;   % 15mm signals with differences in ambient light > AMB_THR_DROP rejected
count27_drop = sweep.count27;   % 27mm signals with differences in ambient light > AMB_THR_DROP rejected
for ii = 1:length(time)
    A2 = sweep.count27(ii,4); %sweep.ambient(ii) + sweep.count27(ii,4);    % instantaneous second reading
    A1 = sweep.count15(ii,1); % sweep.ambient(ii)
    for jj = 1:num_leds
%        interp_amb(jj) = -sweep.ambient(ii) - (((num_leds-jj)/num_leds)*sweep.ambient(ii) + jj/num_leds*A2);  % linearly interpolate between first and last ambient light readings
        interp_amb(jj) = jj/num_leds*sweep.count27(ii,4);  % linearly interpolate between first and last ambient light readings
    end
    count15_subtract(ii,:) = sweep.count15(ii,:) - interp_amb(1:num_leds/2);   % signals with interpolated values in ambient light subtracted
    count27_subtract(ii,:) = sweep.count27(ii,:) - interp_amb(num_leds/2+1:end);
    count15_combined(ii,:) = count15_subtract(ii,:);
    count27_combined(ii,:) = count27_subtract(ii,:);
%    meanA = (A2 + sweep.ambient(ii))/2; % mean ambient reading
%    deltaA = A2 - sweep.ambient(ii);    % delta in ambient reading
    threshold = abs((A2 - A1)*9/7) ./ (sweep.ambient(ii) + 16e3);
%    if  abs(sweep.count27(ii,4)) > AMB_DROP_THR % drop counts in which ambient light varies too much
%    if  abs(deltaA ./ meanA) > AMB_DROP_THR % drop counts in which ambient light varies too much
    if  threshold > AMB_DROP_THR % drop counts in which ambient light varies too much
        count15_drop(ii,:) = NaN;
        count27_drop(ii,:) = NaN;
        count15_combined(ii,:) = NaN;
        count27_combined(ii,:) = NaN;
    end
end

%A2 = sweep.ambient + sweep.count27(:,4);    % instantaneous second reading
%meanA = (A2 + sweep.ambient)/2; % mean ambient reading
%deltaA = A2 - sweep.ambient;    % delta in ambient reading
A2 = sweep.count27(:,4);
A1 = sweep.count15(:,1);
threshold = abs((A2 - A1)*9/7) ./ (sweep.ambient + 16e3);

npower15_detected = round(spower(sweep.count15));
npower27_detected = round(spower(sweep.count27));
npower15_subtract = round(spower(count15_subtract));
npower27_subtract = round(spower(count27_subtract));
npower15_drop = round(spower(count15_drop));
npower27_drop = round(spower(count27_drop));
npower15_combined = round(spower(count15_combined));
npower27_combined = round(spower(count27_combined));

%% Plot results

close all
% fprintf('Average SmO2 = %2.2f\n', mean(ppSmO2(isfinite(ppSmO2))));
% if length(ppSmO2) >= 200
%     fprintf('Baseline SmO2 = %2.2f\n', prctile(ppSmO2(100:200),10));
% end
% fprintf('Average Residual = %s. Max. Residual = %s\n', mean(R(isfinite(R))), max(R(isfinite(R)))); 

%Run_check_plot  % plot results
LEDlabels = cellstr(num2str(leds'));

figure  % Ambient light
plot(time, sweep.ambient)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Ambient light','FontSize', FONTSIZE)

figure % Original
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
plot(time, sweep.count15)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('15mm counts','FontSize', FONTSIZE)
title('Detected counts','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower15_detected)])
ax(2) = subplot(2,1,2);
plot(time, sweep.count27)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('27mm counts','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower27_detected)])
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure % Linear interpolation
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
plot(time, count15_subtract)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('15mm counts','FontSize', FONTSIZE)
title('Linear interpolation method','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower15_subtract)])
ax(2) = subplot(2,1,2);
plot(time, count27_subtract)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('27mm counts','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower27_subtract)])
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure % Threshold drop interpolation
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
plot(time, count15_drop)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('15mm counts','FontSize', FONTSIZE)
title('Threshold drop method','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower15_drop)])
ax(2) = subplot(2,1,2);
plot(time, count27_drop)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('27mm counts','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower27_drop)])
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure % Combined method
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
plot(time, count15_combined)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('15mm counts','FontSize', FONTSIZE)
title('Combined method','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower15_combined)])
ax(2) = subplot(2,1,2);
plot(time, count27_combined)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('27mm counts','FontSize', FONTSIZE)
text(50,70,['Noise power = ' num2str(npower27_combined)])
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure % Relative threshold
plot(time, threshold)
hold on
plot(time, ones(size(time))*AMB_DROP_THR, 'r-.')
hold off
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('Threshold signal (a.u.)','FontSize', FONTSIZE)
title('Relative ambient light variation','FontSize', FONTSIZE)
legend('Rel. var.', 'Threshold', 'Location', 'Best')

%% PowerPoint saving option

[pathstr,name,ext] = fileparts(filename);
if filterind ~= 1   % selected file was not originally a CSV
    movefile(TEMP_CSV, [pathname '\' name '.csv'],'f'); % move CSV file to final destination, renaming it in the process
end
reply = questdlg('Save figures to PowerPoint file?');
if strcmp(reply,'Yes')
    saveAssessmentPPT([pathname name '.ppt'], ['Assessment of file ' pathname filename '\nAssessment number ' sweep.assessment '\nSport: ' sweep.sport '\n\nDevice number: ' sweep.Device_id ' Firmware version: ' sweep.FW_version '\nAssessment Date: ' sweep.date ' Assessment Time: ' sweep.UTCtime '\n\nAnalysis date: ' date '\nThreshold value = ' num2str(AMB_DROP_THR)]);
end

