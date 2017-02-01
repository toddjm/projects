function mu_a = cyt_c_mu_a(wavelength, conc, vol_pc)
% function mu_a = cyt_c_mu_a(wavelength, conc, vol_pc)
% Calculates absorption coefficient of cytochrome c at wavelength specified by 
% vector wavelengths, at concentrations conc (g/ml) and percentage volumes
% vol_pc.
% Uses average of oxidized and reduced cytochrome c spectra (assumes 50/50
% distribution).
%
% Inputs
% wavelength - vector with wavelengths of interest (nm)
%
% conc - concentration of cytochrome oxydase in tissue (ug/g = micro-gram per gram of dry tissue). Typical
% values are 72 (skeletal muscle), 138 (liver), 245 (kidney), 346 (heart), 50 (brain) and 21 (lung). The first 4 values are from H. A. Salmon, "The cytochrome c content of the heart kidney, liver and skeletal muscle of iron-deficient rats," J. Physiol., vol. 164, pp. 17-30 (1962).
% The last value is from V. R. Potter and K. P. DuBois, "The Quantitative determination of cytochrome c*," J. Biol. Chem., vol. 142, pp. 417-426 (1942).
%
% vol_pc - volume percentage of given tissue (e.g., % of muscle tissue in
% total tissue). Default = 100%.
%
% Outputs
% mu_a - absorption coefficient (1/cm)
% 
% See also
% Hb_mu_a, H2O_mu_a, melanosome_mu_a, collagen_mu_a
%
% P. Silveira, Jan. 2015
% BSX Proprietary

DEFAULT_conc = 72;      % default cytochrome c concentration (ug/g)
DEFAULT_VOLPC = 100.0;    % default volume percentage

if ~exist('vol_pc', 'var')
    vol_pc = DEFAULT_VOLPC;
end

if ~exist('conc', 'var')
    warning(['Cytochrome c concentration not defined. Using default = ' num2str(DEFAULT_conc) 'ug/g.'])
    conc = DEFAULT_conc;
end

[e_cyt, e_cyt_oxid, e_cyt_red] = cyt_c_ext(wavelength);  % get molar extinction coefficients (L / cm . mole)
K = 1.882273434966113e-07 * vol_pc / DEFAULT_VOLPC;  % converconversion factor = log(10)*1e-3/12233 to convert from extinction to absorption and from ug/g to mmol/L.
mu_a = K * e_cyt * conc;





