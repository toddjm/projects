% Script used to process data from the Tape Removal study
% See \Google Drive\Tech_RD\Sensor\Research\Testing\Ambient light with sleeve modifications\Tape_Removal

%% Initialize
clear
close all

% EVENTS{4,7} = [];   % create cell array (max. dim.)
% EVENT_TIMES(4,7) = 0;
% EVENTS(1,1:6) = {'Start' '1' '2' '3' '4' 'End'};
% EVENT_TIMES(1,1:6) = [0 60 120 180 240 300];
% EVENTS(2,:) = EVENTS(1,:);
% EVENT_TIMES(2,:) = EVENT_TIMES(1,:);
% EVENTS(3,1:5) = {'Indoors' 'Start' '4' '3' 'End'};
% EVENT_TIMES(3,1:5) = [0 60 120 180 240];
% EVENTS(4,:) = {'Indoors' 'Start' '8' '7' '6' '5' 'End'};
% EVENT_TIMES(4,:) = [0 60 120 180 240 300 360];
EVENT_TIMES = [0 60 120 180 240 300];
EVENTS = {'Start' '1' '2' '3' '4' 'End'};
RANGE = [20, 50];   % data range to be used (s)

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Ambient light with sleeve modifications\Tape_Removal\'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
IN_FILE = 'Trial*.bin';    % string used to identify input files
PROCESS_SUFFIX = '_process.mat';
IMG_SUFFIX = '.png';
printYN = questdlg('Save results?');

%% Data input

figure
set(gcf, 'Position', [713 176 960 544])
trials = dir([FILE_PATH IN_FILE]); 
numTrials = length(trials);
for ii = 1:numTrials
        [~, filen] = fileparts(trials(ii).name);
        pathn = [FILE_PATH filen];
        sweepFilen =  [pathn SWEEP_SUFFIX];
        processFilen =  [pathn PROCESS_SUFFIX];
        fprintf('Processing trial %d\n', ii);
        if ~exist(processFilen, 'file')
%             activity = getActivity(activity_id);
            sweep = getSweep([FILE_PATH trials(ii).name])
            process = sweep2process(sweep)
            save(sweepFilen, 'sweep')
            save(processFilen, 'process')
        else
            load(sweepFilen)
            load(processFilen)
        end
        cont = 1;   % counter
        for jj = 1:numel(EVENT_TIMES)-1     % find ambient light plateaus
            temp = baselineStats(sweep.ambient, findRange(sweep.time, EVENT_TIMES(jj)+RANGE));
            if isfield(temp, 'baseline')
                ambient(cont) = temp.baseline;
                cont = cont+1;
            end
        end        
        % Plots
        generateAssessmentPlot(sweep, process)
        if strcmp(printYN, 'Yes')
            print([FILE_PATH 'Trial' num2str(ii) '_Summary' IMG_SUFFIX], '-dpng')
        end
        clf
        plot(sweep.time, sweep.ambient)
        xlabel('time (s)')
        ylabel('Ambient (counts)')
        axis tight
        grid
        showEvents(EVENTS, EVENT_TIMES, ambient)
        title(['Tape removal - Trial ' num2str(ii)])
        if strcmp(printYN, 'Yes')
            print([FILE_PATH 'Trial' num2str(ii) '_Ambient' IMG_SUFFIX], '-dpng')
        end           
end


