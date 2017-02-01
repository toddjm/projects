% Script used to obtain IMU data from LT database
%

%% Initialize
clear
close all

sweepFields = {'samp_rate' 'imu_samp_rate' 'device' 'Acc_y' 'Acc_z' 'Gyro_x' 'Gyro_y' 'HR' 'PacePower' 'SDS_speed' 'SDS_cadence'};
assessmentFields = {'sport' 'completed_on' 'completed_stages'};
protocolFields = {'calibration_period' 'stages'};

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\LT Assessments\COMPLETE\'];
OUT_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Heart Rate\Development\HR_stats\'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
IN_FILE = ['*' SWEEP_SUFFIX];    % string used to identify input files

%% Data input

files = dir([FILE_PATH IN_FILE]);
numFiles = length(files);
for ii = 1:numFiles
    fprintf('Processing file #%d/%d\n', ii, numFiles)
    load([FILE_PATH files(ii).name])
    id = files(ii).name(1:end-length(SWEEP_SUFFIX));
    for jj = 1:length(sweepFields)
        if isfield(sweep, sweepFields{jj})
            data(ii).(sweepFields{jj}) = sweep.(sweepFields{jj});
        end
    end
    assessment = getAssessment(id);
    data(ii).assessment = id;
    for jj = 1:length(assessmentFields)
        if isfield(assessment, assessmentFields{jj})
            data(ii).(assessmentFields{jj}) = assessment.(assessmentFields{jj});
        end
    end
    for jj = 1:length(protocolFields)
        if isfield(assessment.protocol, protocolFields{jj})
            data(ii).protocol.(protocolFields{jj}) = assessment.protocol.(protocolFields{jj});
        end
    end
end

%% Data output
save([OUT_PATH 'IMU_data.mat'], 'data')
fprintf('Done!')

