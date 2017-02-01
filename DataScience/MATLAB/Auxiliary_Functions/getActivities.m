function [ Assessments ] = getActivities( varargin )
% limit={integer} -- the number you want per page
% status={COMPLETE|ERROR} -- the status of the assessment
% sport={bike|run} -- sport
% dateBegin={same format as devices endpoint} -- find everything that was created on or after this date
% dateEnd={same format as above} -- find everything that was created before this date
% page={integer} --- will select which page of results you want to see
%
%
% Examples:
%
% Assessment = getActivities('limit', '10', 'status', 'COMPLETE')
% Returns first 10 completed test
% See also urlread, parse_json, base64decode
%
% P. Silveira and Nithin Rajan, March. 2015

%% Get assessment(s) and parse json strings

Base_URL = 'https://api.bsxinsight.com'; % production server
%Base_URL = 'http://devapi.bsxinsight.com'; % development server
AllAssessments_URL = [Base_URL '/allactivities'];

body = '';  % convert from cell array to string
for ii = 1:2:numel(varargin)
    body = [body varargin{ii} '=' varargin{ii+1} '&'];
end
str = makeRequestUrlRead2([AllAssessments_URL '?' body], 'GET', '');
Assessments = parse_json(str);