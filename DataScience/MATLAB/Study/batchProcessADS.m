% Script used to process files from Active Dehydration study. Use this
% script to pre-process files from each trial.
%
% BSX Proprietary

clear

% Constants
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
SWEEP_SUFFIX = '_sweep.mat';
PROCESS_SUFFIX = '_process.mat';
TRIAL_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Hydration\Active dehydration\'];
TRIAL_PATH = [uigetdir(TRIAL_PATH, 'Select trial to be processed') '\'];
PDF_FILE = [TRIAL_PATH 'Sensor_summary.pdf'];
NONBSX_FILE = [TRIAL_PATH 'Non-BSX Sensors.mat'];
WAHOO_FILE = [TRIAL_PATH 'Wahoo.csv'];   % Wahoo file name
ZEPHYR_ZIP = [TRIAL_PATH 'Bioharness.zip'];  % Zephyr zip file name
ZEPHYR_NEW_NAME = [TRIAL_PATH 'Zephyr_Summary.csv']; % Zephyr file name after unzipping and renaming
CORTEMP_FILE = [TRIAL_PATH 'CorTemp.cvt'];
LOGGER_FILE = [TRIAL_PATH 'Logger.txt'];
TEMP_DIR = [TRIAL_PATH 'Temp\'];    % directory for temporary unzipping of Zephyr data
BSX_TIME_OFFSET = 300;  % estimated mean time offset between start of insight data collection and Wahoo data collection (s)

%% Data input

% Wahoo file must exist since it is used to synchronize all other data
% streams.
if exist(WAHOO_FILE, 'file')
    wahoo = getWahoo(WAHOO_FILE);
else
    error(['Need Wahoo file to process trial data! Could not find file  ' WAHOO_FILE])
end

if exist(NONBSX_FILE, 'file')
    resp = questdlg(['Delete file ' NONBSX_FILE '?'], 'Log file detected', 'Yes');
    if strcmp(resp, 'Yes')
        delete(NONBSX_FILE)
        save(NONBSX_FILE, 'wahoo')
    else
        save(NONBSX_FILE, 'wahoo', '-append')
    end
else
    save(NONBSX_FILE, 'wahoo')
end

% Process Zephyr data
if exist(ZEPHYR_ZIP, 'file') && ~exist(ZEPHYR_NEW_NAME, 'file')
    mkdir(TEMP_DIR);
    unzip(ZEPHYR_ZIP, TEMP_DIR);
    temp = dir(TEMP_DIR);
    zephyr_file = dir([TEMP_DIR temp(3).name '\*Summary.csv']);
    movefile([TEMP_DIR temp(3).name '\' zephyr_file.name], ZEPHYR_NEW_NAME, 'f')
    zephyr = getZephyr(ZEPHYR_NEW_NAME);
    rmdir(TEMP_DIR, 's');
    zephyr = strSync(zephyr, wahoo.StartTime); % synchronize Zephyr and Wahoo data streams
    save(NONBSX_FILE, 'zephyr', '-append')
elseif exist(ZEPHYR_NEW_NAME, 'file')
    zephyr = getZephyr(ZEPHYR_NEW_NAME);
    zephyr = strSync(zephyr, wahoo.StartTime); % synchronize Zephyr and Wahoo data streams
    save(NONBSX_FILE, 'zephyr', '-append')
else
    warning(['Zephyr file not found! File = ' ZEPHYR_NEW_NAME])
end

if exist(CORTEMP_FILE, 'file')
    corTemp = getCorTemp(CORTEMP_FILE);
    corTemp = strSync(corTemp, wahoo.StartTime);
    save(NONBSX_FILE, 'corTemp', '-append')
else
    warning(['CorTemp file not found! File = ' CORTEMP_FILE])
end

if exist(LOGGER_FILE, 'file')
    logger = getLogger(LOGGER_FILE);
    logger = strSync(logger, wahoo.StartTime);
    save(NONBSX_FILE, 'logger', '-append')
else
    warning(['Logger file not found! File = ' LOGGER_FILE])
end

%% Plotting
temp_pdf = publish('batchProcessADS_plot.m', 'outputDir', TRIAL_PATH, 'format', 'pdf','showCode', false);
%new_pdf_file = [pathPDF file '.pdf'];
movefile(temp_pdf, PDF_FILE,'f'); % move pdf file to final destination, renaming it in the process
fprintf('Saved PDF to file %s\n', PDF_FILE)

close all

assessment_ID = inputdlg('Enter activity IDs', 'Select activities');
assessment_ID = strsplit(assessment_ID{1});

sensorNum = length(assessment_ID);
for ii = 1:sensorNum    % sweep file parsing loop
    fprintf('Parsing Sensor %d\n', ii)
    rootN = [TRIAL_PATH assessment_ID{ii} '_Sensor' num2str(ii)];   % root file name
    if ~exist([rootN SWEEP_SUFFIX], 'file')
        activity = getActivity(assessment_ID{ii});
        sweep = getSweep(activity);
        if strcmp(sweep.date, '0001/01/01')     % deal with lack of synchronization
            warning('Date set to 0001/01/01')
            sweep.date = wahoo.StartDate;
            sweep.UTCtime = datestr(datenum(wahoo.StartTime) - BSX_TIME_OFFSET/(24*3600), 'HH:MM:SS');
            sweep.time = sweep.time - BSX_TIME_OFFSET;
            sweep.RefTime = wahoo.StartTime;
        else
            sweep = strSync(sweep, wahoo.StartTime);
        end
        save([rootN SWEEP_SUFFIX], 'sweep')
    end
end
for ii = 1:sensorNum    % sweep file processing loop
    fprintf('Processing Sensor %d\n', ii)
    rootN = [TRIAL_PATH assessment_ID{ii} '_Sensor' num2str(ii)];   % root file name
    load([rootN SWEEP_SUFFIX])
    if ~exist([rootN PROCESS_SUFFIX], 'file')
        process = sweep2process(sweep);
        save([rootN PROCESS_SUFFIX], 'process')
    else
        load([rootN PROCESS_SUFFIX])
    end
    figure(ii)
    set(gcf, 'Position', [394 248 1077 539]);
    generateAssessmentPlot(sweep, process)
    print([rootN '.png'], '-dpng')
end

fprintf('Done processing files in folder %s\n', TRIAL_PATH)




