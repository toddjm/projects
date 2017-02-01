function [ assessment ] = getAssessment( id, varargin )
%[ assessment ] = getAssessment( id, varargin )
% Returns information about a list of assessments from the server
%
% Inputs:
% id - string with id of assessment of interest, or cell
% array with strings containing a list of assessments.
%
% Examples:
%
% Assessment = getAssessments('limit', 10, 'status', 'COMPLETE')
% Returns first 10 completed tests
%
% Assessment = getAssessment('5515958badac18db278b4d27')
% Returns assessment data for id of 5515958badac18db278b4d27
%
% Outputs:
% Assessment - structure (or array of structures) containing a set of
% Assessment information on the server
%
% See also urlread, parse_json, base64decode
%
% P. Silveira and Nithin Rajan, March. 2015

%% Initializations

Base_URL = 'https://api.bsxinsight.com';
Assessment_URL = [Base_URL '/v2/getassessment'];


%% Get assessment(s) and parse json strings


if ischar(id),
    str = makeRequestUrlRead2([Assessment_URL '/' id], 'GET', '');  % query an individual device
    assessment = parse_json(str);
else if iscell(id)
        for ii = 1:numel(id),
            str = makeRequestUrlRead2([Assessment_URL '/' char(id(ii))], 'GET', '');  % query an individual device
            assessment{ii} = parse_json(str);
        end
    else
        error('id must be either a string or cell array')
    end
end



