% Script created to get LT statistics from successful assessments
% PPTFILEN - complete path of output PowerPoint file, if given.
% P. Silveira, July 2015
% BSX Proprietary

%% Initializations

clear all
close all
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)

%UNIQUE = 1; % set to one to select a unique assessment per user;

% User entered parameters
EXCLUDED_USERS = {'492'};
EXCLUDED_ASSESSMENTS = {'55640aceadac18f20e8b55d1' '556FA3CE07C519F1048B4573' '557e1d0d07c519650f8b45b3' '54d8db8fadac18f10e8b4a3a', '5548f027adac18f10e8b52fb', '5534f1d8adac18f10e8b5147', '552828d4adac18f10e8b4f64', '5527f24aadac18f20e8b4ff2', '5526d19aadac18f20e8b4fb3','55204442adac18db278b4e82', '5523b4dbadac18db278b4ee8', '5522fc64adac18db278b4ed5', '55228e7fadac18f20e8b4eb8', '55157c8aadac18db278b4d23', '54e49349adac18db278b4b79','54e469c5adac18f20e8b4b76', '54dcb6ffadac18f20e8b4b1d', '54dba24fadac18db278b4b07', '55546d8dadac18f10e8b53e0','553fbc52adac18f10e8b523c', '553360aaadac18db278b520e', '552712a3adac18f20e8b4fd0'};    % list of assessments to be excluded
% ST_RANGE = [75:1075];  % starting range (15s to 215s)
% END_RANGE = [4500:5500];    % end range (900s to 1100s)
% PERCENTILE = 10;    % percentile used to remove outliers on trimmean calculations
% PP_THR = 10;    % post-processing threshold (counts)
% AMB_THR = 10000; % ambient light threshold (counts)
% BODY_PART = 'calf';
PPTDIR = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\User_assessments'];  % initial path for saving PowerPoint file with intermediate results
PPTFILEN = 'Assesssment_Analysis_plots';    % default filename of PowerPoint file with intermediate results
SAVE_RESULTS = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\User_assessments\LT_Analysis_results']; % path were results are saved at the end

% Other system parameters
DATE_FORMAT = 'yyyy-mm-dd HH:MM:SS'; % date format used by server in queries
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
% Filename of powerPoint file with intermediate plots characterizing each assessment. Comment out if this option is not desired.
PPT_EXT = '.ppt';   % PowerPoint file extension
FONTSIZE = 11;  % size of fonts used in plots
% leds = getLeds; % LED centroid wavelengths
% currents = getCurrents; % get 25 nominal current values (Amps)end
% MU = 'mu_a';    % pseudo-inverse method
% mu_s = calc_mu_s(leds, BODY_PART)/10; % if second argument is not set, calc_mu_s assumes we are monitoring a calf
jj = 0; % valid assessment counter
usr_idx = 0;    % user index

% query = questdlg('Would you like to save intermediate results?');
% PPT_FLAG = strcmp(query,'Yes'); % generate flag for saving intermediate PowerPoint results
% if PPT_FLAG
%     PPTDIR = uigetdir(PPTDIR);  % confirm directory
%     PPT_PATH = [PPTDIR '\' PPTFILEN '_' date PPT_EXT]
%     ppt = saveppt2(PPT_PATH, 'init');    % open file for saving
% end

%% Process data
assessmentMat = getAssessmentList('status', 'COMPLETE'); % Get all completed assessments from server

% sort assessments by date
[dates, sort_idx] = sort(datenum(assessmentMat(:,5), DATE_FORMAT),'descend');   % extract dates and convert to numeric form
sortedAssessments = assessmentMat(sort_idx,:); % sort assessments by date
% if UNIQUE
%     [uniqueUsers, uid_idx]  = unique(sortedAssessments(:,3));   % find unique user ids
%     assessmentList = sortedAssessments(uid_idx,:);  % select 1 assessment per user, in sorted order
% else
assessmentList = sortedAssessments;
% end

num_tot_assessments = length(assessmentList);   % total number of assessments to be processed
fprintf('%d assessments to be processed.\n', num_tot_assessments)

% if PPT_FLAG
%     saveppt2('ppt', ppt, 'textbox', ['Analysis date: ' date '\n Processing ' num2str(num_tot_assessments) ' assessments.\n PP_THR = ' num2str(PP_THR) '\nAMB_THR = ' num2str(AMB_THR) '\nBODY_PART = ' BODY_PART])
%     figure(1);  % prepare figure with intermediate results
%     set(1, 'Position', [830 247 907 420]);
% end

% Retrieve assessments
for ii = 1:num_tot_assessments
    fprintf('Processing assessment %d: ', ii);
    assessment = getAssessment(assessmentList{ii,1});
    if exist('EXCLUDED_ASSESSMENTS', 'var') && any(strcmpi(assessment.alpha__id, EXCLUDED_ASSESSMENTS)), % ignore anomalous assesments
        fprintf('Excluding assessment %s.\n', assessment.alpha__id);
        continue
    end
    if isfield(assessment, 'entry_type') && ~strcmp(assessment.entry_type, 'insight')
        fprintf('Entry type = %s. Skipping\n', assessment.entry_type);
        continue
    end
    %     if ~isfield(assessment, 'links') || ~isfield(assessment.links, 'optical')    % scan only through assessment which have a valid optical file
    %         fprintf('No optical file. Skipping.\n');
    %         continue
    %     end
    if isfield(assessment, 'user_id') && exist('EXCLUDED_USERS', 'var') && any(strcmpi(assessment.user_id, EXCLUDED_USERS)), % ignore test users
        fprintf('Excluding assessment performed by user %s.\n', assessment.user_id);
        continue
    end
    %     try
    %         sweep = getSweep(assessment.links.optical, TEMP_CSV); % get sweep data, save csv file to temporary file
    %     catch
    %         fprintf('Defective sweep file. Skipping.\n')
    %         continue    % skip defective sweeps
    %     end
    %     szct = size(sweep.count15);
    %     if szct(1) < END_RANGE(end)
    %         fprintf('File too short (%d samples). Skipping.\n', szct(1))
    %         continue    % skip short assessments
    %     end
    %     device = getDevice(sweep.device_id);    % get device data
    %     [AllCnt,invC15,invC27,diag] = getAllCnt( device, 1 ); % get most recent device calibration data
    %     if isfield(diag, 'CalibrationStatus') && diag.CalibrationStatus     % check for non-zero device calibration status
    %         fprintf('Non-zero device calibration status = %d on device %s. Skipping.\n', diag.CalibrationStatus, sweep.device_id);
    %         continue
    %     end
    %     [OD15, OD27] = processCounts(sweep, AllCnt, currents, PP_THR, AMB_THR);
    %     cHb15 = OD15 * invC15';
    %     cHb27 = OD27 * invC27';
    %     sweep.tHb_15 = sum(cHb15,2);   % total hemoglobin from re-calculated concentrations
    %     sweep.tHb_27 = sum(cHb27,2);
    %     sweep.SmO2_15 = cHb15(:,2) ./ sweep.tHb_15;   % using re-calculated concentrations
    %     sweep.SmO2_27 = cHb27(:,2) ./ sweep.tHb_27;
    %     ODDiff = OD27-OD15; % differential OD
    %     [SmO2, R, mu_eff, HbF] = calc_SmO2(ODDiff, MU, BODY_PART);   % calculate SmO2, Residuals, mu_eff and total hemoglobin
    jj = jj + 1;    % checked all exceptions. Ok to increase valid assessment counter
    incl_assessment{jj} = assessment; % keep track of successfully accepted assessments, in case we need to go back to an individual one for more analysis.
    %     device_id(:,jj) = device.device_id;
    %    user_id{jj} = assessment.user_id;  % keep track of unique users
    LT1(jj) = NaN;
    LT2(jj) = NaN;
    if  ~isfield(assessment, 'lthr') || isempty(assessment.lthr)
        lthr(jj) = NaN;
    else
        lthr(jj) = assessment.lthr;
        LT2(jj) = assessment.lthr;
    end
    if ~isfield(assessment, 'lt1hr') || isempty(assessment.lt1hr)
        lt1hr(jj) = NaN;
    else
        lt1hr(jj) = assessment.lt1hr;
        LT1(jj) = assessment.lt1hr;
    end
    if ~isfield(assessment, 'stage_at_lt') || isempty(assessment.stage_at_lt)
        stage_at_lt(jj) = NaN;
    else
        stage_at_lt(jj) = assessment.stage_at_lt;
    end
    if ~isfield(assessment, 'stage_at_lt_value') || isempty(assessment.stage_at_lt_value)
        stage_at_lt_value(jj) = NaN;
    else
        stage_at_lt_value(jj) = assessment.stage_at_lt_value;
    end
    if ~isfield(assessment, 'calculated_lt_speed') || isempty(assessment.calculated_lt_speed)
        calculated_lt_speed(jj) = NaN;
    else
        calculated_lt_speed(jj) = assessment.calculated_lt_speed;
    end
    if ~isfield(assessment, 'calculated_lt1_speed') || isempty(assessment.calculated_lt1_speed)
        calculated_lt1_speed(jj) = NaN;
    else
        calculated_lt1_speed(jj) = assessment.calculated_lt1_speed;
    end
    if ~isfield(assessment, 'calculated_lt_power') || isempty(assessment.calculated_lt_power)
        calculated_lt_power(jj) = NaN;
    else
        calculated_lt_power(jj) = assessment.calculated_lt_power;
    end
    if ~isfield(assessment, 'calculated_lt1_power') || isempty(assessment.calculated_lt1_power)
        calculated_lt1_power(jj) = NaN;
    else
        calculated_lt1_power(jj) = assessment.calculated_lt1_power;
    end
    %%
    if isfield(assessment, 'training_zones')
        if isfield(assessment.training_zones, 'exertion') && ~isempty(assessment.training_zones.exertion)
            LT2predLT1(jj) = assessment.training_zones.exertion{2}.max;  % End of zone 2 (Aerobic threshold, as predicted by LT2)
        elseif isfield(assessment.training_zones, 'hr') && ~isempty(assessment.training_zones.hr)
            LT2predLT1(jj) = assessment.training_zones.hr{2}.max;  % End of zone 2 (Aerobic threshold, as predicted by LT2)
        else
            LT2predLT1(jj) = NaN;
        end
    end
    
    %     mu_eff_Start(:,jj)  = trimmean(mu_eff(ST_RANGE,:), PERCENTILE, 1); % store one mu_eff value for every user
    %     mu_eff_End(:,jj) = trimmean(mu_eff(END_RANGE,:), PERCENTILE, 1);
    %     count15Start(:,jj) = trimmean(sweep.count15(ST_RANGE,:), PERCENTILE, 1);
    %     count15End(:,jj) = trimmean(sweep.count15(END_RANGE,:), PERCENTILE, 1);
    %     count27Start(:,jj) = trimmean(sweep.count27(ST_RANGE,:), PERCENTILE, 1);
    %     count27End(:,jj) = trimmean(sweep.count27(END_RANGE,:), PERCENTILE, 1);
    %     current15End(:,jj) = trimmean(sweep.current15(END_RANGE,:), PERCENTILE, 1);
    %     current27End(:,jj) = trimmean(sweep.current27(END_RANGE,:), PERCENTILE, 1);
    %     if PPT_FLAG     % save plots to PowerPoint
    %         generateAssessmentPlot(sweep, SmO2, R, HbF)
    %         saveppt2('ppt', ppt, 'fig', 1, 'stretch', 'off', 'textbox', ['Assessment ' assessment_id{jj} ' from user ' user_id{jj} ' completed on ' assessment.completed_on])
    %     end
    if isfield(assessment, 'user_id') && isfield(assessment, 'user_id')
        fprintf('Successfully processed assessment from user %s performed on %s.\n', assessment.user_id, assessment.completed_on)
    else
        fprintf('Successfully processed assessment.\n')
    end
end
numAssessments = jj;    % number of successfully processed assessments
%[uniqueUsers, uid_idx] = unique(incl_assessment.user_id);
fprintf('%d assessments successfully processed.\n', numAssessments);
% if PPT_FLAG     % close PowerPoint file, if ppt filename is defined
%     clf
%     saveppt2('ppt', ppt, 'textbox', [num2str(numAssessments) ' optical files successfully processed from ' num2str(length(uniqueUsers)) ' unique users.\n'])
%     saveppt2(PPT_PATH, 'ppt', ppt, 'close');
% end

%% Data analysis

ltHRratio = lthr ./ lt1hr;  % Heart rate Lactate Threshold ratios
ltSpeedRatio = calculated_lt_speed ./ calculated_lt1_speed; % LT speed ratios

% This script takes a long time to run, so let's make sure to save results.
save([SAVE_RESULTS '_' date '.mat']);
fprintf('Results saved to file %s\n', [SAVE_RESULTS '.mat'])

%% Display results

figure(1)
plot(ltHRratio)
axis tight; grid
ylabel('HR LT ratio',  'FontSize', FONTSIZE)
xlabel('Assessments', 'FontSize', FONTSIZE)
%set(gcf, 'Position', [807 -7 560 728]);

figure
plot(ltSpeedRatio)
axis tight; grid
ylabel('Calculated speed LT ratio', 'FontSize', FONTSIZE)
xlabel('Assessments', 'FontSize', FONTSIZE)
%set(gcf, 'Position', [807 -7 560 728]);

%reply = input('Save figures to PowerPoint file (Y/N)?','s');
reply = questdlg('Save figures to PowerPoint file?');
if strcmp(reply,'Yes')
    saveAssessmentPPT([SAVE_RESULTS '_' date PPT_EXT], ['Analysis of completed assessments' '\n# of assessments = ' num2str(numAssessments) '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART]);
end

