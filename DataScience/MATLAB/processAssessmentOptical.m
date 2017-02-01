%% Outline
% 1. DL optical file
% 2. Recalcuate the smo2 values (Direct and Proj)
% 3. Plot the comparison of the two
% 4. Make a Oxy file with the new recalcuated data
% 5. Run deploy script with force option.
% 6. print out file results (LT, Dmax, LTHR, DmaxHR)


%% Initialize
clear all
close all
initProcess

%% DL The Assessment
assessment_ID = inputdlg('Enter assessment ID number:');
fileExt = 'optical';%'url';    % flag URL selection
assessment = getAssessment(assessment_ID{1});
oxyfile = strcat(pwd,'\',assessment_ID{1},'.oxy');
finalfile = strrep(oxyfile,'oxy','out');
sweep = getSweep(strcat(assessment_ID{1},'.optical'), TEMP_CSV); % get raw data, save csv file to temporary file
device = getDevice(sweep.device_id);    % get device data
[AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent device calibration data
recalucateProcess
postProcess
oxyProcess
scriptProcess
%pathname = pwd; file = strcat('\',assessment.alpha__id); printProcess;
close all


