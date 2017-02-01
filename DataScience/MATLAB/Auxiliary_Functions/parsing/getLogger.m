function [ logger ] = getLogger( infile )
% Reads content of data logger CSV file (infile) and returns them into a structure (logger).
%
% Inputs
% infile - complete path of input CSV file
%
% Outputs
% logger - structure. Fields are
%   time - time series (s)
%   temperature - temperature in deg Fahrenheit
%   humidity - relative humidity (%)
%   dewpoint - dew point (deg. Fahrenheit)
%   StartTime - starting time of time series
%   StartDate - starting date of time series
%
% See also
% getMoxy, getWahoo, getSweep, getZephyr, getCorTemp
%
% BSX Proprietary

formatIn = 'yyyy-mm-dd HH:MM:SS';  % format of input date and time';
dateFormatOut = 'yyyy/mm/dd';   % format of output date
timeFormatOut = 'HH:MM:SS'; % format of output time
HEADERLINES = 2;    % lines to skip

fid = fopen(infile);
if fid<0
    error(['Could not open file ' infile]);
end

%temp = textscan(fid, '%s', 2, 'Delimiter', '\n');  % read header and first line
data = textscan(fid, '%d %s %f32 %f32 %f32', 'CollectOutput', true, 'Delimiter', ',', 'Headerlines', HEADERLINES);   % read remaining data
dateTime = data{2};
dateTimeVec = datevec(dateTime, formatIn);

numData = data{3};
logger.temperature = numData(:,1);
logger.humidity = numData(:,2);
logger.dewpoint = numData(:,3);
logger.time = dateTimeVec(:,3)*86500+dateTimeVec(:,4)*3600+dateTimeVec(:,5)*60+dateTimeVec(:,6);    % create time array (s)
logger.time = logger.time - min(logger.time(:));        % time starts at zero
logger.StartDate = datestr(dateTimeVec(1,:), dateFormatOut);
logger.StartTime = datestr(dateTimeVec(1,:), timeFormatOut);

fclose(fid);

end

