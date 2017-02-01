function [ MAXALLCNT_MIN, MAXALLCNT_MAX, MuEffNom, MuError, MuEffTol, RMSErrorMAX ] = calibPassFail( hw_version )
%function [ MAXALLCNT_MIN, MAXALLCNT_MAX, MuEffNom, MuError, MuEffTol, RMSErrorMAX ] = calibPassFail( hw_version )
%
% Reads Pass/Fail criteria from Calibration files. Files are located at
% \Google Drive\Tech_RD\Sensor\Development\Release to Market
% Product\Insight Calibration Files\HWXX, where XX denotes the hardware
% version (e.g., '255').
%
% Example:
% device = getDevice('0CEFAF810047');
% [ MAXALLCNT_MIN, MAXALLCNT_MAX ] = calibPassFail( device.hw_version )
% 
% Inputs:
% hw_version - string containing hardware version. Default = '255'
%
% Outputs:
% MAXALLCNT_MIN - Vector with minimum MaxAllCnt values used in pass/fail
% test. One vector element per LED.
% MAXALLCNT_MAX - Vector with maximum MaxAllCnt values used in pass/fail
% test. One vector element per LED.
% MuEffNom - vector nominal values of effetive absorption coefficients. One
% vector element per wavelength.
% MuEffTol - % tolerance error in MuEff.
% MuError - vector with maximum accepted deviations used in pass/fail test.
% Test fails is measured MuEff > MuEffNom+MuError or if MuEff < MuEffNom-MuError for any wavelength.
% MuError = MuEffNom*MuEffTol.
% RMSErrorMax - maximum acceptable RMS Error. Test fail if any RMS Error >
% RMSErrorMax. Used to detect excessive noise in measurements.
%
% See also
% getDevice, getAllCnt, processCounts
%
% P. Silveira, Feb. 2015
% BSX Proprietary

%% Initializatons

global HW_DEFAULT   % defined by getDevice

USERPATH = getenv('USERPROFILE');
INOMODEL_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Insight Calibration Files\inoBlockModel.json'];

if ~exist('hw_version', 'var')
    hw_version = HW_DEFAULT;    % set default hardware version
end
PASSFAIL_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Insight Calibration Files\HW' hw_version '\CalibrationPassCriteriaModel.json'];

%% File input
h = fopen(PASSFAIL_PATH);   % open jason file with pass/fail criteria
if h == -1
    error(['Could not open file ' PASSFAIL_PATH])
end
str = fread(h,'*char');     % read file contents
fclose(h);
temp = parse_json(str');    % parse json data
MAXALLCNT_MIN = cell2mat(temp.FullPwrAllCntMinThreshold);
MAXALLCNT_MAX = cell2mat(temp.FullPwrAllCntMaxThreshold);
MuEffTol = temp.MuEffectiveTestMargin;   % mu_eff tolerance (%)
RMSErrorMAX = temp.CrossGeometryRMSErrorThreshold; % get maximum acceptable RMS Error

h = fopen(INOMODEL_PATH);   % open jason file with INO model data
str = fread(h,'*char');     % read file contents
fclose(h);
temp = parse_json(str');    % parse json data
MuEffNom = cell2mat(temp.MuEff);   % mu_eff tolerance (%)
MuError = MuEffNom * MuEffTol;  % calculate mu_eff maximum acceptable error

end

