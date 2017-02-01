% Script used to qualify new calibration setups
%
% P. Silveira, Mar. 2015
%

%% Initialize
clear all
close all
deviceID = '0CEFAF8100E9';
DATE_START = '2015-03-21 22:00:00'; % start date to include in query
DATE_END = '2015-03-21 23:40:00';   % end date to include in query
leds = [665, 810, 850, 950];
DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format string
% Mean of MaxAllCtn, from MultipleBlocks2 experiment, excluding block 6
MEAN_MAXALLCNT = [297548768   262691360   322383392   371146496   381963296   294225088   333585760 427841472];
MEAN_MUEFF = [2.9813    2.6723    2.6570    2.5758];
kk = 0; % checkouts counter

[ MIN_PASS, MAX_PASS, MuEffNom, MuError ] = calibPassFail;

dateStart = datenum(DATE_START, DATE_FORMAT);   % convert dates to date numbers
dateEnd = datenum(DATE_END, DATE_FORMAT);

%% Get data

device = getDevice(deviceID);    %, 'dateBegin', dateBegin, 'dateEnd', dateEnd);
for jj = 1:numel(device.checkouts);  % check all available checkouts
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
%    block = block + 1;
%     if block > 8,   % reset block number after the 8th block
%         block = 1;
%         time = time + 1;
%     end
    cr_date{kk} = device.checkouts{jj}.created_at;
        
    [ allData(kk,:,:), invC15, invC27, calib_diag] = getAllCnt(device, jj)

%     if device.checkouts{jj}.status,
%         warning(['Device status = ' device.checkouts{jj}.status ' in ckeckout # ' num2str(jj)])
%     end
%     allData(kk,:,:) = reshape(data,8,25);   % convert to 25x8 matrix
%     temp = parse_json(device.checkouts{jj}.diagnostic_file);
    RMSError(kk,:) = cell2mat(calib_diag.RMSErrorCrossGeometry);
    MuEff(kk,:) = cell2mat(calib_diag.MuEffectiveMeasured);
    Bias(kk,:) = cell2mat(calib_diag.BiasCrossGeometry);
end

num_checkouts = kk;   % number of valid runs

%% Data analysis

MaxAllCnt = squeeze(allData(:,end, :));    % array of max counts

%% Display results

figure(1)
plot(MaxAllCnt','-+')
legend(num2str([1:num_checkouts]'))
title('Different cradles ')
ylabel('MaxAllCnt (counts)')
hold on
plot(MEAN_MAXALLCNT', '-.+k', 'linewidth', 2)
plot(MIN_PASS, 'r')
plot(MAX_PASS, 'r')
hold off
axis tight; grid

temp = vdist(MEAN_MAXALLCNT, MaxAllCnt);  % find distance between vectors
disp(['Orientation with smallest Euclidian distance to the mean of MaxAllCnt of all other blocks = ' num2str(find(temp == min(temp(:))))])
%temp = proj(MEAN_MAXALLCNT, MaxAllCnt);  % find distance between vectors
%disp(['Orientation with MaxAllCnt shape that is closest to the mean of all other blocks = ' num2str(find(temp == max(temp(:))))])

figure(2)
plot(leds, MuEff','-+')
legend(num2str([1:num_checkouts]'))
title('Different cradles')
ylabel('\mu_{eff} (1/cm)')
xlabel('Wavelength (nm)')
hold on
plot(leds, MEAN_MUEFF', '-.+k', 'linewidth', 2)
plot(leds, MuEffNom, 'r.', 'linewidth', 2)
hold off
axis tight; grid

temp = vdist(MEAN_MUEFF, MuEff); % find distance between vectors
disp(['Orientation with smallest Euclidian distance to the mean of MuEff of all other blocks = ' num2str(find(temp == min(temp(:))))])
%temp = proj(MEAN_MUEFF, MuEff);  % find distance between vectors
%disp(['Orientation with MuEff shape that is closest to the mean of all other blocks = ' num2str(find(temp == max(temp(:))))])

figure(3)
boxplot(RMSError)
title('Different cradles')
ylabel('RMS Error (counts)')
xlabel('LEDs')
    
