function [ AssessmentList, assessmentStruc ] = getAssessmentList( varargin )
% function [ AssessmentList, assessmentStruc ] = getAssessmentList( varargin )
%% Get list of assessment using search terms
%
% Example:
%
% AssessmentList = getAssessmentList('status','ERROR')
% Returns list of assessment with status of ERROR (NOTE: search terms are case sensitve)
%
% Outputs:
% AssessmentList - Returns a nx6 cell array that fit these search terms.
% There are n assessment that fit the search result and 6 columns:
% Assessment ID
% Type (Assessment or Activity)
% User ID
% Sport (bike or run)
% Created at Time
% Status (COMPLETE, ERROR, PROCESSING, QUEUED)
% Note: Only search by status, date, and sport. You CANNOT search by page.
%
% See also getAssessments, getAssessment
%
% Nithin Rajan, April. 2015
% BSX Proprietary

assessmentPages = getAssessments(varargin{:});
numPages = 1+assessmentPages.last_page-assessmentPages.current_page;
k=0;
for j=1:numPages
    Assessments = getAssessments(varargin{:}, 'page', num2str(j));
    if numPages < 2 || numel(Assessments.data) == 0     % empty query
        AssessmentList = [];    % return empty array
        return
    end
    for i=1:length(Assessments.data),
        k=k+1;
        fl = fields(Assessments.data{1,i});
        for jj = 1:numel(fl)
              AssessmentList{k,jj} = Assessments.data{1,i}.(fl{jj});
        end
%         AssessmentList{k,1} = Assessments.data{1,i}.alpha__id;
%         AssessmentList{k,2} = Assessments.data{1,i}.type;
%         AssessmentList{k,3} = Assessments.data{1,i}.user_id;
%         AssessmentList{k,4} = Assessments.data{1,i}.sport;
%         AssessmentList{k,5} = Assessments.data{1,i}.created_at;
%         AssessmentList{k,6} = Assessments.data{1,i}.status;
        assessmentStruc{k} = Assessments.data{i}; % passess complete structure
    end
end

