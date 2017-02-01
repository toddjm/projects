function [ wahoo ] = getWahoo( infile )
% Reads content of Wahoo's CSV file infile and returns a wahoo structure.
%
% Inputs
% infile - complete path of input CSV file
%
% Outputs
% wahoo - wahoo structure. Fields are given by the first line before the
% beginning of data. Data is assume to be single-precision floating point.
%
% See also
% getMoxy, wahooTS, getSweep
%
% BSX Proprietary

formatDate = 'dd-mm HH:MM:SS';
HEADERLINES = 1;
HEADER_STR = 'pwr_accdist';
HD_OFFSET = -17;

fid = fopen(infile);
if fid<0
    error(['Could not open file ' infile]);
end

% Read start date and time
temp = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s', 1, 'HeaderLines', HEADERLINES, 'Delimiter', ',');
wahoo.StartDate = cell2mat(strcat(temp{2}, '/', temp{4}, '/', temp{6}));
wahoo.StartTime = cell2mat(strcat(temp{8}, ':', temp{10}, ':', temp{12}));

% Find start of data series
while ~strcmp(temp{2}, HEADER_STR) && ~feof(fid)
    temp = textscan(fid, '%s %s', 1, 'Delimiter', ',');
end
fseek(fid, HD_OFFSET, 0);  % go back to beginning of header
header = fgets(fid);
fl = strsplit(header(1:end-2), ',');   % find fields. Avoid end of line.
numFields = length(fl);
formatStr = ''; % text parsing string
for ii = 1:numFields
    formatStr = [formatStr '%f32 '];
end
temp = textscan(fid, formatStr, 'CollectOutput', true, 'Delimiter', ',');   % read remaining data
data = temp{1};
for ii = 1:numFields
    wahoo.(fl{ii}) = data(:,ii);
end

% % Find boundaries
% ind = find(diff(st.interval));    % list of indices where Laps change
% ind(end+1) = len;    % include last index
% numLaps = length(ind);
% if numLaps > 1
%     wahoo(1) = subStruct(st, [1:ind(1)]);
%     for ii = 1:numLaps-1
%         wahoo(ii+1) = subStruct(st, [ind(ii)+1:ind(ii+1)]);
%         wahoo(ii+1).time = wahoo(ii+1).time - wahoo(ii+1).time(1);    % reset time
%         wahoo(ii+1).StartDate = dateTime{ind(ii+1),1};
%         wahoo(ii+1).StartTime = dateTime{ind(ii+1),2};
%     end
% else
%     wahoo = st;
% end

fclose(fid);

end

