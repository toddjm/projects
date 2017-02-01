function [ activity ] = getActivity( id, varargin )
% function [ activity ] = getActivity( id )
% Returns information about a list of activities from the server
%
% Inputs:
% id - string with id of activity of interest, or cell
% array with strings containing a list of activities.
%
% Examples:
%
%
% activity = getActivity('564b72bd07c51960668b4571')
% Returns activity data for activity id 564b72bd07c51960668b4571
%
% Outputs:
% activity - structure (or array of structures) containing a set of
% Assessment information on the server
%
% See also urlread, parse_json, base64decode
%
% P. Silveira and Nithin Rajan, March. 2015

%% Initializations

%Base_URL = 'http://devapi.bsxinsight.com';  % development server
Base_URL = 'https://api.bsxinsight.com';   % production server
activity_URL = [Base_URL '/getactivity'];


%% Get activity(s) and parse json strings


if ischar(id),
    str = makeRequestUrlRead2([activity_URL '/' id], 'GET', '');  % query an individual device
    activity = parse_json(str);
else if iscell(id)
        for ii = 1:numel(id),
            str = makeRequestUrlRead2([activity_URL '/' char(id(ii))], 'GET', '');  % query an individual activity
            activity{ii} = parse_json(str);
        end
    else
        error('id must be either a string or cell array')
    end
end



