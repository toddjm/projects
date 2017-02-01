function [AllCntDev, cinv15Dev, cinv27Dev, lookup_currentDev] = getDeviceFile( device_id )
%[AllCnt, cinv15, cinv27, lookup_current] = getDeviceFile( device_id)
% Returns calibration data of device defined by device_id. Instead of calling this function, use
% getDevice(device_id) whenever possible. getDevice calls this function, if necessary.
%
% Inputs:
% device_id - string with mac address of device of interest.
%
% Examples:
%
% [AllCnt, cinv15, cinv27] = getDevice('0CEFAF81009')
% Returns AllCnt and cinv matrices for device 0CEFAF81009.
%
% Outputs:
% AllCnt - All count matrix (transmission . counts). Convert counts into
% transmission.
% cinv15 - converts OD into oxy- and deoxyhemoglobin
% concentrations. [Mol/liter] / [OD / mm]. 15mm distance.
% cinv27 - converts OD into oxy- and deoxyhemoglobin
% concentrations. [Mol/liter] / [OD / mm]. 27mm distance.
% lookup_current - lookup table linking current codes to rows in the AllCnt
% matrix. Lookup current may be saved on device .mat file or, if absent,
% this function use the size of AllCnt matrix to guess which lookup_current
% to use: Hardware version FF if AllCnt has 25 rows, legacy device if
% AllCnt has 256 rows.
%
% See also
% getDevice, getSweep, getAllCnt


%% Initialization

global USERPATH

% Substitute the following path with that which contains device calibration files
%USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
PATHN = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\DO_NOT_MOVE\Sensor_files\'];
EXT = '.mat';   % device file extension

%% Get device(s) and parse data

if ischar(device_id),   % Not a cell. Execute only once.
    open([PATHN device_id EXT]);  % device data expected to be in .mat files
    AllCntDev = ans.AllCnt;
    cinv15Dev = ans.invC15;
    cinv27Dev = ans.invC27;
    if isfield(ans, 'lookup_current')
        lookup_currentDev = ans.lookup_current;
    else % lookup_current is not defined
        allCntLen = length(AllCntDev);
        switch allCntLen
            case(25) % assume device is 4.11
                lookup_currentDev = [0, 1, 2, 3, 4, 6, 8, 11, 14, 19, 24, 31, 39, 49, 62, 71, 81, 167, 177, 190, 199, 209,221, 236, 255 ];
            case (256) % assume device is legacy
                lookup_currentDev = [0:255];
            otherwise
                error(['Unexpected AllCnt matrix length = ' num2str(allCntLen)])
        end
    end
else    % not a single device
%     if iscell(device_id)    % if a cell array, read one device at a time
%         for ii = 1:numel(device_id),
%             open([PATHN char(device_id{ii}) EXT]);
%             tempAllCnt(ii,:,:) = ans.AllCnt;
%             tempcinv15(ii,:,:) = ans.invC15;
%             tempcinv27(ii,:,:) = ans.invC27;
%             if isfield(ans, 'lookup_current')
%                 templookup_currentDev(ii,:) = ans.lookup_current;
%             else % lookup_current is not defined
%                 allCntLen = length(tempAllCnt(ii,:,:));
%                 switch allCntLen
%                     case(25) % assume device is 4.11
%                         lookup_currentDev = [0, 1, 2, 3, 4, 6, 8, 11, 14, 19, 24, 31, 39, 49, 62, 71, 81, 167, 177, 190, 199, 209,221, 236, 255 ];
%                     case (256) % assume device is legacy
%                         lookup_currentDev = [0:255];
%                     otherwise
%                         error(['Unexpected AllCnt matrix length = ' num2str(allCntLen)])
%                 end
%             end
%             AllCntDev = tempAllCnt;
%             cinv15Dev = tempcinv15;
%             cinv27Dev = tempcinv27;
%             lookup_currentDev = templookup_current;
%         end     % for loop
%     else % unknown input format
        error('device_id must be either a string array')
%     end
end




