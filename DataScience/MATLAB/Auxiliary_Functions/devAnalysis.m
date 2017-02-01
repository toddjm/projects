function device = devAnalysis(device_id, checkout, pptfile)
% function devAnalysis(device_id, checkout)
% Function used to analyze calibration data from a single device
%
% Inputs
% device_id - A string with the device mac ID or a device structure obtained from getDevice
% checkout - device checkout number. Default = 1 (most recent checkout).
% Use 'end' to report very first checkout.
% pptfile - complete path of PowerPoint file in which to save results. Asks
% user whether to save results in a file if empty. Doesn't ask anything if
% = 'none'
%
% Outputs
% Displays device structure and plots MaxAllCnt, RMSError, mu_eff vs current and count
% sweeps vs time
%
% See also
% getDevice, getSweep, calibPassFail, getAllCnt, SingleAllCntAnalysis, AllCntAnalysis
%
% P. Silveira, Feb. 2015.
% BSX Athletics Proprietary

%% Initialize

FONTSIZE = 12;  % size of font used in plots
[wavel, leds] = getLeds; %[665, 810, 850, 950];  % get centroid wavelengths and nominal LED values
numLeds = numel(leds);

if ~exist('checkout', 'var')
    checkout = 1; % which checkout to display. Use 1 for most recent.
end

%% Data input
if ~exist('device_id','var')
    device_id = input('Enter device MAC address or complete path to binallcnt.csv file: ','s');
    str = input('Enter checkout number (DEFAULT = most recent): ', 's');
    if ~isempty(str),
        checkout = str2num(str);
    end
end
% if ~isstruct(device_id) && exist(device_id, 'file')   % AllCnt file entered as input
%     data = csvread(device_id,3,0);  % Read file, skipping first 3 rows (header)
%     AllCnt(:,:) = data(:,1:end-1);   % save all data, ignoring last column (blank)
if ~isstruct(device_id)     % device_id is a device structure. No need to re-use getDevice
    device_id = removeChar(device_id, '-');
    device = getDevice(device_id);
else
    device = device_id;
    device_id = device.device_id;
end
if strcmpi(checkout, 'end') % replace string with number
    checkout = numel(device.checkouts);
end
[ AllCnt, invC15, invC27, lookup_current, diag, sweep ] = getAllCnt(device, checkout);
RMSError = cell2mat(diag.RMSErrorCrossGeometry);
% Read file with pass/fail criteria
[ MAX_PASS, MIN_PASS, MuEffNom, MuError, MuEffTol, RMSErrorMAX ] = calibPassFail(device.hw_version);
[currents currents256] = getCurrents(device.hw_version);
deviceMuEffNom = cell2mat(diag.MuEffectiveNominal); % get nominal mu_eff stored in device checkout
MuEff = cell2mat(diag.MuEffectiveMeasured);
deviceMuError = deviceMuEffNom * MuEffTol;  % calculate mu_eff maximum acceptable error



%% Data analysis

maxCnt = AllCnt(end,:);
ratio = sweep.count27./sweep.count15;
ratio = ratio .* (ratio > 0);   % remove negative values
logRatio = log10(ratio);
mu_eff = calc_mu_eff(-logRatio);    % calculate estimated mu_eff (1/mm)
current15 = currents256(sweep.ccode15+1);   % assuming 15mm and 27mm geometries use the same sweeps, so a single current is enough
%current15 = ccode2Amp(sweep.ccode15, device.lookup_current, currents);

%% Display results

figure(1); clf
set(gcf, 'Position', [16 340 560 420]);
plot(maxCnt,'k')
hold on
plot(MAX_PASS,'r')
plot(MIN_PASS,'r')
hold off
grid
xlabel('LED', 'FontSize', FONTSIZE)
ylabel('Counts/Transmission', 'FontSize', FONTSIZE)
title(['MaxAllCnt of device ' device.device_id], 'Fontsize', FONTSIZE)
legend('Device', 'Tolerances', 'Location', 'Best')

figure(2); clf
set(gcf, 'Position', [595 341 560 420]);
surf([1:2*numLeds], currents, double(AllCnt))
xlabel('LEDs')
ylabel('Currents (Amp)')
zlabel('Counts/Transmission')
title('AllCnt matrix')
axis tight

%if exist('device', 'var')

figure(3); clf
set(gcf, 'Position', [1173 340 560 420]);
plot(wavel, MuEff,'k+')
hold on
plot(wavel, MuEffNom,'r.')
xlabel('wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('\mu_{eff} (1/cm)', 'FontSize', FONTSIZE)
title(['\mu_{eff} of device ' device.device_id], 'Fontsize', FONTSIZE)
if spower(MuEffNom - deviceMuEffNom) > eps, % show difference in current nominal mu_eff and that used when device was calibrated
    errorbar(wavel, deviceMuEffNom, deviceMuError, 'b.')
    plot(wavel, deviceMuEffNom, 'b-')
    legend('Measured', 'Current Nominal', 'Previous nominal', 'Location', 'Best')
else
    legend('Measured', 'Nominal', 'Location', 'Best')
end
plot(wavel, MuEffNom,'r-')
plot(wavel, MuEff,'k-')
errorbar(wavel, MuEffNom, MuError, 'r.')
grid
hold off
axis tight


figure(4); clf
set(gcf, 'Position', [20 -186 560 420]);
plot(wavel, RMSError, 'b+', 'linewidth', 2)
xlabel('LED wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('RMS Error (a.u.)', 'FontSize', FONTSIZE)
title(['RMS Error for device ' device.device_id], 'Fontsize', FONTSIZE)
hold on
grid
plot(wavel, RMSErrorMAX*ones(numLeds), 'r-')
hold off
axis([wavel(1)-10 wavel(end)+10 0 max([RMSErrorMAX RMSError(:)'])])
legend('RMS Errors', 'Threshold', 'Location', 'Best')

fprintf('Device %s, hw_version = %s, id = %s\n', device.device_id, device.hw_version, device.id)
fprintf('Showing checkout number %d out of %d checkouts\n', checkout, numel(device.checkouts))
device.checkouts{checkout}

% Plot current sweep results
figure(5); clf
set(gcf, 'Position', [597 -183 560 420]);
plot(sweep.time, sweep.ambient)
xlabel('time (s)', 'FontSize', FONTSIZE)
ylabel('Ambient light (counts)', 'FontSize', FONTSIZE)
title('Ambient light during calibration', 'Fontsize', FONTSIZE)
grid; axis tight

figure(6); clf
set(gcf, 'Position', [1174 -182 560 420]);
figure(7); clf
set(gcf, 'Position', [522 5 696 525]);

for LEDNum = 1:numLeds,
    
    figure(6)
    subplot(2,1,1)
    plot(sweep.time, sweep.count15)
    xlabel('time (s)')
    ylabel('Counts')
    title('15mm LED sweep')
    grid; axis tight
    legend(leds)
    subplot(2,1,2)
    plot(sweep.time, sweep.count27)
    xlabel('time (s)')
    ylabel('Counts')
    title('27mm LED sweep')
    grid; axis tight
    legend(leds)
    
    figure(7)
    %      subplot(2,2,LEDNum)
    %      plot(current15(:,LEDNum), OD27r(:, LEDNum),'+')
    %      xlabel('Current')
    %      ylabel('OD @ 27mm estimated from ratios')
    %      title(strcat('Current sweep, log scale, for INO 432, LED ',num2str(leds(LEDNum))))
    %      axis tight; grid
    % %     legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
    %
    %      figure(5)
    %      subplot(2,2,LEDNum)
    %      plot(current15(:,LEDNum), OD15r(:,LEDNum),'+')
    %      xlabel('Current')
    %      ylabel('OD @ 15mm estimated from ratios')
    %      title(strcat('Current sweep, log scale, for INO 432, LED ',num2str(leds(LEDNum))))
    %      axis tight; grid
    %  %    legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
    
    %     figure(6)
    subplot(2,2,LEDNum)
    plot(current15(:,LEDNum), mu_eff(:,LEDNum)*10,'+')
    xlabel('Current, 15mm geometry (Amp)')
    ylabel('\mu_{eff}(1/cm)')
    title(['Current sweep for INO 432, LED ',leds{LEDNum}])
    grid
    axis([0 max(current15(:,LEDNum)) min(mu_eff(:,LEDNum)*10) max(mu_eff(:,LEDNum)*10)])
    %   legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
    
end

reply = '';
if ~exist('pptfile', 'var')
    reply = questdlg('Save figures to PowerPoint file?');
end
if (exist('pptfile', 'var') && ~strcmp(pptfile, 'none')) || strcmp(reply,'Yes')
    saveAssessmentPPT([pwd '\' 'Calibration_Analysis_device_' device_id '.ppt'], ['Analysis of calibration of device ' device_id '\nCheckout number: ' num2str(checkout) ' out of ' num2str(numel(device.checkouts))]);
end
%end

end

