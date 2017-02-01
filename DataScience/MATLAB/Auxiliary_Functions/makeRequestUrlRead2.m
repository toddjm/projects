% function [ output ] = makeRequestUrlRead2( url, method, body, varargin )
% Function used to read URL data from an authenticated page without
% requesting a new authentication token, unless if needed.
%
% Inputs
% url - string with url to be read
% method - string with URL method.  Examples: 'GET' 'POST' etc
% body - (vector)(char, uint8 or int8) body to write, generally used 
%               with POST or PUT, use of uint8 or int8 ensures that the 
%               body input is not manipulated before sending, char is sent
%               via unicode2native function with ENCODING input. See
%               urlread2 for more details.
% varargin - other arguments to be passed to urlread2
%
% Outputs
% output - structure with output arguments
%
% N. Rajan, 2015
% BSX Proprietary

function [ output ] = makeRequestUrlRead2( url, method, body, varargin )
    header.name = 'Authorization';
    header.value = getToken( false );   % first try without renewing token
    [output, extras] = urlread2(url, method, body, header, varargin{:});
    if extras.status.value == 401   % if that fails, get new token and try again
        getToken( true );
        output = makeRequestUrlRead2(url, method, body, varargin{:});
    end
end