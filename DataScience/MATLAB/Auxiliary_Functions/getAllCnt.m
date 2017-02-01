function [ AllCnt, invC15, invC27, lookup_current, calib_diag, sweep ] = getAllCnt( device, chkout )
%function [ AllCnt, invC15, invC27, lookup_current, calib_diag, sweep ] = getAllCnt( device, chkout )
%   Returns calibration data for a given device. Treats legacy devices and
%   devices differently (uses legacy AllCnt marix). If device is in the
%   "exception" list loads calibration file instead.
%
% Inputs:
% device - a structure with device checkouts, as returned by getDevice
% function. Must be a single decice, but may include multiple checkouts.
% chkout - device checkout to use (positive integer). Default = 1 (most
% recent). If chkout = 'end', function returns very first checkout.
%
% Outputs:
% AllCnt - single-precision floating point matrix with calibration
% values in OD/counts for all 8 LEDs (15mm distance wavelength1, 15mm
% distance wavelength2, ..., 27mm distance wavelength4). Same number of rows as elemnts in lookup_current vector, usually 25x8.
% InvC15 - 2x4 matrix that converts ODs of 15mm LEDs into deoxy- and oxyhemoglobing concentrations
% loolup_current - lookup table linking current codes to rows in the AllCnt matrix
% InvC27 - 2x4 matrix that converts ODs of 27mm LEDs into deoxy- and oxyhemoglobing concentrations
% calib_diag - structure with calibration diagnostics (e.g., BiasCrossGeometry, CalibrationStatus, MuEffective, etc). Default = empty.
% sweep - current sweep output (counts)
%
% See also
% getDevice, getDeviceFile, getCurrents
%
% P. Silveira, Mar. 2015
% BSX Athletics Proprietary

%% Initialization

% LEGACY_DEVID is a global variable defined in getDevice. So, getDevice
% must always be called before getAllCnt
global LEGACY_DEVID     % defined by getDevice.m
TEMPF = 'temp.bin';   % temporary file
% List of devices for which we have separate AllCnt files (usually devices that are out of commission). Also includes legacy devices for which we have specific AllCnt tables stored.
HAVE_ALLCNT_DEVICE_EXCEPTION = {'0CEFAF810086' 'DEADBEEF0BB8' 'DEADBEEF0BB9' 'DEADBEEF0BBC' 'DEADBEEF0BBE' 'DEADBEEF0CB7' 'DEADBEEF0004' '0CEFAF8FFFE7' '0CEFAF8FFFEB' '0CEFAF8FFFED'};

if ~exist('chkout', 'var')
    chkout = 1;
end

%% Processing

calib_diag = '';    % empty = default
sweep = [];
if any(strcmpi(device.device_id , HAVE_ALLCNT_DEVICE_EXCEPTION))    % device exceptions take precedence over other exceptions
    warning(['Device ' device.device_id ' in device exception list! Using previously stored device calibration file.']);
    [AllCnt,invC15,invC27,lookup_current] = getDeviceFile(device.device_id); % use stored file instead
    return
end

if strcmp(device.id, LEGACY_DEVID)  % legacy device
    warning('Using default legacy device calibration values.');
    [AllCnt,invC15,invC27,lookup_current] = getLegacyAllCnt;
    return
end

% Some devices already have all information in their structure. That's notoriously the case for prototypes, to prevent the need of two device files per device.
% Assuming no additional checkouts for these devices.
if isfield(device, 'AllCnt')
    AllCnt = device.AllCnt;
    invC15 = device.invC15;
    invC27 = device.invC27;
    lookup_current = device.lookup_current;
    return
end

if isfield(device, 'checkouts') % be prepared to deal with legacy structure
    if isempty(device.checkouts)
        warning(['Empty checkout structure found in device ' device.device_id '. Using default calibration values!'])
        [ AllCnt, invC15, invC27, lookup_current ] = getDefaultAllCnt(device);
        return
    end
    if strcmpi(chkout, 'end'),
        calib_str = device.checkouts{end}.calibration_file;
        diag_str = device.checkouts{end}.diagnostic_file;
        current_sweep = device.checkouts{end}.current_sweep;
        if isfield(device.checkouts{end}, 'lookup_current')
            lookup_current = device.checkouts{end}.lookup_current;
        else
            lookup_current = useHW2SetLookupCurrent(device);
        end
    else
        calib_str = device.checkouts{chkout}.calibration_file;
        diag_str = device.checkouts{chkout}.diagnostic_file;
        current_sweep = device.checkouts{chkout}.current_sweep;
        if isfield(device.checkouts{chkout}, 'lookup_current')
            lookup_current = cell2mat(device.checkouts{chkout}.lookup_current);
        else
            lookup_current = useHW2SetLookupCurrent(device);
        end
    end
else
    if isfield(device, 'calibration_file')
        calib_str = device.calibration_file;    % contains AllCnt data
        diag_str = device.diagnostic_file;
        current_sweep = device.current_sweep;
        if isfield(device, 'lookup_current')
            lookup_current = device.lookup_current;
        else
            lookup_current = useHW2SetLookupCurrent(device);
        end
    else
        warning(['No checkouts found in device ' device.device_id '. Using default calibration values!'])
        [ AllCnt, invC15, invC27, lookup_current ] = getDefaultAllCnt(device);
        return
    end
end

% Getting to this point means we have a calib_diag structure that needs parsing, so let's do that next.
calib_diag = parse_json(diag_str);  % get structure with calibration diagnostics
if calib_diag.CalibrationStatus,
    warning(['Device status = ' num2str(calib_diag.CalibrationStatus) ' in ckeckout # ' num2str(chkout) ' of device ' device.device_id])
end
out = base64decode(calib_str);    % convert into decimal octets
data = typecast(out(65:end), 'single'); % convert to float, ignoring first 2 rows
AllCnt = reshape(data,8,25)';   % convert to 25x8 matrix
data = typecast(out(1:64), 'single');   % convert to float, ignoring AllCnt
InvCMat = reshape(data,8,2)';
invC15 = reshape(InvCMat(1,:),2,4);
invC27 = reshape(InvCMat(2,:),2,4);
if nargout > 5, % save time if sweep data is not required
    temp = base64decode(current_sweep, TEMPF); % save current sweep data onto TEMPF
    sweep = getSweep(TEMPF, 'false');    % convert into a sweep structure. Do not save it.
end

end

%% Function with default calibration values
function [ AllCnt, invC15, invC27, lookup_current ] = getDefaultAllCnt(device)

USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
% set AllCnt path depending on hw_version
rootPath = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Insight Calibration Files\HW' device.hw_version '\'];
AllCnt = csvread([rootPath 'Default.Allcnt.csv']);
% read invC from legacy default values
invC = csvread([USERPATH '\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\invC.csv']);
invC15 = invC(1:2,:);
invC27 = invC(3:4,:);
if isfield(device, 'lookup_current')    % try to find lookup_current info, if available
    lookup_current = device.lookup_current;
else    % otherwise, use hardware info to set default lookup_current
    lookup_current = useHW2SetLookupCurrent(device);
end

end

%% Function with legacy calibration values
function [ AllCnt, invC15, invC27, lookup_current ] = getLegacyAllCnt

USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
AllCnt = csvread([USERPATH '\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\AllCnt-8wv.csv']);
invC = csvread([USERPATH '\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\Default values\invC.csv']);
invC15 = invC(1:2,:);
invC27 = invC(3:4,:);
lookup_current = [0:255];
%         invC15 = [0.0017 -0.0003 -0.0005 0; -0.0018 0.0035 0.0046 -0.0019];
%         invC27 = invC15;

end

%% Function used to set lookup current based on hardware version
function lookup_current = useHW2SetLookupCurrent(device)

if isfield(device, 'hw_version') && ~isempty(device.hw_version)
    switch(device.hw_version)
        case{'4.11', '1.1', '255'}
            lookup_current = [0, 1, 2, 3, 4, 6, 8, 11, 14, 19, 24, 31, 39, 49, 62, 71, 81, 167, 177, 190, 199, 209,221, 236, 255 ];
        case{'4.14', '197', '192', '194', '2'}    % '4.14' corresponds to BSXInsight 2.0 Alpha exception list, some of which were later re-assigned hw_version 197 and 192. Future devices will have their own lookup_current tables saved during calibration. Hence, there should be no need to keep updating this list with their hw_version numbers.
            lookup_current = [0, 1, 128, 2, 3, 4, 5, 7, 9, 12, 15, 20, 26, 33, 142, 56, 152, 159, 93, 111, 194, 204, 217, 233, 255 ];
        otherwise
            error(['Unknown hardware version = ' device.hw_version])
    end
else    % Error. hw_version should have been set by getDevice
    error(['No lookup_current defined and cannot determine lookup_current from hardware version in device ' device.device_id])
%    lookup_current = [0, 1, 2, 3, 4, 6, 8, 11, 14, 19, 24, 31, 39, 49, 62, 71, 81, 167, 177, 190, 199, 209,221, 236, 255 ];
end

end
