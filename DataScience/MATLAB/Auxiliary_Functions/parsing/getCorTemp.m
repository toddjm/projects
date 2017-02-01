function [ corTemp ] = getCorTemp( infile )
% Reads content of CorTemp's CSV file (infile) and returns them into a structure (corTemp).
%
% Inputs
% infile - complete path of input CSV file
%
% Outputs
% corTemp - structure. Fields are
%   time - time series (s)
%   temperature - temperature in deg Fahrenheit
%   StartTime - starting time of time series
%   StartDate - starting date of time series
%
% See also
% getMoxy, getWahoo, getSweep, getZephyr
%
% BSX Proprietary

formatIn = 'mm/dd/yyyy HH:MM:SS';  % format of input date and time
formatTime = 'HH:MM:SS';
dateFormatOut = 'yyyy/mm/dd';   % format of output date
timeFormatOut = 'HH:MM:SS'; % format of output time

fid = fopen(infile);
if fid<0
    error(['Could not open file ' infile]);
end

data = textscan(fid, '%s %s %f32 %s', 'CollectOutput', true, 'Delimiter', ',');   % read remaining data
dateTime = data{1};
dateTimeVec = datevec([dateTime{1,1} ' ' dateTime{1,2}], formatIn);
corTemp.StartDate = datestr(dateTimeVec, dateFormatOut);
corTemp.StartTime = datestr(dateTimeVec, timeFormatOut);
temp = datevec(dateTime(:,2));  % convert time field
corTemp.time = temp(:,3)*86500+temp(:,4)*3600+temp(:,5)*60+temp(:,6);    % create time array (s)
corTemp.time = corTemp.time - min(corTemp.time(:));        % time starts at zero
corTemp.temperature = data{2};

fclose(fid);

end

