function [ sweep, CSVpath ] = getSweep( assessment, saveCSV)
% function [ sweep, CSVpath ] = getSweep( assessment, saveCSV)
%
% Reads a BSXInsight sweep (or assessment) data file. Accepts either
% binary, .optical, CSV or _sweep.mat files, or a server URL pointing at the assessment
% optical data. Also accepts an assessment structure, as output by a
% getAssessment function call.
%
% Saves a MATLAB files with a _sweep.mat extension containing the sweep
% structure. Optionally, also saves a CSV file if a complete pathname is
% provided in the saveCSV input parameter. If you don't want to save a
% _sweep.mat file, set saveCSV to 'false' (string).
%
% Example:
% assessment = getAssessment('5515958badac18db278b4d27');   % get information for assessment 5515958badac18db278b4d27
% sweep = getSweep(assessment);
%
% Inputs:
% assessment - complete path of file to be converted into sweep structure. Can be a URL (for accessing an optical file from the server) or a
% pathname (CSV, .bin or .optical file). Can also be an assessment strucutre or a string with assessment ID.
% saveCSV - Optional (str). Pathname where CSV file is saved. No file is
% saved if undefined. Set to false to also prevent the saving of a
% _sweep.mat file.
%
% Outputs:
% sweep - structure of arrays with fields
%     sweep.flash_schame - data format used to store data in FLASH (uint16)
%     sweep.device_id - device serial number (string). Usually its MAC ID.
%     sweep.UTCtime - time of sweep (string).
%     sweep.date - date of sweep (string).
%     sweep.FW_version - firmware version of device used to collect data.
%     sweep.assessment - assessment ID.
%     sweep.samp_rate - sampling rate (Hz) of optical data.
%     sweep.imu_samp_reate - samplint rate (Hz) of IMU data.
%     sweep.hw_version - version of device hardware used to collect data.
%     sweep.sport - string with sport type selected for data collection. 
%     sweep.current15 - current (Amp) of 15mm LEDs.
%     sweep.current27 - current (Amp) of 27mm LEDs.
%     sweep.ambient - ambient light counts.
%     sweep.count15 - counts produced by 15mm LEDs.
%     sweep.count27 - counts produced by 27mm LEDs.
%     sweep.cHhb_15mm - deoxyhemoglobin concentration at 15mm spacing (unknown units).
%     sweep.cHbO2_15m - oxyhemoglobin concentration at 15mm spacing (unknown units).
%     sweep.cHhb_27mm - deoxyhemoglobin concentration at 27mm spacing (unknown units).
%     sweep.cHbO2_27mm - oxyhemoglobin concentration at 27mm spacing (unknown units).
%     sweep.SmO2 - SmO2 values calculated by the device.
%     sweep.Acc_y - IMU accelerometer data, y axis.
%     sweep.Acc_z - IMU accelerometer data, z axis.
%     sweep.Gyro_x - IMU gyroscope data, x axis.
%     sweep.Gyro_y - IMU gyroscope data, y axis.
%     sweep.Pace_on_dev - IMU pace data (m/s).
%     sweep.time - time array (seconds) with same number of elements as sweep matrices.
%     sweep.Alert - logical array with the values of alert status bits (True = 1).
%     sweep.SDS_speed - speed (m/s) from ANT-attached device
%     sweep.SDS_cadence - cadence (steps/min) from ANT-attached device
%
% CSVpath - path of CSV file. Returns an empty string if conversion fails.
% If assessment already points to a CSV file, than CSVpath = assessment.
% Also saves a _sweep.mat file to the save path.
%
% See also
% getAssessment, processCounts, getCSV, getDevice, getAllCnt, devAnalysis
%
% P. Silveira, March 2015.
% BSX Athletics Proprietary

% Initialization

global USERPATH 
global SWEEP_SUFFIX     % this variable is defined here. Made global so that it can (doesn't need to be) used elsewhere

USERPATH = getenv('USERPROFILE');
BIN2CSV_CONV = ['"' USERPATH '\Google Drive\Tech_RD\Sensor\Research\SW and FW Archive\BSXInsightDeviceRecordParser\BSX.Insight.DeviceRecordParserApp.exe"'];
%BIN2CSV_CONV = ['"' USERPATH '\Google Drive\Tech_RD\Sensor\Research\SW and FW Archive\BSXInsightDeviceRecordParser\BSX.Insight.DeviceRecordParserApp_Schema37.exe"'];
TEMP_CSV = [USERPATH '\temp.csv'];
TEMP_PYTHON = [USERPATH '\temp_python.csv'];
TEMP_BIN = [USERPATH '\temp.bin'];
URL_PART = 'https://';  % string always found on URLs
SWEEP_SUFFIX = '_sweep.mat';    % suffix of sweep files

if exist('saveCSV', 'var') && ~strcmp(saveCSV, 'false')   % make sure variable exists and is not set to false
    CSVpath = saveCSV;
    [pathstr,name,ext] = fileparts(saveCSV);
    SWEEP_FILE = [pathstr '\' name SWEEP_SUFFIX];
else
    CSVpath = '';   % start with empty string
end

if numel(assessment) > numel(URL_PART) && strcmpi(URL_PART, assessment(1:numel(URL_PART)))  % check for URL input
    urlwrite(assessment, TEMP_BIN); % write temporary binary file
    COMMAND = [BIN2CSV_CONV ' "' TEMP_BIN '" ' TEMP_CSV];   % DOS command used for BIN to CSV conversion
    assessment = TEMP_BIN;  % use path of temporary binary file
    if ~exist('SWEEP_FILE', 'var')
        SWEEP_FILE = [USERPATH '\temp' SWEEP_SUFFIX];
    end
    ext = '.bin';
elseif isfield(assessment, 'links')  % input is a structure. Use link to optical file
    if numel(assessment.links.optical) < numel(URL_PART) || ~strcmpi(URL_PART, assessment.links.optical(1:numel(URL_PART)))  % check for URL input
        warning(['Invalid URL link = ' assessment.links.optical]);
        sweep = []; % invalid URL. Return empty sweep structure.
        return
    end
    urlwrite(assessment.links.optical, TEMP_BIN); % write temporary binary file
    COMMAND = [BIN2CSV_CONV ' "' TEMP_BIN '" ' TEMP_CSV];   % DOS command used for BIN to CSV conversion
    assessment = TEMP_BIN;  % use path of temporary binary file
    ext = '.bin';
    if ~exist('SWEEP_FILE', 'var')
        SWEEP_FILE = [USERPATH '\temp' SWEEP_SUFFIX];
    end
else% must be a file input
    COMMAND = [BIN2CSV_CONV ' "' assessment '" ' TEMP_CSV];   % DOS command used for BIN to CSV conversion
    [pathstr,name,ext] = fileparts(assessment);
    if ~exist('SWEEP_FILE', 'var')
        if isempty(pathstr)     % no path given. Use current path
            pathstr = pwd;
        end
        SWEEP_FILE = [pathstr '\' name SWEEP_SUFFIX];
    end
end

% File reading
switch ext
    case ''  % no file selected
        return;
    case {'.bin', '.optical'}  % bin file selected. Convert to CSV
        [out, cmdout] = dos(COMMAND);
        if out==2   % CRC error
            warning(cmdout) % treat CRC errors differently. Display warning but do not stop.
        elseif out  % other error
            error(cmdout)
        else if ~isempty(CSVpath)   % No error. Check if path was given where to save converted CSV file 
                status = copyfile(TEMP_CSV, CSVpath, 'f'); % copy csv file to selected path
                if ~status, % check for copy errors
                    CSVpath = '';
                end
            end
        end
        TEMP_CSV = parseCSV(TEMP_CSV, TEMP_PYTHON);
    case '.csv'  % csv file selected
        CSVpath = assessment;
        TEMP_CSV = parseCSV(assessment, TEMP_PYTHON);
    case '.mat' % sweep file selected
        if strcmp(assessment(end-length(SWEEP_SUFFIX)+1:end), SWEEP_SUFFIX)
            load(assessment)
            return
        else
            error(['Not a sweep file! File name = ' assessment])
        end
    otherwise
        error(['Unrecognized file extension: ' ext])
        return
end

% Read CSV file data
sweep = getCSV(TEMP_CSV);
if ~exist('saveCSV', 'var') || ~strcmp(saveCSV, 'false')
    save(SWEEP_FILE, 'sweep');  % save sweep file, if saveCSV is not set to false
end

% Cleanup
if exist(TEMP_BIN, 'file')
    delete(TEMP_BIN);
end
if exist(TEMP_PYTHON, 'file')
    delete(TEMP_PYTHON);
end
if exist(TEMP_CSV, 'file')
    delete(TEMP_CSV);
end

function pathout = parseCSV(pathn, pathout)
global USERPATH

%USERPATH = getenv('USERPROFILE');
SIMPLE_FILTER_PATH = which('bsx_simple_filter_csv.py');
COMMAND = ['python "' SIMPLE_FILTER_PATH '" "' pathn '" "' pathout '"'];
%COMMAND = ['python "' USERPATH '\Google Drive\Tech_RD\Sensor\Research\SW and FW Archive\Python Apps\bsx_simple_filter_NoEmpty_csv.py' '" "' pathn '" "' pathout '"'];
%Convert CSV file to a file with no rows before optical data, no empty lines and no Infinity values
[out, cmdout] = dos(COMMAND);
if out
    error(cmdout)
end



