function [ device ] = getDevice( mac_address )
%[ device ] = getDevice( mac_address )
% Returns device calibration records from the server. If device is found, field 'hw_version' is
% guaranteed to be filled in. If device is identified as a "legacy" device
% (i.e., mac_address starting with 'DEADBEEF') hw_version is left blank and
% id is set to 'Legacy'.
%
% Inputs:
% mac_address - string with mac address of device of interest
%
% Examples:
%
% getDevice('0CEFAF810047')
% Returns record from device with mac_address 0CEFAF810047
%
% Outputs:
% device - structure (or array of structures) containing all device
% information on the server, with fields
%    id - device id
%    device_id - device MAC address (and unique ID)
%    hw_version - hardware version (e.g., '4.11'). If none is found in the
%    server, uses default value '4.11'.
%    meta.firmware - firmware version
%    meta.model_number - string with model number (e.g., 'XM100BLK')
%    meta.type - string with model type (e.g., 'IXM' for multi-sport)
%    checkouts - array with information on each device calibration
%    checkout, in which checkout{1} is the most recent.
%    checkout{1}.alpha_id - assessment id of the current sweep used in calibration
%    checkout{1}.block - calibration block used
%    checkout{1}.calibration_file - AllCnt matrix and cinv (see
%    getAllCnt.m for more details).
%    checkout{1}.calibration_sweep - numeric data, in base64 format,
%    captured during calibration sweep
%    checkout{1}.diagnostic_file - JSON record with calibration diagnostics
%    checkout{1}.firmware - firmware uploaded during calibration
%    checkout{1}.operator_id - id of operator responsible for calibration
%    checkout{1}.station - id of calibration station used
%    checkout{1}.status - integer. 0 means success.
%    checkout{1}.led_lot - LED lot number. Used to determine cinv matrix to
%    use with that LED
%    checkout{1}.updated_at - last upated of checkout. Currently it is
%    always = created_at
%    checkout{1}.created_at - checkout record creation data
%    checkout{1}.lookup_current - vector with conversion table, converting
%    from current codes to rows in AllCnt matrix
%
%
% See also
% getAllCnt, devAnalysis, getSweep, getDeviceChks, getCurrents
%
% P. Silveira, Feb. 2015
% BSX Athletics Proprietary

%% Initializations

global LEGACY_DEVID HW_DEFAULT USERPATH     % legacy device ID and hardware version. Declare as global so it can be used by getAllCnt and getCurrents

LEGACY_DEVID = 'Legacy';    % legacy device id
HW_DEFAULT = '255';    % default hardware version (before current increase)
LEGACY_MAC = 'DEADBEEF';    % legacy device id prefix
% List of known legacy devices that do not follow LEGACY_MAC prefix. These devices are not found in the server and should be listed here to prevent error.
EXCEPTION_LEGACY = {'0CEFAF8FFFED' '0CEFAF8FFFE7' '0CEFAF8FFFEB' '0CEFAF8FFFFC' '0CEFAF8FFFE7' '0CEFAF8FFFEB' '0CEFAF8FFFED'}; 
%PROTOTYPE_HW_VERSION = '2'; % device hardware version to be used with prototypes. Currently Nellie and Calypso use the same lookup currents as version 2.

% Non-conclusive list of devices that have been deactivated and are no longer available in the server. Calibration info available on .mat files instead
EXCEPTION_DEACTIVATED = {'0CEFAF81051C' '0CEFAF8107FA' '0CEFAF810203' '0CEFAF81026F' '0CEFAF810111' '0CEFAF810160'};
DEACTIVATED_PATH = '\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\DO_NOT_MOVE\Sensor_files\'; % path were .mat files of deactivated devices is available.
% List of prototype device prefixes that are stored in the PROTOTYPE_PATH instead of being stored in the database
PROTOTYPE_PREFIX_LIST = {'99'}; %{'01FFFFFF2001' '20FFFFFF3006' };
PROTOTYPE_PATH = '\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\DO_NOT_MOVE\Sensor_files\Nellie_and_Calypso\'; % path were .mat files of deactivated devices is available.

Base_URL = 'https://api.bsxinsight.com';
Devices_URL = [Base_URL '/devices'];
% List of devices that are known to be hw_version = '4.14' but which are not listed as such in the server
% EXCEPTION_414 = {};%{'0CEFAF810984' '0CEFAF81097D' '0CEFAF810970' '0CEFAF81097A' '0CEFAF810976' '0CEFAF81096B' '0CEFAF810986' '0CEFAF810972' '0CEFAF810975' '0CEFAF81097C' '0CEFAF81097F' '0CEFAF810978' '0CEFAF810981' '0CEFAF810982' '0CEFAF810983'}; 
% EXCEPTION_HW = '4.14';

if ~ischar(mac_address)
    error('mac_address must be a string')
end

if ~exist('USERPATH', 'var')
    USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
end

%% Get device(s) and parse json strings

if strcmpi(mac_address(1:8), LEGACY_MAC) || any(strcmpi(mac_address, EXCEPTION_LEGACY))   % legacy devices are not in the server
    warning(['Legacy device detected = ' mac_address '. Using default legacy info.'])
    device.device_id = mac_address;
    device.id = LEGACY_DEVID;
elseif any(strcmpi(mac_address, EXCEPTION_DEACTIVATED))     % deactivated devices have been removed from the server
    load([USERPATH DEACTIVATED_PATH mac_address '.mat']);
elseif any(strcmpi(mac_address(1:2), PROTOTYPE_PREFIX_LIST))  %any(strcmpi(mac_address, PROTOTYPE_LIST))    % prototypes are also not in the server
%    device.hw_version = PROTOTYPE_HW_VERSION;
    load([USERPATH PROTOTYPE_PATH mac_address '.mat']);
else % legacy or deactivated devices would have caused an error in the following makeRequestUrlRead2 call
    str = makeRequestUrlRead2([Devices_URL '/' mac_address], 'GET', '');  % query an individual device
    device = parse_json(str);
end

% if any(strcmpi(mac_address, EXCEPTION_414))  % check if device belongs to exception list
%     device.hw_version = EXCEPTION_HW;
% end

if ~isfield(device, 'hw_version')   % set default hw_version, if none found
    device.hw_version = HW_DEFAULT;
end

if isempty(device.hw_version)   % set default hw_version, if empty
    warning(['Empty hw_version in device ' device.device_id '. Hardware version ' HW_DEFAULT ' assumed.'])
    device.hw_version = HW_DEFAULT;
end

if ~isfield(device, 'wavel')  % set default wavelengths and geometry
    [device.centWavel, device.wavel] = getLeds;
    device.centWavel = [device.centWavel device.centWavel];
    device.wavel = [device.wavel device.wavel];
    device.geometry = [15 15 15 15 27 27 27 27];
end

