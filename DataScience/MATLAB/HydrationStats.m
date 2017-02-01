% Script used to obtain Hydration data from LT database
%

%% Initialize
clear
close all

processFields = {'pH2O'};% 'pH2Oproj' 'pH2Ocos'};
%sweepFields = {'samp_rate' 'imu_samp_rate' 'device' 'Acc_y' 'Acc_z' 'Gyro_x' 'Gyro_y' 'HR' 'PacePower' 'SDS_speed' 'SDS_cadence'};
%assessmentFields = {'sport' 'completed_on' 'completed_stages'};

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\LT Assessments\COMPLETE\'];
OUT_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Hydration\Dynamic Osmolality\Plots\'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
PROCESS_SUFFIX = '_process.mat';    % suffix of files with sweep structures
IN_FILE = ['*' PROCESS_SUFFIX];    % string used to identify input files
MIN_HYD = 0.2;
MIN_HYD_END = 0.1;
MAX_HYD = 0.55;
TOL_HYD = 0.9;
HYD_FILT_LENGTH = 100;  % number of samples to be used in filter
SAMP_RATE = 5;          % sampling rate. WARNING: assumed to be constant for all assessments!

%% Data input

%figure
files = dir([FILE_PATH IN_FILE]);
numFiles = length(files);
count = 0;
max_len = 0;
for ii = 1:numFiles
    fprintf('Processing file #%d/%d\n', ii, numFiles)
    load([FILE_PATH files(ii).name])
    id = files(ii).name(1:end-length(PROCESS_SUFFIX));
    for jj = 1:length(processFields)
        if isfield(process, processFields{jj})
            %           data(ii).(processFields{jj}) = process.(processFields{jj});
            pH2O = process.(processFields{jj});
        end
    end
    %   data(ii).assessment = id;   % keep track of seleced assessments
    
    temp = pH2O(isfinite(pH2O));
    cur_len = length(temp);
    if cur_len > 2*HYD_FILT_LENGTH     % skip short assessments
        
        pH2Ost = median(temp(1:HYD_FILT_LENGTH)); % start of hydration signal
        pH2Oend = median(temp(end-HYD_FILT_LENGTH:end)); % start of hydration signal
        if pH2Ost >= MIN_HYD && pH2Ost <= MAX_HYD && pH2Oend < pH2Ost*TOL_HYD && pH2Oend > MIN_HYD_END && ~any(temp > 1) && ~any(temp <0) && cur_len < 2700*SAMP_RATE
            count = count+1;
            selected(count).pH2O = pH2O;
            selected(count).assessment = id;
            
            if  cur_len > max_len
                max_len = cur_len;
                %        max_len_ind = ii;
            end
            
            %             plot([1:cur_len]/SAMP_RATE, temp, 'Color', [.5 .5 .5])
            %             temp2 = [temp ; NaN*ones(max_len-cur_len,1)];
            %             totpH2O = totpH2O + temp2;
            %             finiteTotCount = finiteTotCount + [ones(cur_len,1) ; zeros(max_len-cur_len,1)] ;
            %             hold on
            %
        end
    end
    
end

%% Data output
figure
totpH2O = zeros(max_len,1);
finiteTotCount = zeros(max_len,1);
for ii = 1:count
    temp = selected(ii).pH2O;
    cur_len = length(temp);
    plot([1:cur_len]/SAMP_RATE, temp, 'Color', [.5 .5 .5])
    temp2 = [temp ; NaN*ones(max_len-cur_len,1)];
    totpH2O = totpH2O + temp2;
    finiteTotCount = finiteTotCount + [ones(cur_len,1) ; zeros(max_len-cur_len,1)] ;
    hold on
end
xlabel('time (s)')
ylabel('Hydration index')
axis tight
ylim([0 .8])
totpH2O = totpH2O ./ finiteTotCount;
valid_totpH2O = totpH2O(isfinite(totpH2O));
time = linspace(0,max_len/SAMP_RATE, length(totpH2O))';
valid_time = linspace(0, length(valid_totpH2O)/SAMP_RATE, length(valid_totpH2O))';
p = polyfit(valid_time, valid_totpH2O, 1);
linfit = polyval(p, time);
plot(time, linfit, 'k--', 'Linewidth', 2)
title(['Hydration signal from ' num2str(count) ' LT assessments'])
%plot(linspace(0, max_len/SAMP_RATE, max_len), totpH2O, 'k--', 'Linewidth', 2)
%plot(valid_time, valid_totpH2O, 'r--', 'Linewidth', 1)

figure
plot(time, linfit, 'k', 'Linewidth', 2)
xlabel('time (s)')
ylabel('Hydration index')
axis tight
ylim([0 .8])
title(['Linear fit on hydration signal from ' num2str(count) ' LT assessments'])

figure
plot(time, linfit, 'k', 'Linewidth', 2)
xlabel('time (s)')
ylabel('Hydration index')
axis tight
ylim([0 .8])
hold on
ii = 29; pH2O = selected(ii).pH2O; l = length(pH2O); t = linspace(0,l/5,l); plot(t,pH2O, 'r')
ii = 26; pH2O = selected(ii).pH2O; l = length(pH2O); t = linspace(0,l/5,l); plot(t,pH2O)
title(['Linear fit on hydration signal from ' num2str(count) ' LT assessments'])
legend({'Linear fit' selected(29).assessment selected(26).assessment}, 'Location', 'Best')

save([OUT_PATH 'pH2O_data.mat'], 'selected')
fprintf('%d assessments selected', count)

