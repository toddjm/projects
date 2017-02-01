function Errorlist = getErrorList(AssessmentList, str)
% Get list of assessment using search terms
% 
% Example:
%
% ErrorList = getErrorList('UNHANDLED EXCEPTION')
% Returns list of assessment with UNHANDLED EXCEPTION in the error
% description (NOTE: search terms are case sensitve)
%
% Outputs:
% Returns a cell array on length n that fit these search terms.
%
% See also getAssessmentList, getAssessment
%
% Nithin Rajan, April. 2015

Errorlist = {};
ii = 0;
for i=1:length(AssessmentList),
    Aid = AssessmentList{i,1};
    Atemp = getAssessment(Aid);
    if isfield(Atemp, 'error')
        if ~isempty(strfind(Atemp.error.description, str))
            ii = ii+1;
            Errorlist{ii} = Atemp.alpha__id;
        end
    end
end
