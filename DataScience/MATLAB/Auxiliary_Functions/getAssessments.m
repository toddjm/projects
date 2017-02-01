function [ Assessments ] = getAssessments( varargin )
% limit={integer} -- the number you want per page
% status={COMPLETE|ERROR} -- the status of the assessment
% sport={bike|run} -- sport
% dateBegin={YYYYMMDD} -- find everything that was created on or after this date
% dateEnd={same format as above} -- find everything that was created before this date
% page={integer} --- will select which page of results you want to see
%
%
% Examples:
%
% Assessment = getAssessments('limit', '10', 'status', 'COMPLETE')
% Returns first 10 completed test
%
% Assessment = getAssessments('dateBegin', '20150202', 'dateEnd', '20150210')
% Returns all assessments entered between Feb. 2nd and Feb. 10th 2015.
%
% See also urlread, parse_json, base64decode
%
% P. Silveira and Nithin Rajan, March. 2015

%% Get assessment(s) and parse json strings

Base_URL = 'https://api.bsxinsight.com'; % production server
%Base_URL = 'http://devapi.bsxinsight.com'; % development server
AllAssessments_URL = [Base_URL '/allassessment'];

body = '';  % convert from cell array to string
for ii = 1:2:numel(varargin)
    body = [body varargin{ii} '=' varargin{ii+1} '&'];
end
str = makeRequestUrlRead2([AllAssessments_URL '?' body], 'GET', '');
Assessments = parse_json(str);