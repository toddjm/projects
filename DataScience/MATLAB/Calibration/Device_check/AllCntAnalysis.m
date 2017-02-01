% Script used to analyze AllCounts calibration data from server or CSV file
% Modified specifically to analyze new Sabic plastic by creating an INCLUDED_DEVICES list.
%
% P. Silveira, Feb. 2015
% Last modification: June 2015.
%

%% Query customization section
clear all
close all

%status = [0];   % list of statuses (comment out to exclude from query)

% Select start and end date of checkouts to be included in query. REMEMBER
% to go one day beyond last day of interest so all devices are included.
% Comment out to include all dates.
%chkDateBegin = '20150202'; chkDateEnd = '20150313';   % Kickstarter run
%chkDateBegin = '20150324'; chkDateEnd = '20150327';  % 1st lot of MP run
%chkDateBegin = '20150327'; chkDateEnd = '20150331';  % 2nd lot of MP run
%chkDateBegin = '20150401'; chkDateEnd = '20150404';  % 2nd lot of MP run
%chkDateBegin = '20150611'; chkDateEnd = '20150613';  % 3rd lot of MP run
%chkDateBegin = '20150709'; chkDateEnd = '20150711';  % 34 units calibrated in Austin
%chkDateBegin = '20150804'; chkDateEnd = '20150808';  % 1st units calibrated by TS3
%chkDateBegin = '20150807'; chkDateEnd = '20150831';  % 1.5 alpha units (set also INCLUDED_OPERATORS to 'alpha' or use INCLUDED_DEVICES)
%chkDateBegin = '20150818'; chkDateEnd = '20150820';   % 80-unit, small lot run @ TS3
%chkDateBegin = '20150909'; chkDateEnd = '20150911';   % Beta run @ TS3
%chkDateBegin = '20150915'; chkDateEnd = '20150918';   % Small 1.0 batch @ TS3
%chkDateBegin = '20151130'; chkDateEnd = '20151202';     % OPT7020 batch @ TS3
%chkDateBegin = '20160217'; chkDateEnd = '20160225';  % MP lot of 250
%chkDateBegin = '20160228'; chkDateEnd = '20160301';
chkDateBegin = '20160530'; chkDateEnd = '20160601';     % MP lot of 250


%EXCLUDED_OPERATORS = {'Nithin'; 'wayne'; 'alpha'; 'paulo'; 'Paulo Silveira'; 'Meredith'}; % list of operators to exclude from analysis. Leave blank or comment out to include all.
%INCLUDED_OPERATORS = {'alpha'}; % only include in the analysis operators in this list

%EXCLUDED_DEVICES = {'0CEFAF810A05'};
%EXCLUDED_DEVICES = {'0CEFAF810047' '0CEFAF8101E2' '0CEFAF810216' '0CEFAF810225' '0CEFAF810235' '0CEFAF810191'}; % list of devices to exclude from analysis. Leave blank or comment out to include all.
%EXCLUDED_DEVICES = {'0CEFAF810975', '0CEFAF8103CE'}; % list of devices to exclude from analysis. Leave blank or comment out to include all.
%EXCLUDED_DEVICES = {'0CEFAF810ABA', '0CEFAF810AC2'};
% Defective Gen2 devices with OPT7020
%EXCLUDED_DEVICES = {'0CEFAF810C29' '0CEFAF810CE1' '0CEFAF810C30' '0CEFAF810D31' '0CEFAF810CDF' '0CEFAF810D1D' '0CEFAF810D17' '0CEFAF810D15' '0CEFAF810D16' '0CEFAF810D1E' '0CEFAF810C4F' '0CEFAF810D3D' '0CEFAF810C28' '0CEFAF810D3F' '0CEFAF810D35' '0CEFAF810D37' '0CEFAF810D14' '0CEFAF810C55' '0CEFAF810D40' '0CEFAF810CDB' '0CEFAF810CDD' '0CEFAF810D3E' '0CEFAF810D21' '0CEFAF810D32' '0CEFAF810D44' '0CEFAF810D26' '0CEFAF810D36' '0CEFAF810D2D' '0CEFAF810C3C' '0CEFAF810C42' '0CEFAF810C4D' '0CEFAF810CF2' '0CEFAF810C51' '0CEFAF810C56' '0CEFAF810D38' '0CEFAF810C2B' '0CEFAF810C3A' '0CEFAF810C2C' '0CEFAF810C2E' '0CEFAF810D41' '0CEFAF810D33' '0CEFAF810D13'};

% List of devices using dyed Sabic plastic and Sabic enclosure
%INCLUDED_DEVICES = {'0CEFAF8106D8' '0CEFAF8106E7' '0CEFAF81069F' '0CEFAF8106D6' '0CEFAF81069D' '0CEFAF810687' '0CEFAF8106F3' '0CEFAF8106DA' '0CEFAF8106A1' '0CEFAF8106DE' '0CEFAF8106E3' '0CEFAF8106EC' '0CEFAF81068F' '0CEFAF8106E6' '0CEFAF810685' '0CEFAF8106F1' '0CEFAF8106EF' '0CEFAF810692' '0CEFAF81065A' '0CEFAF8105F9' '0CEFAF810695' '0CEFAF8106E8' '0CEFAF81068A' '0CEFAF810696' '0CEFAF810688' '0CEFAF81068D' '0CEFAF810686' '0CEFAF81061C' '0CEFAF810691' '0CEFAF8106DF' '0CEFAF81069C' '0CEFAF810690' '0CEFAF810697' '0CEFAF81069A'};
% List of devices using dyed Sabic plastic and Sabic enclosure, but not
% including defective device 0CEFAF810697 
%INCLUDED_DEVICES = {'0CEFAF8106D8' '0CEFAF8106E7' '0CEFAF81069F' '0CEFAF8106D6' '0CEFAF81069D' '0CEFAF810687' '0CEFAF8106F3' '0CEFAF8106DA' '0CEFAF8106A1' '0CEFAF8106DE' '0CEFAF8106E3' '0CEFAF8106EC' '0CEFAF81068F' '0CEFAF8106E6' '0CEFAF810685' '0CEFAF8106F1' '0CEFAF8106EF' '0CEFAF810692' '0CEFAF81065A' '0CEFAF8105F9' '0CEFAF810695' '0CEFAF8106E8' '0CEFAF81068A' '0CEFAF810696' '0CEFAF810688' '0CEFAF81068D' '0CEFAF810686' '0CEFAF81061C' '0CEFAF810691' '0CEFAF8106DF' '0CEFAF81069C' '0CEFAF810690' '0CEFAF81069A'};
% List of devices using clear Sabic plastic
%INCLUDED_DEVICES = {'0CEFAF8106E2' '0CEFAF8106E0' '0CEFAF8106A0' '0CEFAF810684' '0CEFAF810699' '0CEFAF8106EB' '0CEFAF810698' '0CEFAF8106EE' '0CEFAF81069E'};
% BSXInsight 2.0 Alpha units
%INCLUDED_DEVICES = {'0CEFAF81097C' '0CEFAF81097F' '0CEFAF81096B' '0CEFAF810978' '0CEFAF810980' '0CEFAF810982' '0CEFAF810976' '0CEFAF810983' '0CEFAF810970' '0CEFAF810984'};
% BSXInsight 2.0 Beta units
%INCLUDED_DEVICES = {'0CEFAF8109AD' '0CEFAF810991' '0CEFAF8109AB' '0CEFAF810992' '0CEFAF81099D' '0CEFAF810998' '0CEFAF81099E' '0CEFAF810993' '0CEFAF810999' '0CEFAF8109A6' '0CEFAF81098B' '0CEFAF8109A7' '0CEFAF8109A5' '0CEFAF810995' '0CEFAF8109AC' '0CEFAF8109A4' '0CEFAF81098D' '0CEFAF81099F' '0CEFAF810996' '0CEFAF81099B'  '0CEFAF81098F' '0CEFAF81099C' '0CEFAF8109A2' '0CEFAF810994' '0CEFAF81099A' '0CEFAF810990' '0CEFAF8109A8' '0CEFAF81098C' '0CEFAF8109A9' '0CEFAF810997' '0CEFAF8109AA'};
% Devices used in Optical adhesive study
%INCLUDED_DEVICES = {'0CEFAF8103D0' '0CEFAF8107FC' '0CEFAF810107' '0CEFAF810917'}; % First 4 Permatex devices
%INCLUDED_DEVICES = {'0CEFAF8106DE' '0CEFAF810270' '0CEFAF810726' '0CEFAF8104A2' '0CEFAF810529' '0CEFAF8101C5' '0CEFAF8102BC' '0CEFAF8101CF' '0CEFAF8104F3' '0CEFAF8103C1'}; % Additional 10 Permatex devices used during verification.
%INCLUDED_DEVICES = {'0CEFAF810C4B' '0CEFAF810C4C' '0CEFAF810C29' '0CEFAF810CD7' '0CEFAF810CDF'}; % OPT7020 Gen2 devices made at TS3, before fully cured
% Off-axis bubbles
%INCLUDED_DEVICES = {'0CEFAF8103E3' '0CEFAF8104C9' '0CEFAF8102A6' '0CEFAF8103E5' '0CEFAF8107FE' '0CEFAF810242'};
% No bubbles
%INCLUDED_DEVICES = {'0CEFAF8102F9' '0CEFAF810728' '0CEFAF8101EA' '0CEFAF810021' '0CEFAF810365' '0CEFAF810019' '0CEFAF81029E' '0CEFAF8100EA' '0CEFAF81025C' '0CEFAF800078' '0CEFAF810210'};
% On-axis bubbles
%INCLUDED_DEVICES = {'0CEFAF810302' '0CEFAF810509' '0CEFAF810200' '0CEFAF8101B1' '0CEFAF81041E'};
% Devices that failed Feb. 2016 TS3 run
%INCLUDED_DEVICES = {'0CEFAF810EAB' '0CEFAF810F44' '0CEFAF810F56' '0CEFAF8110A2' '0CEFAF8112BA'};

%% Initialize

FONTSIZE = 11;  % font size used in some plots
[cent_leds leds] = getLeds; %[665, 810, 850, 950];    % peak wavelengths (nm) of LEDs used in device
numLeds = numel(leds);
DATE_FORMAT = 'yyyymmdd'; % date format used by server in queries
HW_VERSION_UNSET = true;    % flag indicating that hw_version is still unset
SAVE_PDF = false;   % Flag for saving individual PDF results
pdfPath = pwd;  % default path for saving PDF output files

% if exist('chkDateBegin', 'var')
%      chkDateBeginNum = datenum(chkDateBegin, DATE_FORMAT);
%     chkDateEndNum = datenum(chkDateEnd, DATE_FORMAT);
% end
% if exist('crtDateBegin', 'var')
%      crtDateBeginNum = datenum(crtDateBegin, DATE_FORMAT);
%     crtDateEndNum = datenum(crtDateEnd, DATE_FORMAT);
% end

DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format reported by server
kk = 0; % valid devices counter
high_ambient = {};  % list of devices with high ambient light

%% Get and parse data

% Ignore all previous query steps if a list of included devices is provided
% instead
if exist('INCLUDED_DEVICES', 'var')
    unique_device = INCLUDED_DEVICES;
else
    if ~exist('status', 'var')
        device_chks = getDeviceChks( 'dateBegin', chkDateBegin, 'dateEnd', chkDateEnd);
    else
        device_chks = getDeviceChks( 'status', num2str(status), 'dateBegin', chkDateBegin, 'dateEnd', chkDateEnd);
    end
    fprintf('%d total checkouts found, ', numel(device_chks));
    for ii = 1:numel(device_chks); device_chks_cell{ii} = device_chks{ii}.device_id; end  % convert device ids to cell array
    unique_device = unique(device_chks_cell);  % make sure all devices are unique. Remove duplicate device ids.
end
num_devices = numel(unique_device);
fprintf('%d unique devices found.\n', num_devices);

indiv_reply = questdlg('Save individual results to PDF?');
if strcmp(indiv_reply, 'Yes')
    pdfPath = uigetdir(pdfPath);
    SAVE_PDF = true;
end
    
for jj = 1:num_devices;    % Parse each device
    devicejj = getDevice(unique_device{jj});
    chkout = devicejj.checkouts{1};
    % Parse exceptions
%     if exist('crtDateBegin', 'var')
%         dateNum = datenum(devicejj.checkouts{end}.created_at, DATE_FORMAT);
%         if dateNum < crtDateBeginNum | dateNum > crtDateEndNum,
%             disp(['Excluding device ' chkout.device_id ' because first checkout date = ' devicejj.checkouts{end}.created_at])
%             continue
%         end
%     end
    if exist('EXCLUDED_OPERATORS', 'var') && any(strcmpi(chkout.operator_id, EXCLUDED_OPERATORS)), % ignore test devices
        disp(['Excluding device ' chkout.device_id ' entered by ' chkout.operator_id ' because of operator exclusion list.']) 
        continue
    end
    if exist('INCLUDED_OPERATORS', 'var') && any(~strcmpi(chkout.operator_id, INCLUDED_OPERATORS)), % ignore these devices
        disp(['Excluding device ' chkout.device_id ' entered by ' chkout.operator_id ' because operator is not in inclusion list.']) 
        continue
    end
    if exist('EXCLUDED_DEVICES', 'var') && any(strcmpi(chkout.device_id, EXCLUDED_DEVICES)), % ignore test devices
        disp(['Excluding device ' chkout.device_id ' because of device exclusion list.']) 
        continue
    end
    if HW_VERSION_UNSET  % assume all devices use the same hw_version as first device
        current = getCurrents(devicejj.hw_version);  % get 25 current values (Amps)    
        [ MAX_PASS, MIN_PASS, MuEffNom, MuError, MuEffTol, RMSErrorMAX ] = calibPassFail(devicejj.hw_version);   % get pass/fail criteria being currently used
        HW_VERSION_UNSET = false;
    end
    [ AllCnt, invC15, invC27, lookup_current, calib_diag, sweep ] = getAllCnt(devicejj);   % device may be valid. Fetch info
    if exist('status', 'var') && calib_diag.CalibrationStatus ~= status     % ONLY WORKS FOR STATUS = 0!!!
        disp(['Skipping device ' chkout.device_id])
        continue
    end
    if any(isnan(AllCnt)) % flag "false negative" devices
        warning(['Device ' chkout.device_id ' contains NaNs in AllCnt matrix! Skipping it.'])
        continue
    end

    kk = kk + 1;    % device is not an exception. Increment counter
    station{kk} = chkout.station;
    device_id(kk,:) = chkout.device_id;
    hwversion{kk} = devicejj.hw_version;
%     block(kk,:) = chkout.block;
    lastChk_date{kk} = chkout.updated_at;
    creation_date{kk} = devicejj.checkouts{end}.created_at;   % creation date of first checkout (order in which device was entered on server db)
%    chk_date_num(kk,:) = datenum(chk_date(kk,:), DATE_FORMAT);
    operator{kk} = chkout.operator_id;
    allData(kk,:,:) = AllCnt;
    RMSError(kk,:) = cell2mat(calib_diag.RMSErrorCrossGeometry);
    MuEff(kk,:) = cell2mat(calib_diag.MuEffectiveMeasured);
    Bias(kk,:) = cell2mat(calib_diag.BiasCrossGeometry);
    deviceMuEffNom(kk,:) = cell2mat(calib_diag.MuEffectiveNominal); % get nominal mu_eff stored in device checkout
    deviceMuError(kk,:) = deviceMuEffNom(kk,:) * MuEffTol;  % calculate mu_eff maximum acceptable error
    if any(sweep.ambient > 0)
        high_ambient = {high_ambient{:} chkout.device_id};
    end
    
    if SAVE_PDF
        pdf_file = publish(['devAnalysis(''' device_id(kk,:) ''', 1, ''none'')'], 'outputDir', pdfPath, 'format', 'pdf','showCode', false);
        new_pdf_file = [pdfPath '\Analysis_device_' device_id(kk,:) '.pdf'];
        movefile(pdf_file, new_pdf_file,'f'); % move pdf file to final destination, renaming it in the process
        fprintf('Saved most recent calibration to PDF file %s\n', new_pdf_file)
    end
end
num_devices = kk;   % number of valid devices

fprintf(1, '# of devices included = %d\n', num_devices)

if ~num_devices,    % query returned zero devices.
    fprintf(1, 'chkDateBegin = %s, chkDateEnd = %s, STATUS = %s\n', chkDateBegin, chkDateEnd, status);
    error('No devices satisfy query.')
end
% temp = size(filename);
% num_files = temp(2);    % find number of files to be read
% for ii = 1:num_files,
%     data = csvread([pathname char(filename(ii))],3,0);  % Read file, skipping first 3 rows (header)
%    allData(ii,:,:) = data(:,1:end-1);   % save all data, ignoring last column (blank)
% end

%% Data analysis

meanData = squeeze(round(mean(allData)));   % calculate mean of AllCnt
stdData = squeeze(std(allData));
maxData = squeeze(round(max(allData)));
minData = squeeze(round(min(allData)));

expMax = meanData(end,:);  % expected maximum counts
stdMax = stdData(end,:);   % std. dev. of maximum counts
%margin = 3*stdMax;         % maximum count tolerance
maxExpMax = round(expMax+4*stdMax); % maximum count tolerance
minExpMax = round(expMax-4*stdMax); % minimum count tolerance
maxMax = maxData(end,:);   % maximum of all counts over all devices
minMax = minData(end,:);   % Minimum of all counts over all devices

endData = squeeze(round(allData(:,end,:)));    % array of max counts
    
% Calculate lot statistics
meanMuEff = squeeze(mean(MuEff));
stdMuEff = squeeze(std(MuEff));
maxMuEff = squeeze(max(MuEff));
minMuEff = squeeze(min(MuEff));

meanMaxAllCnt = squeeze(meanData(end,:))' / 1E7;
stdMaxAllCnt = squeeze(stdData(end,:))' / 1E7;
device_stats = table([1:2*numLeds]', meanMaxAllCnt, stdMaxAllCnt, 'VariableNames', {'Led' 'Mean' 'Std'});

[temp, creation_ind] = sort(creation_date);  % creates index array, sorted by device first calibration date (same order as in the server)

%% Display results

close all
figure(1)
surf([1:numLeds], current, double(meanData(:,1:4)))
ylabel('Current (Amps)')
xlabel('LED')
zlabel('Counts/Transmission')
title('Mean counts for 15mm distance')
axis tight

figure(2)
surf([1:numLeds], current, double(meanData(:,5:8)))
ylabel('Current (Amps)')
xlabel('LED')
zlabel('Counts/Transmission')
title('Mean counts for 27mm distance')
axis tight

figure(3)
set(gcf, 'Position', [228 112 1212 420])
plot(expMax,'k-')
hold on
plot(maxExpMax, 'm-.')
plot(minExpMax, 'm--')
plot(MAX_PASS, 'r')
plot(MIN_PASS, 'r')
plot(maxMax, 'g-')
plot(minMax, 'b-')
h = legend('Averaged max. counts', 'Calc. Max. tol.', 'Calc. Min. tol.', 'Current Max. tol.', 'Current Min. tol.','Max over all devices', 'Min over all devices', 'Location', 'EastOutside');
set(h, 'FontSize', 8)
grid
xlabel('LEDs')
ylabel('Counts/Transmission')
title('Expected maximum counts and tolerances (4-\sigma)')
hold off

figure(4)
set(gcf, 'Position', [816 -14 766 420])
boxplot(squeeze(allData(:,end,:)))
xlabel('LEDs')
ylabel('Counts/Transmission')
title(['Boxplot of MaxCnts for ' num2str(num_devices) ' devices'])
hold on
plot(MAX_PASS, 'r')
plot(MIN_PASS, 'r')
legend('Tolerances', 'Location', 'Best')
hold off
axis auto

figure(5)
set(gcf, 'Position', [569 -78 888 420])
surf(double(endData))
ylabel('Devices')
xlabel('LEDs')
zlabel('Counts/Transmission')
title('Max. counts surface')
axis tight

figure(6)
set(gcf, 'Position', [188 116 844 420])
for ii=1:numLeds,
    subplot(2,4,ii)
    hist(endData(:,ii),25)
    ylabel('# of devices')
    xlabel('counts')
    title(['15mm, ' leds{ii} 'nm'])
%    axis([2e8 5.7e8 0 60])
    subplot(2,4,4+ii)
    hist(endData(:,4+ii),25)
    ylabel('# of devices')
    xlabel('counts')
    title(['27mm, ' leds{ii} 'nm'])
%    axis([2e8 5.7e8 0 60])
end

figure(7)
errorbar(cent_leds, meanMuEff, 4*stdMuEff, 'k-', 'linewidth', 2)
hold on
errorbar(cent_leds, MuEffNom, MuError, 'r.', 'linewidth', 2)
plot(cent_leds, maxMuEff, 'g-')
plot(cent_leds, minMuEff, 'g-.')
hold off
xlabel('wavelength (nm)')
ylabel('\mu_{eff} (1/cm)')
title(['\mu_{eff} for all ' num2str(num_devices) ' devices.'])
grid; axis tight
legend('Measured average (4-\sigma)', 'Nominal', 'Max over all devices', 'Min. over all devices')

figure(8)
set(gcf, 'Position', [964 1 709 420])
boxplot(RMSError)
xlabel('LEDs')
ylabel('Counts/Transmission')
% plot(cent_leds, RMSError, 'b+', 'linewidth', 2)
ylabel('RMS Error (a.u.)', 'FontSize', FONTSIZE)
title(['RMS Error for ' num2str(num_devices) ' devices'], 'Fontsize', FONTSIZE)
hold on
%grid
plot([1:numLeds], RMSErrorMAX*ones(numLeds), 'r-')
axis tight
legend('Threshold')
hold off

if exist('device_chks_cell', 'var')
    dup_chks = duplicate(device_chks_cell);
    if ~isempty(dup_chks)
        fprintf('List of devices with multiple checkouts:\n')
        fprintf('%s ', dup_chks(:).element)
    end
end

fprintf('\nCalculated Minimum tolerance = \n[')
for ii = 1:numel(minExpMax)-1,
    fprintf('%d,', minExpMax(ii))
end
fprintf('%d]\n', minExpMax(end))
fprintf('Calculated Maximum tolerance = \n[')
for ii = 1:numel(maxExpMax)-1,
    fprintf('%d,', maxExpMax(ii))
end
fprintf('%d]\n', maxExpMax(end))

fprintf('MaxAllCnt (/1E7):\n')
disp(device_stats)

if ~isempty(high_ambient)
    fprintf(2,'List of devices with high ambient light: ')
    fprintf(2, '%s ', high_ambient{:})
    fprintf(2, '\n')
end

[fileName,pathName,FilterIndex] = uiputfile('*.ppt','Select PowerPoint file name to save plots',['./AllCnt Analysis-' date '.ppt']);
if fileName
    Str = ['AllCnt Analysis ' pathName fileName '\n\nNumber of devices: ' num2str(num_devices)];
    if exist('chkDateBegin', 'var')
        Str = [Str '\nStart date: ' chkDateBegin '. End date: ' chkDateEnd];
    end
    Str = [Str '\n\nAnalysis date: ' date];
    saveAssessmentPPT([pathName fileName], Str);
end
    

%cd(oldpath)


