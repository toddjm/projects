function [ mu_a ] = lipid_mu_a( wavel, vol_pc )
% [ mu_a ] = lipid_mu_a( wavel, vol_pc )
% Provides absorption coefficient of lipid.
% Reference [1]: Taroni et al, "Diffuse optical spectroscopy of breast tissue
% extended to 1100nm," J. of Biomedical Optics, vol. 14, no. 5 (2009)
%
% Inputs
% wavel - desired wavelengths (nm)
% vol_pc - volume percentage concentration of collage. Default = 100%.
%
% Outputs
% mu_a - absorption coefficients (1/cm)
%
% P. Silveira, Jan. 2016
% BSX Proprietary

% Values read from plot shown on Figure 4 of reference.

DEFAULT_VOLPC = 100.0;    % default volume percent concentration of lipid

if ~exist('vol_pc', 'var')
    vol_pc = DEFAULT_VOLPC;  
end

K = vol_pc / DEFAULT_VOLPC;    % 

data = [.006    600
    .005    615
    .005    655
    .003    665
    .002    715
    .006    740
    .013    755
    .005    772
    .001    785
    .006    825
    .005    850
    .006    860
    .012    875
    .055    898
    .135    930
    .074    940
    .027    958
    .012    968
    .012    985
    .036    1010
    .065    1040
    .046    1055
    .025    1095
    .0255    1100
];

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

