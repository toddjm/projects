% Script used to process warmup indicator data.
% See https://docs.google.com/spreadsheets/d/1lM7xxv44fqstfg8CcBYe-MOeWz0cI2RhvzXZCo9RoAc/edit#gid=0
% for more details.
%
% P. Silveira, Feb. 2016
% BSX Proprietary

%% Initialize
clear
close all

% Activity IDs (from first to last trial, listed by site).
% id.LeftCalf = {'56c4fb4cadac1869268b456a'
%
% '56c613feadac181d308b4567'
% '56c634a0adac18df308b456d'
% '56c64fdaadac18e7318b4567'
%
%
% '56c73d69adac18623b8b4568'
% '56c7542aadac18b03c8b4567'
%
% '56c7a0aeadac181a408b4568'
%
% '56cb6a22adac18d35c8b456c'
% '56cb7ba7adac1868608b4578'
% '56cb994eadac1899618b4568'
%
%
% '56ccda60adac185a718b4567'
% '56cd046eadac183d728b4567'
%
% '56cdecfeadac18267e8b4568'
% '56ce0946adac18b47e8b456a'
% '56ce20c2adac186a7f8b4568'
% '56ce4914adac187e018b4569'
% };
%
%
% id.LeftQuad = {'56c4fbfcadac1869268b456c'
%
% '56c6148eadac181a308b456a'
% '56c63594adac18df308b456e'
% '56c65106adac180a328b4567'
%
%
% '56c73debadac18623b8b4569'
% '56c7572dadac18173d8b4567'
%
% '56c7a1acadac181f408b4568'
%
% '56cb6a85adac1843608b4568'
% '56cb7c1aadac18d9608b4567'
% '56cb99ffadac1838618b4569'
%
% '56ccb645adac18636e8b456a'
% '56ccdc70adac1861718b4568'
% '56cd04caadac1844728b456a'
%
% '56cdedabadac18fd7d8b456c'
% '56ce0a2fadac18fb7e8b4567'
% '56ce2123adac186c7f8b4569'
% '56ce4802adac18aa018b4569'
% };

id.RightWrist = {'56c4fca0adac1860268b456d'
    
'56c61ac2adac1868308b4568'
'56c6368fadac180c318b4569'
'56c651cbadac1811328b4568'


'56c7835fadac182a3f8b456b'
'56c78300adac182c3f8b456a'

'56c7a425adac181f408b4569'

'56cb6b0eadac18d35c8b456d'
'56cb7c9dadac18d9608b4569'
'56cb9a9fadac181b638b4568'

'56ccb6ecadac18326e8b4572'
'56ccdd8aadac1862718b4568'
'56cd0787adac1844728b456c'


'56ce0acdadac18017f8b4567'
'56ce2050adac186c7f8b4568'
'56ce488fadac18aa018b456a'

'56cf4847adac18a60c8b4569'

'56d08fabadac18b71a8b456d'
'56d0a4eaadac18181c8b4570'
'56d0b827adac189b1d8b4569'

'56d47c03adac18573f8b456d'
'56d49960adac187e3f8b4578'
'56d4b417adac18f3408b4567'

'56d5d673adac18e04c8b4568'
'56d5f036adac18694d8b4569'
'56d61458adac188d4d8b4571'

'56d71aaeadac18da568b4569'
'56d73607adac1893588b4570'
'56d75217adac18d15c8b456c'

'56d8735badac1847688b456a'
%'56d8959badac181b698b4571'
'56d8adc1adac18996b8b4568'

'56d9c7e2adac18eb748b4569'

};

trial = {'01'
    
'02'
'03'
'04'

'06'
'07'

'09'

'10'
'11'
'12'

'13'
'14'
'15'


'17'
'18'
'19'

'20'

'21'
'22'
'23'

'24'
'25'
'26'

'27'
'28'
'29'

'30'
'31'
'32'

'33'
%'34'
'35'

'36'
};

%EXCLUSION_LIST = {'34'};
%INCLUSION_LIST = {'31'};
RANGE = [0, 60]; %[1200, 1800]; %[60,120];   % data range to be used (s)
% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Warmup_Indicator\Wrist\'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
PROCESS_SUFFIX = '_process.mat';
IMG_SUFFIX = '.emf'; %'.png'; %
WAHOO_FILE = 'Wahoo.csv';   % wahoo file name
printYN = questdlg('Save results?');

%% Data input

figure
[~, leds] = getLeds;
numLeds = length(leds);
set(gcf, 'Position', [713 176 960 544])
sites = fields(id); % get list of sites
numSites = length(sites);
numTrials = length(trial);
for ii = 1:numTrials
    if exist('INCLUSION_LIST', 'var') && ~any(strcmp(trial{ii}, INCLUSION_LIST))
        continue
    end
    if exist('EXCLUSION_LIST', 'var') && any(strcmp(trial{ii}, EXCLUSION_LIST))   % skip trials in exclusion list
        continue
    end
    for jj = 1:numSites
        activity_id =  id.(sites{jj}){ii};
        pathn = [FILE_PATH 'Trial' trial{ii}];
        sweepFilen =  [FILE_PATH 'Trial' trial{ii} SWEEP_SUFFIX];
        processFilen =  [FILE_PATH 'Trial' trial{ii} PROCESS_SUFFIX];
        fprintf('Processing trial %s, site %s, activity id %s.\n', trial{ii}, sites{jj}, activity_id);
        if ~exist(processFilen, 'file')
            activity = getActivity(activity_id);
            sweep = getSweep(activity)
            process = sweep2process(sweep)
            save(sweepFilen, 'sweep', 'activity')
            save(processFilen, 'process')
        else
            load(sweepFilen)
            load(processFilen)
        end
        
        wahoo = getWahoo([USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Warmup_Indicator\Trial' trial{ii} '\' WAHOO_FILE]);
        sweep = sweepSync(sweep, wahoo.StartTime);  % sync sweep time series with Wahoo start time (UTC)
        ind = find(diff(wahoo.interval));   % find points in time when wahoo laps change
        laps{1} = 'start';  % event marker
        lapTimes = 0;
        for kk = 1:numel(ind); laps{kk+1} = ['lap' num2str(wahoo.interval(ind(kk)))]; end
        laps{end+1} = 'end';
        lapTimes(2:numel(ind)+1) = wahoo.time(ind);
        lapTimes(end+1) = wahoo.time(end);
        
        % Plot results
        generateAssessmentPlot(sweep, process)
        if strcmp(printYN, 'Yes')
            print([FILE_PATH 'Trial' trial{ii} '_Summary' IMG_SUFFIX], '-dmeta')
        end
        subplot(2,1,1)
        plot(sweep.time, sweep.count15)
        xlabel('time (s)')
        ylabel('ADC Counts, 15mm')
        grid
        axis tight
        showEvents(laps, lapTimes);
        legend(leds, 'Location', 'Best')
        subplot(2,1,2)
        plot(sweep.time, sweep.count27)
        xlabel('time (s)')
        ylabel('ADC Counts, 27mm')
        grid
        axis tight
        showEvents(laps, lapTimes);
        %         subplot(3,1,3)
        %         plot(sweep.imu_time, sweep.Gyro_x.^2+sweep.Gyro_y.^2)
        %         xlabel('time (s)')
        %         ylabel('Ang. velocity (deg/s)')
        %         grid
        %         axis tight
        if strcmp(printYN, 'Yes')
            print([FILE_PATH 'Trial' trial{ii} '_Counts' IMG_SUFFIX], '-dmeta')
        end
        clf;
        plot(sweep.time, process.HR)
        hold on
        plot(wahoo.time, wahoo.hr_heartrate, 'r')
        grid; axis tight
        xlabel('time (s)')
        ylabel('Hear rate (bpm)')
        showEvents(laps, lapTimes);
        legend('Insight', 'Wahoo', 'Location', 'Best')
        title(['Samp. freq. = ' num2str(sweep.samp_rate) ' Hz - Trial ' trial{ii}])
        hold off
        if strcmp(printYN, 'Yes')
            print([FILE_PATH 'Trial' trial{ii} '_HR' IMG_SUFFIX], '-dmeta')
        end
        
        % Extract mu_eff data
        for ll = 1:numel(laps)
            indRange = findRange(sweep.time, lapTimes(ll)+RANGE);    % find range of indices between start and end times
            for kk = 1:numLeds
                temp = process.mu_eff(indRange,kk);
                %mu_eff(ii).(laps{ll})(kk) =  median(temp(isfinite(temp)));   % find median effective attenuation coefficients (1/mm)
                data.(laps{ll}).mu_eff(ii,kk) =  median(temp(isfinite(temp)));
            end
        end
        
        clear('laps', 'lapTimes')
    end
end

%% Summarize results
genBoxPlots(data)
fl = fields(data);
for ii = 1:numel(fl)
    mu = zeros(numTrials,numLeds);
    [~, minInd] = min(sum(data.(fl{ii}).mu_eff.^2, 2));
    table(leds, data.(fl{ii}).mu_eff(minInd,:)', 'VariableNames', {'Wavelength' ['mu_eff_' fl{ii}]})
    fprintf('Trial = %s', trial{minInd})
end

