% Script used to analyze calibration data from a single CSV file
% P. Silveira, Jan. 2015
%
% In the CSV files we have that columns J-M (10-13) contain the currents (mA) of the
% 15mm LEDs, in the following order: 680, 810, 850 and 970nm, respectively.
% Columns V-Y (22-25) contain the same information for the 30mm LEDs.
% Counts for 15mm LEDs are stored in columns B-E (2-5).
% Counts for 30mm LEDs are stored in columns N-Q (14-17).
% Column A contains (biased) ambient light counts (1).
% Columns AI-AJ (35-36) contain deoxy- and oxyhemoglobin concentration for
% 15mm distances.
% Columns AK-AL (37-38) contain deoxy- and oxyhemoglobin concentration for
% 30mm distances.
% First 3 rows contain header information.
%

%% Initialize
clear all
close all
leds = {'665', '810', '850', '970'};

%[filename, pathname] = uigetfile('*.csv', 'Pick files with sweep data', 'MultiSelect', 'on');
[filename, pathname] = uigetfile('*.csv', 'Pick files with sweep data', 'MultiSelect', 'off');

%% Data input

%temp = size(filename);
%num_files = temp(2);    % find number of files to be read
%dev_ct = 1; % device counter
%ll = 0; % row counter
%for ii = 1:num_files,
    data = csvread([pathname filename],3,0);  % Read file, skipping first 3 rows (header)
    temp = filename;
    device = str2num(temp(1:5)); % store device number
    sz = size(data);
    kk = 0; % row counter
%     if ~mod(ii,13)
%        dev_ct = dev_ct + 1; % increment device count every 12 files
%        ll = 0;
%    end
%    ll = ll + 1;
    % Parse data
    %for jj = 4:5:sz(1),   % skip blank counts and current data, occupied by IMU data
    for jj = find(data(:,1) < 0)',
        kk = kk + 1;
        current15(kk,:) = data(jj,10:13);    % as it turns out, current15=current27, so only one of the two is needed
        current27(kk,:) = data(jj,22:25);
        ambient(kk,:) = data(jj,1);
        count15(kk,:) = data(jj,2:5);
        count27(kk,:) = data(jj,14:17);
        cHHb_15(kk,:) = data(jj,35);
        cHbO2_15(kk,:) = data(jj,36);
        cHHb_27(kk,:) = data(jj,37);
        cHbO2_27(kk,:) = data(jj,38);        
%        count27((ll-1)*254+kk,:) = data(jj,14:17);
    end
%end

%% Data analysis

ratio = count27./count15;
ratio = ratio .* (ratio > 0);   % remove negative values
logRatio = log10(ratio);
OD27r = 1.09-logRatio/12*27;  % estimate ODs
OD15r = 1.09-logRatio/12*15;  % estimate ODs
%   mu_eff = -0.074-0.192*logRatio; % estimate mu_eff (1/mm) - Empirical constant
mu_eff = -0.098-0.192*logRatio; % estimate mu_eff (1/mm) - Analytic constant
%    ODpermm = 0.4343*mu_eff+0.0322;
ODpermm27 = 0.4343*mu_eff + 2/(27*log(10));
ODpermm15 = 0.4343*mu_eff + 2/(15*log(10));
OD27mu = ODpermm27*27+1.09;
%OD15mu = ODpermm15*15+1.09;
OD15mu = ODpermm27*15+1.09;

ii = find(current15 < 0.0001);  % find low current events
disp(['Noise power of 15mm LEDs = ' num2str(spower(count15(ii)))])
disp(['Noise power of 27mm LEDs = ' num2str(spower(count27(ii)))])


 %% Plot results
 
 for LEDNum = 1:4,
     
     figure(1)
     subplot(2,2,LEDNum)
     plot(current15(:,LEDNum), OD27r(:, LEDNum),'+')
     xlabel('Current')
     ylabel('OD @ 27mm estimated from ratios')
     title(strcat('Current sweep, log scale, for INO 432, LED ',leds(LEDNum)))
     axis tight; grid
%     legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
     
     figure(2)
     subplot(2,2,LEDNum)
     plot(current15(:,LEDNum), OD15r(:,LEDNum),'+')
     xlabel('Current')
     ylabel('OD @ 15mm estimated from ratios')
     title(strcat('Current sweep, log scale, for INO 432, LED ',leds(LEDNum)))
     axis tight; grid
 %    legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
     
     figure(3)
     subplot(2,2,LEDNum)
     plot(current15(:,LEDNum), mu_eff(:,LEDNum)*10,'+')
     xlabel('Current')
     ylabel('\mu_{eff}(1/cm)')
     title(strcat('Current sweep, log scale, for INO 432, LED ',leds(LEDNum)))
     axis tight; grid
  %   legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
     
     figure(4)
     subplot(2,2,LEDNum)
     plot(current15(:,LEDNum), OD15mu(:,LEDNum),'+')
     xlabel('Current')
     ylabel('OD @ 15mm estimated from \mu_{eff}')
     title(strcat('Current sweep, log scale, for INO 432, LED ',leds(LEDNum)))
     axis tight; grid
   %  legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
     
     figure(5)
     subplot(2,2,LEDNum)
     plot(current15(:,LEDNum), OD27mu(:,LEDNum),'+')
     xlabel('Current')
     ylabel('OD @ 27mm estimated from \mu_{eff}')
     title(strcat('Current sweep, log scale, for INO 432, LED ',leds(LEDNum)))
     axis tight; grid
%     legend(num2str(device(1)), num2str(device(13)), num2str(device(25)), num2str(device(37)))
 end
 
%  figure
%  plot(current15(:,2), count15(:,2),'+')
% figure
%  plot(current27(:,2), count27(:,2),'+')
%  P15 = polyfit(current15(:,2), count15(:,1),2)
%  P27 = polyfit(current27(:,2), count27(:,1),2)
 
 
 

