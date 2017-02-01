%% Outline
% 1. Input oxy
% 2. Run deploy script with force option.
% 3. print out file results (LT, Dmax, LTHR, DmaxHR)


%% Initialize
clear all
close all
initProcess

%% Input The Assessment
assessment_ID = inputdlg('Enter assessment ID number:');
fileExt = 'url';    % flag URL selection
assessment = getAssessment(assessment_ID{1});

%% Set fullfile 
oxyfile = strcat(pwd,'\',assessment_ID{1},'.oxy');
finalfile = strrep(oxyfile,'oxy','out');

%% Process Assessment
if isfield(assessment.links, 'oxy')
        urlwrite(assessment.links.oxy,strcat(assessment.alpha__id,'.oxy'))
        scriptProcess
else
    fprintf('No Oxy files available in asessment! \n')
    return
end

close all
