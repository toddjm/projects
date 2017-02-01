% SortAssessment.m - Script created to sort assessments stored at \Google Drive\Tech_RD\Sensor\Research\LT Assessments
% CD to that folder before running.
%
% N. Rajan and P. Silveira, Nov. 2015
% BSX Proprietary

subFolder = 'ERROR';  % set to 'COMPLETE' or 'ERROR' to sort through different lists
sortField = 'sport';    % select what field you want to sort by under assessment structure
sweeps_files_list = what(subFolder);
fileList = {};
for filen = sweeps_files_list.mat'
    pathn = [subFolder '\' filen{1}];
    temp = load(pathn, 'assessment');
    if isfield(fileList, temp.assessment.(sortField))
        fileList.(temp.assessment.(sortField)){end+1} = pathn;
    else
        fileList.(temp.assessment.(sortField)){1} = pathn;
    end
end
save(['Sorted_List_of_' subFolder '_Assessments'], 'fileList')
for fieldName = fieldnames(fileList)'   % save again in Excel format
    xlswrite(['Sorted_List_of_' subFolder '_Assessments.xlsx'], (fileList.(fieldName{1}))', fieldName{1})
end

% for i=1:numel(sweeps_files_list.mat)
%     temp = load(sweeps_files_list.mat{i});
%     if strcmp(temp.assessment.sport,'run')
%         movefile(sweeps_files_list.mat{i},'../RUN','f'); %movefile(strcat('RUN/',sweeps_files_list.mat{i}));
%     end
% end
