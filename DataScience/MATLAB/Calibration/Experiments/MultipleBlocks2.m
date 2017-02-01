%function blockOrientation();

% Script used to analyze data collected during multiple block DOE
%
% P. Silveira, Feb. 2015
%

%% Initialize
clear all
close all
deviceID = '0CEFAF8100E9';
DATE_START = '2015-02-19 00:00:00'; % start date to include in query
DATE_END = '2015-02-20 23:59:59';   % end date to include in query
leds = [665, 810, 850, 950];
DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format string
%kk = 0; % checkouts counter
block = 0;  % block counter
time = 1;   % time counter
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
MuError = MuEffNom * MuEffTol;  % calculate mu_eff maximum acceptable error

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
%    kk = kk + 1; % checkout is valid. Increment counter
    block = block + 1;
    if block > 8,   % reset block number after the 8th block
        block = 1;
        time = time + 1;
    end
    
%    cr_date{kk} = device.checkouts{jj}.created_at;
        
        
    if device.checkouts{jj}.status,
        warning(['Device status = ' device.checkouts{jj}.status ' in ckeckout # ' num2str(jj)])
    end
    allData(time, block,:,:) = reshape(data,8,25)';   % convert to 25x8 matrix
    temp = parse_json(device.checkouts{jj}.diagnostic_file);
    RMSError(time, block,:) = cell2mat(temp.RMSErrorCrossGeometry);
    MuEff(time, block,:) = cell2mat(temp.MuEffectiveMeasured);
    Bias(time, block,:) = cell2mat(temp.BiasCrossGeometry);
end

%num_checkouts = kk;   % number of valid runs


%% Data analysis

MaxAllCnt = squeeze(round(allData(:,:,end,:)));    % array of max counts

meanMaxAllCnt = squeeze(mean(MaxAllCnt,1));
stdAllCnt = std(MaxAllCnt,1);
meanMuEff = mean(MuEff,1);
stdMuEff = std(MuEff,1);
meanRMSErr = mean(RMSError,1);
stdRMSErr = std(RMSError,1);

bm_MaxAllCnt = squeeze(mean(MaxAllCnt,1));
bs_MaxAllCnt = squeeze(std(MaxAllCnt,1));
bm_MuEff = squeeze(mean(MuEff,1));
bs_MuEff = squeeze(std(MuEff,1));
bm_RMSErr = squeeze(mean(RMSError,1));
bs_RMSErr = squeeze(std(RMSError,1));

xbm_MaxAllCnt = [ bm_MaxAllCnt(1:5,:) ; bm_MaxAllCnt(7:8,:)];    % exclude outlier
xbm_MuEff = [ bm_MuEff(1:5,:) ; bm_MuEff(7:8,:)];    % exclude outlier

%% Display results

figure(1)
for ii = 1:block,
    subplot(2,4,ii)
    plot(squeeze(MaxAllCnt(:,ii,:))', '-+')
    title(['Block # ' num2str(ii)])
    ylabel('MaxAllCnt (counts)')
    axis([0 block+1 min(MaxAllCnt(:)) max(MaxAllCnt(:))])
    hold on
    errorbar(bm_MaxAllCnt(ii,:), bs_MaxAllCnt(ii,:),'k-.', 'Linewidth', 2)
    hold off
end
legend('2-19 AM', '2-20 AM', '2-20 PM')

figure(6)
subplot(2,1,1)
    boxplot(bm_MaxAllCnt, 'notch', 'on')
    title('Mean counts over time')
    ylabel('MaxAllCnt (counts)')
    xlabel('LED #')
subplot(2,1,2)
    boxplot(bm_MaxAllCnt', 'notch', 'on')
    title('Mean counts over time')
    ylabel('MaxAllCnt (counts)')
    xlabel('Block #')

figure(2)
errorbar(repmat(leds,block,1)', bm_MuEff', bs_MuEff')
legend(num2str([1:block]'))
hold on
errorbar(leds, MuEffNom, MuError, 'r.')
grid; axis tight
hold off
ylabel('\mu_{eff} (1/cm)')
title('\mu_{eff} for all 432 blocks')
xlabel('Wavelength (nm)')

figure(3)
errorbar(bm_RMSErr', bs_RMSErr')
grid; axis tight
legend(num2str([1:8]'))
title('RMS Error for all 432 blocks')


figure(4)
for ii = 1:block,
    subplot(2,4,ii)
    plot(squeeze(RMSError(:,ii,:))', '-+')
    title(['Block # ' num2str(ii)])
    ylabel('RMS Error (counts)')
    axis([0 5 0 max(RMSError(:))])
end
legend('2-19 AM', '2-20 AM', '2-20 PM')

figure(5)
for ii = 1:block,
    subplot(2,4,ii)
    boxplot(squeeze(RMSError(:,ii,:)), 'notch', 'on')
    title(['Block # ' num2str(ii)])
    ylabel('RMS Error (counts)')
    axis([0 5 0 max(RMSError(:))])
end

figure(7)
plot(bm_MaxAllCnt','-+')
legend(num2str([1:block]'))
title('MaxAllCnt for all 432 blocks')
ylabel('MaxAllCnt (counts)')
hold on
plot(mean(bm_MaxAllCnt)', '-.+k', 'linewidth', 2)
plot(MIN_PASS, 'r')
plot(MAX_PASS, 'r')
hold off
axis tight; grid

disp('Mean Mu_Eff (1/cm), including all blocks:')
mean(bm_MuEff)
disp('Relative Mu_Eff variation (%), including all blocks:')
std(bm_MuEff) / std(bm_MuEff) * 100

disp('Mean Mu_Eff (1/cm), excluding block 6:')
mean(xbm_MuEff)

disp('Relative Mu_Eff variation (%), excluding block 6:')
std(xbm_MuEff) ./ mean(xbm_MuEff) * 100

