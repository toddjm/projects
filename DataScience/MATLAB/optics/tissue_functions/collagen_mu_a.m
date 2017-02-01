function [ mu_a ] = collagen_mu_a( wavel, vol_pc )
% [ mu_a ] = collagen_mu_a( wavel, vol_pc )
% Provides absorption coefficient of collagen.
% Reference [1]: Taroni et al, "Diffuse optical spectroscopy of breast tissue
% extended to 1100nm," J. of Biomedical Optics, vol. 14, no. 5 (2009)
%
% Inputs
% wavel - desired wavelengths (nm)
% vol_pc - volume percentage concentration of collage. Default = 14%, as
% used in reference [1] according to Refence [2]: Tseng et al, "Noninvasive
% evaluation of collagen and hemoglobin contents and scattering property of
% in vivo keloid scars and normal skin using diffuse refelectance
% spectroscopy: pilot study," J. of Biomedical Optics, vol. 17, no. 7
%
% Outputs
% mu_a - absorption coefficients (1/cm)
%
% P. Silveira, Jan. 2016
% BSX Proprietary

% Values read from plot shown on Figure 3 of reference.

DEFAULT_VOLPC = 14.0;    % default volume percent concentration of collagen (= 0.196g/cm3)

if ~exist('vol_pc', 'var')
    vol_pc = DEFAULT_VOLPC;  
end

K = vol_pc / DEFAULT_VOLPC;    % 

data = [
    .092 600
    .088 610
    .075    630
    .068    660
    .056    680
    .044    720
    .031    800
    .027    855
    .028    865
    .034    890
    .045    910
    .039    935
    .033    950
    .048    990
    .065    1010
    .066    1025
    .062    1035
    .044    1065
    .027    1100];

wavel_nom = data(:,2);
mu_a_nom = K*data(:,1);

if any(wavel > max(wavel_nom)) || any(wavel < min(wavel_nom))
    warning(['Wavelength out of bounds of available numeric data. Minimum numeric wavelength = ' num2str(min(wavel_nom)) 'nm. Max numeric wavelength = ' num2str(max(wavel_nom)) 'nm. Extrapolating.'])
    method = 'linear';  % linear method extrapolates better
else
    method = 'pchip';   % interpolates better
end

mu_a = interp1(wavel_nom, mu_a_nom, wavel, method, 'extrap');

end

