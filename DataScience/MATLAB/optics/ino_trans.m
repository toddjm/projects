function [ transmissions, ino ] = ino_trans( wavel, inoBlock )
% function [ transmissions, ino ] = ODs( wavel, inoBlock )
%
% Uses interpolation (and extrpolation) to provide transmission (and other block parameters) at
% wavelengths of interest.
%
% Inputs
% wavel - vector of wavelengths of interest (nm)
% inoBlock - string defining INO block being used. Default = 'PB432'
%
% Outputs
% transmission - transmission at 15mm and at 27mm distances, rasterized in
% a vector
% ino.T15 - transmission at 15mm distance
% ino.T27 - transmission at 27mm distance
% ino.OD15 - optical density at 15mm distance
% ino.OD27 - optical density at 27mm distance
% ino.mu_eff - effective absorption parameter (1/cm)
% ino.mu_a - absorption parameter (1/cm)
% ino.mu_s - scattering parameter (1/cm)
%
% P. Silveira, March 2015

METHOD = 'pchip';   % interpolation METHOD
USERPATH = getenv('USERPROFILE');
FILEPATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\INO\PB432_Calibration_pars_and_calc.xlsx'];

if ~exist('inoBlock', 'var') % set default value
    inoBlock = 'PB432';
end

switch inoBlock
    case 'PB432'
        temp = xlsread(FILEPATH, 'B4:J7');
    otherwise
        error(['Unidentified INO block: ' inoBlock])
end

% Parse data
wavel_nom = temp(:,1);
mu_a_nom = temp(:,2);
mu_eff_nom = temp(:,4);
mu_s_nom = temp(:,3);
OD15_nom = temp(:,8);
OD27_nom = temp(:,9);

% Interpolate to desired wavelengths
ino.OD15 = interp1(wavel_nom, OD15_nom, wavel, METHOD, 'extrap');
ino.OD27 = interp1(wavel_nom, OD27_nom, wavel, METHOD, 'extrap');
ino.mu_eff = interp1(wavel_nom, mu_eff_nom, wavel, METHOD, 'extrap');
ino.mu_a = interp1(wavel_nom, mu_a_nom, wavel, METHOD, 'extrap');
ino.mu_s = interp1(wavel_nom, mu_s_nom, wavel, METHOD, 'extrap');
ino.T15 = 10.^(-ino.OD15);
ino.T27 = 10.^(-ino.OD27);
transmissions = [ino.T15(:); ino.T27(:)];

end

