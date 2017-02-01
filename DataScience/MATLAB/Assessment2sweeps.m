% Script created to convert assessments from the server into MATLAB
% sweep structures. Sweep files are saved as .mat files on Google Drive,
% where they can be more easily (and quickly) accessed by MATLAB scripts.
%
% See also
% assessmentAnalysis
%
% P. Silveira, Sep. 2015
% BSX Proprietary

%% Initializations

clear all
close all
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)

% User entered parameters
STATUS = 'COMPLETE';    % assessment status (and sub-folder where to save results). 'COMPLETE' or 'ERROR'
SAVE_RESULTS = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\LT Assessments\' STATUS '\']; % path were results are saved at the end
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
RESWEEP_FLAG = 0; % set to one if you want to overwrite existing sweep files

% Other system parameters
dateBegin = '20160205';     % date, in YYYYMMDD format, with earliest assessment to be included. Comment out to include all assessments.
DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format used by server in queries
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
jj = 0; % valid assessment counter
usr_idx = 0;    % user index

%% Process data

fprintf('Querying server for %s assessments.\n', STATUS)
if exist('dateBegin', 'var')
    [~, assessmentMat] = getAssessmentList('status', STATUS, 'dateBegin', dateBegin); % Query assessments from server
else
    [~, assessmentMat] = getAssessmentList('status', STATUS); % Query assessments from server
end

% sort assessments by date
for ii = 1:length(assessmentMat)
    dates{ii} = assessmentMat{ii}.created_at;
end
[dates, sort_idx] = sort(datenum(dates, DATE_FORMAT),'descend');   % extract dates and convert to numeric form
assessmentList = assessmentMat(sort_idx); % sort assessments by date
num_tot_assessments = length(assessmentList);   % total number of assessments to be processed
fprintf('%d assessments to be processed.\n', num_tot_assessments)

% Retrieve assessments
for ii = 1:num_tot_assessments
    fprintf('Processing assessment %d/%d: ', ii, num_tot_assessments);
    try
        assessment = getAssessment(assessmentList{ii}.alpha__id);
    catch err
        try     % if at first you don't succeed, try again... (sometimes we get 504 - server timeout errors)
            assessment = getAssessment(assessmentList{ii}.alpha__id);
        catch err
            fprintf(2,'Error getting assessment %s. Skipping.\n', assessmentList{ii}.alpha__id);
            fprintf(2,'Error message = %s\n', err.identifier)
            continue
        end
    end
    if exist('EXCLUDED_ASSESSMENTS', 'var') && any(strcmpi(assessment.alpha__id, EXCLUDED_ASSESSMENTS)), % ignore anomalous assesments
        fprintf('Excluding assessment %s.\n', assessment.alpha__id);
        continue
    end
    if exist('EXCLUDED_USERS', 'var') && any(strcmpi(assessment.user_id, EXCLUDED_USERS)), % ignore test users
        fprintf('Excluding assessment performed by user %s.\n', assessment.user_id);
        continue
    end
    if ~isfield(assessment, 'links') || ~isfield(assessment.links, 'optical')    % scan only through assessment which have a valid optical file
        fprintf('No optical file. Skipping.\n');
        continue
    end
    fileN = [SAVE_RESULTS assessment.alpha__id SWEEP_SUFFIX];
    if ~RESWEEP_FLAG && exist(fileN, 'file')
        fprintf('Skipping existing file %s\n', fileN)
        continue
    end
    try
        sweep = getSweep(assessment.links.optical, 'false'); % get sweep data, save csv file to temporary file
    catch err
        fprintf(2,'Defective sweep file. Skipping.\n')
        fprintf(2,'Error message = %s\n', err.identifier)
        continue    % skip defective sweeps
    end
    try     % don't stop because of a bug
        device = getDevice(sweep.device_id);    % get device data
        
    catch err
        fprintf(2, '%s. Skipping assessment.\n', err.message)
        continue
    end
    
    save(fileN, 'sweep', 'assessment', 'device');
    jj = jj + 1;    % increment successful processing counter
    if isfield(assessment, 'completed_on')
        fprintf('Successfully processed assessment from user %s performed on %s.\n', assessment.user_id, assessment.completed_on)
    else
        fprintf('Successfully processed assessment from user %s.\n', assessment.user_id)
    end
end
%numAssessments = jj;    % number of successfully processed assessments
%[uniqueUsers, uid_idx] = unique(user_id);
fprintf('%d optical filess successfully processed.\n', jj);



