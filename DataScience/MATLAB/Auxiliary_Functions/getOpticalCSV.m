function [ data ] = getOpticalCSV( pathn )
% function [ data ] = getOpticalCSV( pathn )
%
% Parses assessment and sweep data from CSV file. Returns parsed fields in a
% structure.
%
% Inputs
% pathn - input file name (complete path). Must be a CSV file.
%
% Outputs
% data - output structure with parsed data
%
% See also
% getSweep, getDevice
%
% N. Rajan, September 2015.
% BSX Athletics Proprietary

% Initialize
HEADER_ROWS = 3;    % default number of rows used by header;

USERPATH = getenv('USERPROFILE');
COMMAND = ['python ' '"' USERPATH '\Google Drive\Tech_RD\Web Apps\BSXinsight\bsx_filter_csv.py' '" ' '"' pathn '"'];

[out, cmdout] = dos(COMMAND);

pathn = strrep(pathn,'.csv','_optical.csv');
infile = fopen(pathn, 'r');

% Start with CSV header
header = textscan(infile,'%s', HEADER_ROWS, 'delimiter', '\n');   % read header information
fields = textscan(header{1}{1}, '%s', 'delimiter', ',');    % parse field names
values = textscan(header{1}{2}, '%s', 'delimiter', ',');    % parse field values
for ii = 1:numel(fields{1}),
    str = values{1}{ii};
    switch fields{1}{ii}
        case {'Schema_version', 'FLASH_SCHEMA'}
            data.flash_schema = uint16(str2num(str));
        case {'Is_Daily_Activity', 'IS_DAILY_ACTIVITY'}
            switch str
                case {'1', 'True', 'TRUE'}
                    data.Is_Daily_Activity = true;
                case {'0', 'False', 'FALSE'}
                    data.Is_Daily_Activity = false;
                otherwise
                    warning(['Unexpected string in Is_Daily_Activity field = ' str])
            end
        case 'FW_REV'
            data.FW_version = str;
        case {'DEVICE_SN', 'DEVICE_ID'}
            data.device_id = removeChar(str, '-');     % remove '-', if any
            % Deal with legacy device numbers
            if numel(data.device_id) < 12,
                str = dec2hex(str2num(data.device_id));
                str2 = '';
                for ii = 1:4-numel(str),
                    str2 = [str2 '0'];  % pad with zeros
                end
                data.device_id = ['0CEFAF81' str2 str];
            end
        case 'DATE_TIME_UTC'
            str = values{1}{ii};
            ind = strfind(str, ' ');    % find space between date and time
            data.date = str(1:ind-1);   % parse date
            data.UTCtime = str(ind+1:end); % parse time
%         case 'TIME'
%             data.time = str;
        case 'ASSESSMENT_ID'
            data.assessment = removeChar(str,'-');
        case 'DATE'
            data.date = str;
        case {'SAMPLES_PER_SEC', 'OPTICAL_SAMPLES_PER_SEC'}
            data.samp_rate = single(str2num(str));
        case 'IMU_SAMPLES_PER_SEC'
            data.imu_samp_rate = single(str2num(str));
        case {'HW_VERSION'}
            data.HW_VERSION = uint16(num2str(str));
        case {'SPORT' 'SESSION_TYPE'}
            switch str
                case {'0'}
                    data.sport = 'calibration';
                case {'1', 'run'}
                    data.sport = 'run';
                case{'2', 'bike'}
                    data.sport = 'bike';
                otherwise
                    warning(['Unexpected sport = ' str])
                    data.sport = str;
            end
            %        otherwise
            %            error(['Unrecognized field: ' fields{1}{ii}])
    end
end

data_fields = textscan(header{1}{3}, '%s', 'delimiter', ',');    % parse numeric field names
numFields = numel(data_fields{1});

temp = importdata(pathn,',', HEADER_ROWS);  % Read one last time, this time hopefully skipping the correct number of header rows
rawdata = temp.data;

ii = 0; % loop counter
while ii < numFields, % parse through all fields of interest
ii = ii+1;  % always increment by at least one
%for ii = 1:numFields,   
    switch data_fields{1}{ii}
        case {'ADC_AMBIENT', 'NORM_AMBIENT'}
            data.ambient = single(rawdata(:,ii));
        case {'ADC_30mm@680', 'NORMV_30mm680'}
            data.count27 = single(rawdata(:,ii:ii+3));
            ii = ii+3;  % for loop overrides changes to the loop variable...
        case {'ADC_15mm@680', 'NORMV_15mm680'}
            data.count15 = single(rawdata(:,ii:ii+3));
            ii = ii+3;  % for loop overrides changes to the loop variable...
         case {'I_15mm_680'}   % newer schema are no longer reporting currents. All schema report current codes, so always use current codes instead
%             data.current15 = rawdata(:,ii:ii+3);
             ii = ii+3;     % skip (to save time)
         case 'I_30mm_680' % skip this one as well
%             data.current27 = rawdata(:,ii:ii+3);
             ii = ii+3;
        case {'Icode_15mm_680'}
            data.ccode15 = uint8(rawdata(:,ii:ii+3));
            ii = ii+3;  % for loop overrides changes to the loop variable...
        case 'Icode_30mm_680'
            data.ccode27 = uint8(rawdata(:,ii:ii+3));
            ii = ii+3;  % for loop overrides changes to the loop variable...
        case 'CPU_TEMP'
            data.cpuTemp = single(rawdata(:,ii));
        case 'BATTERY_VOLT'
            data.battVolt = single(rawdata(:,ii));
        case {'cHHb_15mm', 'cHhb_15mm'}
            data.cHhb_15mm = single(rawdata(:,ii));
        case {'cHHb_30mm', 'cHhb_27mm'}
            data.cHhb_27mm = single(rawdata(:,ii));
        case 'cHbO2_15mm'
            data.cHbO2_15mm = single(rawdata(:,ii));
        case {'cHbO2_30mm', 'cHbO2_27mm'}
            data.cHbO2_27mm = single(rawdata(:,ii));
        case 'HEART_RATE_BPM'
            data.HR = single(rawdata(:,ii));
        case {'BICYCLE_POWER_WATT', 'Pace/Power'}
            data.PacePower = single(rawdata(:,ii));
        case {'SmO2'}
            data.SmO2 = single(rawdata(:,ii));
        case {'cHHb_SmO2'}
            data.cHHb_SmO2 = single(rawdata(:,ii));
        case {'cHbO2_SmO2'}
            data.cHbO2_SmO2 = single(rawdata(:,ii));
        case {'cH2O_SmO2'}
            data.cH2O_SmO2 = single(rawdata(:,ii));
         case {'Alert_bitflags'}
             data.Alert = logical(de2bi(rawdata(:,ii),16));
    end
end

data.time = [1:length(rawdata)]'./ data.samp_rate;  % time array (seconds)
%fclose(infile); % make sure file is closed before leaving

end


