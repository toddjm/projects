%function blockOrientation();

% Script used to analyze data collected during block orientation DOE
%
% P. Silveira, Feb. 2015
%

%% Initialize
clear all
close all
deviceID = '0CEFAF8100E9';
DATE_START = '2015-02-19 00:00:00'; % start date to include in query
DATE_END = '2015-02-19 23:59:59';   % end date to include in query
leds = [665, 810, 850, 950];
DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format string
kk = 0; % checkouts counter
% pathname = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Calibration_DOE';
PASSFAIL_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Insight Calibration Files\CalibrationPassCriteriaModel.json';
INOMODEL_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Insight Calibration Files\inoBlockModel.json';

% oldpath = pwd;
% cd(pathname);
% [filename, pathname] = uigetfile('*SUCCESS*binallcnt.csv', 'Pick files with calibration data', 'MultiSelect', 'on');

h = fopen(PASSFAIL_PATH);   % open jason file with pass/fail criteria
str = fread(h,'*char');     % read file contents
fclose(h);
temp = parse_json(str');    % parse json data
MIN_PASS = cell2mat(temp.FullPwrAllCntMinThreshold);
MAX_PASS = cell2mat(temp.FullPwrAllCntMaxThreshold);
MuEffTol = temp.MuEffectiveTestMargin;   % mu_eff tolerance (%)

h = fopen(INOMODEL_PATH);   % open jason file with pass/fail criteria
str = fread(h,'*char');     % read file contents
fclose(h);
temp = parse_json(str');    % parse json data
MuEffNom = cell2mat(temp.MuEff);   % mu_eff tolerance (%)

dateStart = datenum(DATE_START, DATE_FORMAT);   % convert dates to date numbers
dateEnd = datenum(DATE_END, DATE_FORMAT);

%% Get data

device = getDevice(deviceID);    %, 'dateBegin', dateBegin, 'dateEnd', dateEnd);
for jj = numel(device.checkouts):-1:1;  % skip 1st checkout
    creation_date = datenum(device.checkouts{jj}.created_at, DATE_FORMAT);
    if (creation_date < dateStart | creation_date > dateEnd),   % ignore checkouts out of the desired date range
        continue
    end  
    str = device.checkouts{jj}.calibration_file; % select most recent calibration data
    out = base64decode(str);    % convert into decimal octets
    data = typecast(out(65:end), 'single'); % convert to float, ignoring first 2 rows
    if any(isnan(data)) % flag "false positive" devices
        warning(['Checkout contains NaNs in AllCnt matrix! Checkout # = ' num2str(jj)])
    end
    kk = kk + 1; % checkout is valid. Increment counter
    if device.checkouts{jj}.status,
        warning(['Device status = ' device.checkouts{jj}.status ' in ckeckout # ' num2str(jj)])
    end
    allData(kk,:,:) = reshape(data,8,25)';   % convert to 25x8 matrix
    temp = parse_json(device.checkouts{jj}.diagnostic_file);
    RMSError(kk,:) = cell2mat(temp.RMSErrorCrossGeometry);
    MuEff(kk,:) = cell2mat(temp.MuEffectiveMeasured);
    Bias(kk,:) = cell2mat(temp.BiasCrossGeometry);
end

num_checkouts = kk;   % number of valid runs


%% Data analysis

MaxAllCnt = squeeze(round(allData(:,end,:)));    % array of max counts

meanAllCnt = mean(MaxAllCnt,1);
stdAllCnt = std(MaxAllCnt,1);
meanMuEff = mean(MuEff,1);
stdMuEff = std(MuEff,1);
meanRMSErr = mean(RMSError,1);
stdRMSErr = std(RMSError,1);

%[rotFig, MaxAllCntRotStat, MuEffRotStat, RMSErrorRotStat] = CalcStats(ind1, ind2, MaxAllCnt, MuEff, RMSError);

%% Display results


figure(1)
subplot(2,1,1)
plot(MaxAllCnt','-+')
hold on
grid; axis tight
legend(num2str([1:8]'))
errorbar(meanAllCnt, stdAllCnt,'k-.', 'Linewidth', 2)
hold off
ylabel('counts/OD')
title('MaxAllCnt for all 432 blocks')
subplot(2,1,2)
boxplot(MaxAllCnt, 'notch', 'on')
ylabel('counts/OD')
title('MaxAllCnt for all 432 blocks')

figure(2)
subplot(2,1,1)
plot(MuEff','-+')
hold on
plot(MuEffNom,'r.')
grid; axis tight
legend(num2str([1:8]'))
errorbar(meanMuEff, stdMuEff,'k-.', 'Linewidth', 2)
hold off
ylabel('\mu_{eff} (1/cm)')
title('\mu_{eff} for all 432 blocks')
subplot(2,1,2)
boxplot(MuEff, 'notch', 'on')
ylabel('\mu_{eff} (1/cm)')
title('\mu_{eff} for all 432 blocks')

figure(3)
subplot(2,1,1)
plot(RMSError','-+')
hold on
grid; axis tight
legend(num2str([1:8]'))
errorbar(meanRMSErr, stdRMSErr,'k-.', 'Linewidth', 2)
hold off
title('RMS Error for all 432 blocks')
subplot(2,1,2)
boxplot(RMSError, 'notch', 'on')
title('RMS Error for all 432 blocks')

meanMueff
stdMuEff ./ meanMuEff * 100

%cd(oldpath)

% % Fine-tune plots
%     function FineTunePlots(fig, label1, label2, MAX_PASS, MIN_PASS, MuEff)
% figure(fig(1))
% subplot(3,3,1)
% title('MaxAllCnt')
% xlabel('LED')
% hold on
% plot(MAX_PASS,'r')
% plot(MIN_PASS,'r')
% hold off
% legend(label1, label2, 'Pass/Fail', 'Location', 'Best')
% subplot(3,3,4)
% title('MuEff')
% xlabel('Wavelength')
% hold on
% plot(MuEffNom,'r.')
% hold off
% legend(label1, label2, 'Nominal', 'Location', 'Best')
% subplot(3,3,7)
% title('RMS Error')
% xlabel('Wavelength')
% legend(label1, label2, 'Location', 'Best')
% 
% figure(fig(2))
% subplot(1,3,1)
% xlabel('LED')
% ylabel('Counts/OD')
% title('MaxAllCnt')
% subplot(1,3,2)
% xlabel('Wavelength')
% ylabel('\mu_{eff} (1/cm)')
% subplot(1,3,3)
% xlabel('Wavelength')
% ylabel('RMS Error')
% legend(label1, label2, 'Location', 'Best')
% xlabel('Wavelength')
% end
% 
% % Calculate statistics
%     function [fig, varargout] = CalcStats(indata1, indata2, varargin);
%         numcalc = numel(varargin);
%         fig(1) = figure;
%         fig(2) = figure;
%         for ii = 1:numcalc      % loop through input variables (MaxAllCnt, mu_eff, RMSError, etc)
%             temp = varargin{ii};
%             data1 = temp(ind1,:);
%             data2 = temp(ind2,:);
%             varargout{ii}.mean1 = mean(data1,1);
%             varargout{ii}.mean2 = mean(data2,1);
%             varargout{ii}.std1 = std(data1,1);
%             varargout{ii}.std2 = std(data2,1);
%             varargout{ii}.dist1 = (varargout{ii}.mean1 - varargout{ii}.mean2) ./ varargout{ii}.std1;
%             varargout{ii}.dist2 = (varargout{ii}.mean2 - varargout{ii}.mean1) ./ varargout{ii}.std2;
%             varargout{ii}.max1 = max(data1,1);
%             varargout{ii}.max2 = max(data2,1);
%             varargout{ii}.min1 = min(data1,1);
%             varargout{ii}.min2 = min(data2,1);
%             
%             % Plot
%             %             varargout{ii}.fig = figure;
%             
%             figure(fig(1))
%             subplot(3,numcalc, 3*ii-2)
%             errorbar(varargout{ii}.mean1, varargout{ii}.std1)
%             hold on
%             errorbar(varargout{ii}.mean2, varargout{ii}.std2,'g')
%             ylabel('Mean')
%             grid
%             hold off
%             subplot(3,numcalc, 3*ii-1)
%             plot(varargout{ii}.std1)
%             hold on
%             plot(varargout{ii}.std2, 'g')
%             ylabel('Std. dev')
%             grid
%             hold off
%             subplot(3,numcalc, 3*ii)
%             plot(varargout{ii}.dist1)
%             ylabel('Dist. between means (std)')
%             hold on
%             plot(varargout{ii}.dist2, 'g')
%             grid
%             hold off
%             set(gcf, 'Position', [14 -46 560*numcalc 800]);
%             
%             figure(fig(2))
%             subplot(1, numcalc, ii)
%             plot(data1','b+')
%             hold on
%             plot(data2','go')
%             plot(data1','b')
%             plot(data2','g')
%             grid
%         end
%         hold off
%         set(gcf, 'Position', [99 212 320*numcalc 420]);
%     end
% end