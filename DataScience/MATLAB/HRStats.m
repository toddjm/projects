% Script used to obtain statistics from HR data in LT database
%

%% Initialize
clear
close all


MAX_HR = 270;

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\LT Assessments\COMPLETE\'];
OUT_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Heart Rate\Development\HR_stats\'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
IN_FILE = ['*' SWEEP_SUFFIX];    % string used to identify input files
IMG_SUFFIX = '.png';
printYN = questdlg('Save results?');

%% Data input


aggregate_HR = zeros(MAX_HR,1);
number_of_subjects = 0;
figure
set(gcf, 'Position', [713 176 960 544])
files = dir([FILE_PATH IN_FILE]);
numFiles = length(files);
for ii = 1:numFiles
    load([FILE_PATH files(ii).name])
    id = files(ii).name(1:end-length(SWEEP_SUFFIX));
    if ~isfield(sweep, 'HR') || isempty(sweep.HR(isfinite(sweep.HR)))
        continue
    end
    number_of_subjects = number_of_subjects + 1;
    heart_rate(number_of_subjects).id = id;
    heart_rate(number_of_subjects).HR = sweep.HR;
    heart_rate(number_of_subjects).time = sweep.time;
    for jj = 1:length(sweep.HR)
        if isfinite(sweep.HR)
            aggregate_HR(sweep.HR(jj)) = aggregate_HR(sweep.HR(jj))+1;
        end
    end
    
    %
    %     % Plots
    %     generateAssessmentPlot(sweep, process)
    plot(sweep.time, sweep.HR)
    grid; axis tight
%    title(['Assessment ' id])
    xlabel('time (s)')
    ylabel('HR (bpm)')
%    hold on
    if strcmp(printYN, 'Yes')
        print([OUT_PATH id IMG_SUFFIX], '-dpng')
    end
end

aggregate_HR = aggregate_HR / number_of_subjects;
save([OUT_PATH 'heart_rate.mat'], 'heart_rate', 'aggregate_HR')

figure
plot(aggregate_HR)
xlabel('HR (bpm)')
ylabel('# of occurrances per user')
axis tight
grid
