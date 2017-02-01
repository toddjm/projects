function [ checkouts ] = getDeviceChks( varargin )
%[ device ] = getDevice( mac_address, varargin )
% Returns device calibration record from the server
%
% Inputs:
% mac_address - string with mac address of device of interest, or cell
% array with strings containing a list of devices
% varargin - list of query parameters.
%
% Examples:
%
% getDeviceChks( 'status', '1')
% Returns all devices with error code 1
%
% getDeviceChks( 'status', '0', 'dateBegin', '20150202', 'dateEnd', '20150210')
% Returns all devices with no error code, calibrated between Feb. 2nd and
%
% Outputs:
% checkouts - cell array with all device checkouts that match the query
%
% See also
% AllCntAnalysis, getAllCnt, getDevice
%
% P. Silveira, Aug. 2015
% BSX Athletics Proprietary

%% Initializations

Base_URL = 'https://api.bsxinsight.com';
Devices_URL = [Base_URL '/devices'];

%% Get device(s) and parse json strings

if ~isempty(varargin) % varargin must contain query
    body = '';  % convert from cell array to string
    for ii = 1:2:numel(varargin)
        body = [body varargin{ii} '=' varargin{ii+1} '&'];
    end
    str = makeRequestUrlRead2([Devices_URL '?' body], 'GET', '');
    checkouts = parse_json(str);
else
    error('varargin must contain query to server')
end

