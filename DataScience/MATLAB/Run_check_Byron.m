% Script used to analyze LT assessment runs
%
% BSX Athletics Proprietary

%% Initialize
clear all
close all

leds = [664  799  846  932];    % led centroid wavelengths
FONTSIZE = 11;  % size of fonts used in plots
FILE_PATH = '';
[HB,HBO2] = prahlhb(leds);   % get absorption spectra
HB = HB/10;%*log(10); %change from cm-1 to mm-1
HBO2 = HBO2/10;%*log(10); %change from cm-1 to mm-1
MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
PP_THR = 10;    % post-processing threshold (counts)
IP_METHOD = 'pseudo-inverse';   % inner-product method. Choose between 'cosine', 'vector projection' and 'pseudo-inverse'
BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'

%% Data input
[filename, pathname, filterind] = uigetfile('*.csv', 'Pick file with assessment data', FILE_PATH, 'MultiSelect', 'off');
sweep = getCSV([pathname filename]);  % get sweep data
[AllCnt,invC15,invC27] = getDeviceFile(sweep.Device_id);    % get device data
%new_invHHb = [0.00400283955548958; -0.000593449697335217; -0.00124874933665490; 4.18536243246937e-05];
%new_invHbO2 = [-0.00410502224987000; 0.00796584804147946; 0.0105951716991859; -0.00439645439487845];
currents = getCurrents; % get 25 nominal current values (Amps)

%% Data processing and Analysis

time = sweep.time;
[OD15, OD27] = processCounts(sweep, AllCnt, currents, PP_THR);
ODDiff = OD27-OD15; % differential OD
mu_eff = 0.192*ODDiff - 0.098;  % mu_eff (1/mm) from Delta OD %-0.98 - 1.92*log10(trans15 ./ trans27);
mu_s = calc_mu_s(leds, BODY_PART)/10; % if second argument is not set, calc_mu_s assumes we are monitoring a calf
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

% SmO2 calculations
SmO2_15 = sweep.cHbO2_15mm ./ (sweep.cHbO2_15mm + sweep.cHhb_15mm);    % using concentrations reported by the device
SmO2_27 = sweep.cHbO2_27mm ./ (sweep.cHbO2_27mm + sweep.cHhb_27mm);
newSmO2_27 = cHb27(:,2) ./ sum(cHb27,2);   % using re-calculated concentrations
newSmO2_15 = cHb15(:,2) ./ sum(cHb15,2);
A = (HBO2 * HB') / (HB * HB');
B = (HBO2 * HBO2') / (HB * HB');

switch IP_METHOD
    case 'cosine'
        pSmO2 = (mu * HBO2') ./ (mu * (HBO2 + HB*sqrt(B))');   % cosine method
    case 'vector projection'
        pSmO2 = (mu * HBO2') ./ (mu * (HBO2 + HB*B)');   % vector projection
    case 'pseudo-inverse'
        pSmO2 = (mu * (HBO2 - A*HB)') ./ (mu * (HBO2*(1-A) + HB*(B - A))');   % pseudo-inverse
    otherwise
        error(['Invalid inner-product method = ' PP_METHOD])
end

%% Plot results

figure  % counts 15mm
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
if isfield(sweep, 'current15')
    plot(time, sweep.current15)
end
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('current (mA)','FontSize', FONTSIZE)
title('Currents @ 15mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
ax(2) = subplot(2,1,2);
plot(time, sweep.count15)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Counts @ 15mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure  % counts 27mm
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
if isfield(sweep, 'current15')
    plot(time, sweep.current27)
end
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('current (mA)','FontSize', FONTSIZE)
title('Currents @ 27mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
ax(2) = subplot(2,1,2);
plot(time, sweep.count27)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Counts @ 27mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure % ODs
set(gcf, 'Position', [636 0 791 1025]);
ax(1) = subplot(3,1,1);
plot(time, OD15)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('ODs @ 15mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
ax(2) = subplot(3,1,2);
plot(time, OD27)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('ODs @ 27mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
ax(3) = subplot(3,1,3);
plot(time, ODDiff)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('Differential OD','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together

figure  % mu
set(gcf, 'Position', [636 0 791 874]);
subplot(2,1,1)
plot(time, mu_eff*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{eff} (1/cm)','FontSize', FONTSIZE)
title('\mu_{eff} over time','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')), 'Location', 'Best')
subplot(2,1,2)
plot(time, mu_a*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{a} (1/cm)','FontSize', FONTSIZE)
title('\mu_{a} over time','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')), 'Location', 'Best')

figure   % SmO2, 15mm
set(gcf, 'Position', [20 0 560 1007]);
subplot(3,1,1)
plot(time, sweep.cHbO2_15mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Device calculations - 15mm','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, sweep.cHhb_15mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, SmO2_15*100)
grid
axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)

figure % SmO2, 27mm
set(gcf, 'Position', [20 0 560 1007]);
ax(1) = subplot(3,1,1);
plot(time, sweep.cHbO2_27mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Device calculations - 27mm','FontSize', FONTSIZE)
ax(2) = subplot(3,1,2);
plot(time, sweep.cHhb_27mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
ax(3) = subplot(3,1,3);
plot(time, SmO2_27*100)
grid; axis tight
%axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)
linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together

figure % SmO2, 15mm
set(gcf, 'Position', [20 0 560 1007]);
subplot(3,1,1)
plot(time, cHb15(:,2))
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Direct calculation - 15mm','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, cHb15(:,1))
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, newSmO2_15*100)
grid; axis tight
%axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)

figure % SmO2, 27mm
set(gcf, 'Position', [20 0 560 1007]);
subplot(3,1,1)
plot(time, cHb27(:,2))
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Direct calculation - 27mm','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, cHb27(:,1))
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, newSmO2_27*100)
grid; axis tight
%axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)

figure   % Projection SmO2
plot(time, pSmO2*100)
grid
axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)

fprintf(1, 'Assessment date: %s. Assessment time: %s UTC.\n', sweep.date, sweep.UTCtime)
fprintf(1, 'Device : %s\n', sweep.Device_id)



