function [ zephyr ] = getZephyr( infile )
% Reads content of Zephyr's Summary CSV file (infile) and returns them into a structure (zephyr).
%
% Inputs
% infile - complete path of input CSV file
%
% Outputs
% zephyr - structure. Fields are given by the first line before the
% beginning of data. Data is assume to be single-precision floating point.
%
% See also
% getMoxy, getWahoo, getSweep
%
% BSX Proprietary

formatTime = 'dd/mm/yyyy HH:MM:SS.FFF'; % format of input date and time
dateFormatOut = 'yyyy/mm/dd';   % format of output date
timeFormatOut = 'HH:MM:SS.FFF'; % format of output time
%HEADERLINES = 1;
%HEADER_STR = 'pwr_accdist';
%HD_OFFSET = -17;

fid = fopen(infile);
if fid<0
    error(['Could not open file ' infile]);
end

% % Read start date and time
% temp = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s', 1, 'HeaderLines', HEADERLINES, 'Delimiter', ',');
% zephyr.StartDate = cell2mat(strcat(temp{2}, '/', temp{4}, '/', temp{6}));
% zephyr.StartTime = cell2mat(strcat(temp{8}, ':', temp{10}, ':', temp{12}));

% Find start of data series
% while ~strcmp(temp{2}, HEADER_STR) && ~feof(fid)
%     temp = textscan(fid, '%s %s', 1, 'Delimiter', ',');
% end
% fseek(fid, HD_OFFSET, 0);  % go back to beginning of header
header = fgets(fid);
fl = strsplit(header(1:end-2), ',');   % find fields. Avoid end of line.
numFields = length(fl);
formatStr = '%s'; % text parsing string, starting with a string for Time field
for ii = 1:numFields
    formatStr = [formatStr '%f32 '];
end
temp = textscan(fid, formatStr, 'CollectOutput', true, 'Delimiter', ',');   % read remaining data
data = temp{2};
for ii = 1:numFields-1
    zephyr.(fl{ii+1}) = data(:,ii);
end
timeStr = temp{1};  % convert time field
temp = datevec(timeStr, formatTime);
zephyr.StartDate = datestr(temp(1,:), dateFormatOut);   % find start date and time
zephyr.StartTime = datestr(temp(1,:), timeFormatOut);
zephyr.time = temp(:,3)*86500+temp(:,4)*3600+temp(:,5)*60+temp(:,6);    % create time array (s)
zephyr.time = zephyr.time - min(zephyr.time(:));        % time starts at zero

fclose(fid);

end

