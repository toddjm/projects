function [ data ] = getCSV( pathn )
% function [ data ] = getCSV( pathn )
%
% Parses sweep data from CSV file. Returns parsed fields in a
% structure. Expects CSV file to have a fixed number of rows (3) before the
% start of optical data. Usually that's not the case, in which case
% getSweep sould be called first, since that function handles file
% conversion before calling getCSV.m
%
% Inputs
% pathn - input file name (complete path). Must be a CSV file with 3 header rows.
%
% Outputs
% data - output structure with parsed data
%
% See also
% getSweep, getDevice
%
% P. Silveira, March 2015
% N. Rajan, September 2015.
% BSX Athletics Proprietary

% Initialize
HEADER_ROWS = 3;    % default number of rows used by header;
infile = fopen(pathn, 'r');
IMU_FIELDS = {'Acc_y' 'Acc_z' 'Gyro_x' 'Gyro_y' 'Pace_on_dev'}; % fields used by IMU
DEFAULT_IMU_SAMP_RATE = 20; % default IMU sampling rate. Used when IMU data is present but sampling rate is not provided in the header.

% Start with CSV header
header = textscan(infile,'%s', HEADER_ROWS, 'delimiter', '\n');   % read header information
fields = textscan(header{1}{1}, '%s', 'delimiter', ',');    % parse field names
values = textscan(header{1}{2}, '%s', 'delimiter', ',');    % parse field values
fclose(infile);
for ii = 1:numel(fields{1}),
    str = values{1}{ii};
    switch fields{1}{ii}
        case {'Schema_version', 'FLASH_SCHEMA'}
            data.flash_schema = uint16(str2num(str));
        case {'Is_Daily_Activity', 'IS_DAILY_ACTIVITY'}
            switch str
                case {'1', 'True', 'TRUE', 'true'}
                    data.Is_Daily_Activity = true;
                case {'0', 'False', 'FALSE', 'false'}
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
        case {'SportType' 'sportType'}
            data.SportType = str;
            %        otherwise
            %            error(['Unrecognized field: ' fields{1}{ii}])
    end
end

if data.flash_schema == 34
    data_fields{1} = {'NORM_AMBIENT' 'NORMV_15mm680' 'NORMV_15mm810' 'NORMV_15mm850' 'NORMV_15mm970' 'Icode_15mm_680' 'ICODE_15mm_810' 'Icode_15mm_850' 'Icode_15mm_970' 'I_15mm_680' 'I_15mm_810' 'I_15mm_850' 'I_15mm_970' 'NORMV_30mm680' 'NORMV_30mm810' 'NORMV_30mm850' 'NORMV_30mm970' 'Icode_30mm_680' 'ICODE_30mm_810' 'Icode_30mm_850' 'Icode_30mm_970' 'I_30mm_680' 'I_30mm_810' 'I_30mm_850' 'I_30mm_970' 'ACC_Y' 'ACC_Z' 'GYRO_X' 'GYRO_Y' 'PACE_ON_DEV(m/s)' 'CPU_TEMP' 'BATTERY_VOLT' 'HEART_RATE_BPM' 'BICYCLE_POWER_WATT' 'cHHb_15mm' 'cHbO2_15mm' 'cHHb_30mm' 'cHbO2_30mm' 'SmO2' 'cHHb_SmO2' 'cHbO2_SmO2' 'cH2O_SmO2' 'Alert_bitflags'};
else
    data_fields = textscan(header{1}{3}, '%s', 'delimiter', ',');    % parse numeric field names
end
numFields = numel(data_fields{1});

% Read rest of data
temp = importdata(pathn,',', HEADER_ROWS);
rawdata = temp.data;
nanInd = isnan(rawdata(:,1));   % find NaN rows in data
ind = find(~nanInd);  % select rows with valid optical data
IMUind = find(nanInd); % select IMU data as invalid optical data

ii = 0; % loop counter
while ii < numFields, % parse through all fields of interest
    ii = ii+1;  % always increment by at least one
    switch data_fields{1}{ii}
        case {'ADC_AMBIENT', 'NORM_AMBIENT'}
            data.ambient = single(rawdata(ind,ii));
        case {'ADC_30mm@680', 'NORMV_30mm680'}
            data.count27(:,1) = single(rawdata(ind,ii));
            %            ii = ii+3;  % for loop overrides changes to the loop variable... Can no longer skip. Need flexibility to read partial number of LEDs (or, soon, more than 4 wavelengths).
        case {'ADC_30mm@810', 'NORMV_30mm810'}
            data.count27(:,2) = single(rawdata(ind,ii));
        case {'ADC_30mm@850', 'NORMV_30mm850'}
            data.count27(:,3) = single(rawdata(ind,ii));
        case {'ADC_30mm@970', 'NORMV_30mm970'}
            data.count27(:,4) = single(rawdata(ind,ii));
        case {'ADC_15mm@680', 'NORMV_15mm680'}
            data.count15(:,1) = single(rawdata(ind,ii));
        case {'ADC_15mm@810', 'NORMV_15mm810'}
            data.count15(:,2) = single(rawdata(ind,ii));
        case {'ADC_15mm@850', 'NORMV_15mm850'}
            data.count15(:,3) = single(rawdata(ind,ii));
        case {'ADC_15mm@970', 'NORMV_15mm970'}
            data.count15(:,4) = single(rawdata(ind,ii));
            %            ii = ii+3;  % for loop overrides changes to the loop variable...
        case {'NORMV_LED0', 'NORMV_LED1', 'NORMV_LED2', 'NORMV_LED3', 'NORMV_LED4', 'NORMV_LED5', 'NORMV_LED6', 'NORMV_LED7', 'NORMV_LED8', 'NORMV_LED9', 'NORMV_LED10', 'NORMV_LED11', 'NORMV_LED12', 'NORMV_LED13', 'NORMV_LED14', 'NORMV_LED15'}
            num = str2num(data_fields{1}{ii}(10:end))+1;
            data.count(:,num) = single(rawdata(ind,ii)); % prototype count
        case {'Icode_LED0', 'Icode_LED1', 'Icode_LED2', 'Icode_LED3', 'Icode_LED4', 'Icode_LED5', 'Icode_LED6', 'Icode_LED7', 'Icode_LED8', 'Icode_LED9', 'Icode_LED10', 'Icode_LED11', 'Icode_LED12', 'Icode_LED13', 'Icode_LED14', 'Icode_LED15'}
            num = str2num(data_fields{1}{ii}(10:end))+1;
            data.ccode(:,num) = single(rawdata(ind,ii)); % prototype current code
        case {'I_15mm_680', 'I_30mm_680', 'I_15mm_810', 'I_30mm_810','I_15mm_850', 'I_30mm_850','I_15mm_950', 'I_30mm_950', }   % newer schema are no longer reporting currents. All schema report current codes, so always use current codes instead
            %             data.current15 = rawdata(ind,ii:ii+3);
            ii = ii+1;     % skip (to save time)
        case {'Icode_15mm_680'}
            data.ccode15(:,1) = uint8(rawdata(ind,ii));
            %            ii = ii+3;  % for loop overrides changes to the loop variable...
        case {'Icode_15mm_810', 'ICODE_15mm_810'}
            data.ccode15(:,2) = uint8(rawdata(ind,ii));
        case {'Icode_15mm_850'}
            data.ccode15(:,3) = uint8(rawdata(ind,ii));
        case {'Icode_15mm_970'}
            data.ccode15(:,4) = uint8(rawdata(ind,ii));
        case 'Icode_30mm_680'
            data.ccode27(:,1) = uint8(rawdata(ind,ii));
            %            ii = ii+3;  % for loop overrides changes to the loop variable...
        case {'Icode_30mm_810', 'ICODE_30mm_810'}
            data.ccode27(:,2) = uint8(rawdata(ind,ii));
        case 'Icode_30mm_850'
            data.ccode27(:,3) = uint8(rawdata(ind,ii));
        case 'Icode_30mm_970'
            data.ccode27(:,4) = uint8(rawdata(ind,ii));
        case 'CPU_TEMP'
            data.cpuTemp = single(rawdata(ind,ii));
        case 'BATTERY_VOLT'
            data.battVolt = single(rawdata(ind,ii));
        case {'cHHb_15mm', 'cHhb_15mm'}
            data.cHhb_15mm = single(rawdata(ind,ii));
        case {'cHHb_30mm', 'cHhb_27mm'}
            data.cHhb_27mm = single(rawdata(ind,ii));
        case 'cHbO2_15mm'
            data.cHbO2_15mm = single(rawdata(ind,ii));
        case {'cHbO2_30mm', 'cHbO2_27mm'}
            data.cHbO2_27mm = single(rawdata(ind,ii));
        case 'HEART_RATE_BPM'
            data.HR = single(rawdata(ind,ii));
        case {'AVG_BICYCLE_POWER_WATT', 'BICYCLE_POWER_WATT', 'Pace/Power'}
            data.PacePower = single(rawdata(ind,ii));
        case {'INST_BICYCLE_POWER_WATT'}
            data.InstPower = single(rawdata(ind,ii));
        case {'BICYCLE_CADENCE_RPM'}
            data.BikeCadence = single(rawdata(ind,ii));
        case {'SmO2'}
            data.SmO2 = single(rawdata(ind,ii));
        case {'tHb'}
            data.tHb = single(rawdata(ind,ii));
        case {'cHHb_SmO2'}
            data.cHHb_SmO2 = single(rawdata(ind,ii));
        case {'cHbO2_SmO2'}
            data.cHbO2_SmO2 = single(rawdata(ind,ii));
        case {'cH2O_SmO2'}
            data.cH2O_SmO2 = single(rawdata(ind,ii));
        case {'SDS_Speed_m/s'}
            data.SDS_speed = allocateIMU(rawdata(IMUind,ii));
        case {'SDS_Cadence_spm'}
            data.SDS_cadence = allocateIMU(rawdata(IMUind,ii));
        case {'Alert_bitflags'}
            data.Alert = logical(de2bi(rawdata(ind,ii),16));
        case {'ACC_Y'}
            data.Acc_y = allocateIMU(rawdata(IMUind,ii));
        case {'ACC_Z'}
            data.Acc_z = allocateIMU(rawdata(IMUind,ii));
        case {'GYRO_X'}
            data.Gyro_x = allocateIMU(rawdata(IMUind,ii));
        case {'GYRO_Y'}
            data.Gyro_y = allocateIMU(rawdata(IMUind,ii));
        case {'PACE_ON_DEV(m/s)'}
            data.Pace_on_dev = allocateIMU(rawdata(IMUind,ii));
    end
end

data.time = [1:numel(ind)]'./ data.samp_rate;  % time array (seconds)

% Define imu_samp_rate field only if at least one IMU data exists
if any(isfield(data, IMU_FIELDS))
    for jj = 1:length(IMU_FIELDS)
        if ~isempty(data.(IMU_FIELDS{jj}))
            if ~isfield(data, 'imu_samp_rate')
                data.imu_samp_rate = DEFAULT_IMU_SAMP_RATE;
                warning(['IMU data present but sampling rate not provided! Using default = ' num2str(DEFAULT_IMU_SAMP_RATE) 'Hz.'])
            end
            data.imu_time = [1:numel(IMUind)]'./data.imu_samp_rate;
            break
        end
    end
end

%% Function used to parse and allocate data used in IMU fields
function out = allocateIMU(data)
temp = single(data);
temp2 = temp(isfinite(temp));   % ignore NaNs and Infs
if ~isempty(temp2) && any(temp2)  % make sure field actually has at least some data before allocating memory
    out = temp;
else
    out = [];
end

