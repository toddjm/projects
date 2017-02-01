function [ moxy ] = getMoxy( infile )
% Reads content of Moxy CSV file infile and returns a moxy structure.
%
% Inputs
% infile - complete path of input CSV file
%
% Outputs
% moxy - structure with the following fields
%   time - time in seconds, starting from zero
%   SmO2Live - SmO2 values, in whole percentages, with limited filtering.
%   SmO2Avg - SmO2 values, in whole percentages, with additional filtering.
%   THb - total hemoglobin (g/dL)
%   Lap - Lap number (integer)
%   SessionCT - session count (integer)
%
% See also
% getCSV, getSweep
%
% P. Silveira, Sep. 2015
% BSX Proprietary

formatDate = 'dd-mm HH:MM:SS';
HEADERLINES = 5;

fid = fopen(infile);
if fid<0
    error(['Could not open file ' infile]);
end

temp = textscan(fid, '%s %s %f32 %f32 %f32 %d8 %d', 'CollectOutput', true, 'HeaderLines', HEADERLINES, 'Delimiter', ',');

% Read time, in seconds, starting from 0s
dateTime = temp{1};
try     % Unfortunately, errors in Moxy files are common. Let's catch them!
    for ii = 1:length(dateTime)
        dateStr = [dateTime{ii,1} ' ' dateTime{ii,2}];
        if dateStr == ' '   % some files end with empty spaces, which would cause an error if not stopped
            ii = ii-1;
            break
        end
        [Y, M, D, H, MN, S] = datevec(dateStr, formatDate);
        time(ii) = D*86400+H*3600+MN*60+S;  % convert day, hour, minutes and seconds to seconds. Fails if data collection goes to the next day of the following month.
    end
catch err
    fprintf(2,'Error in moxy file %s, line %d.\n', infile, ii+HEADERLINES);
    fclose(fid);
    rethrow(err);
end
st.time = time-min(time(1:ii));  % start at zero
st.StartDate = dateTime{1,1};     % get start date
st.StartTime = dateTime{1,2};  % get start time
len = ii;%length(time); % vector length

% Read SmO2 values
numericData = temp{2};
st.SmO2Live = numericData(1:len,1);
st.SmO2Avg = numericData(1:len,2);

% Read remaining fields
st.THb = numericData(1:len,3);
st.Lap = temp{3}(1:len);
st.SessionCt = temp{4}(1:len);

% Find boundaries
ind = find(diff(st.Lap));    % list of indices where Laps change
ind(length(ind)+1) = len;    % include last index
numLaps = length(ind);
if numLaps > 1
    moxy(1) = subStruct(st, [1:ind(1)]);
    for ii = 1:numLaps-1
        moxy(ii+1) = subStruct(st, [ind(ii)+1:ind(ii+1)]);
        moxy(ii+1).time = moxy(ii+1).time - moxy(ii+1).time(1);    % reset time
        moxy(ii+1).StartDate = dateTime{ind(ii+1),1};
        moxy(ii+1).StartTime = dateTime{ind(ii+1),2};
    end
else
    moxy = st;
end

fclose(fid);

end

