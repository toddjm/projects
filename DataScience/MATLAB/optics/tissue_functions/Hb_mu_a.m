function [mu_a_Hhb, mu_a_HbO2, mu_a_tHb] = Hb_mu_a(nm, tHb, SmO2, vol_pc)
% function [mu_a_Hhb, mu_a_HbO2, mu_a_tHb] = Hb_mu_a(nm, tHb, SmO2, vol_pc)
% Calculates absorption coefficient of hemoglobin at wavelengths nm and
% concentration tHb.
%
% Inputs
% nm - vector with wavelengths of interest (nm)
% tHb - hemoglobin concentration (g/dL = gram per deciliter). A typical
% value is 15d/dL (default). Normal ranges are 11 to 18g/dL for healthy adults.
% SmO2 - oxygen saturation. Default = 50% (equal parts of oxy- and
% deoxyhemoglobin). May be a vector, in which case the output is a matrix
% with the same number of elements as SmO2 (1st dim.) x number of elements
% of nm (2nd dim.)
% vol_pc - volume percentage of blood in tissue. Default = 100%. Use a lower value to
% represent blood in tissue. A typical values 5% (normal), 1% (vasoconstricted) and 15% (vasodilated), according to P. Mannheimer, The Physio-optics of pulse oximetry: numerical modeling and clinical experience, PhD Thesis, U. of Lubeck (2004) 
%
% Outputs
% mu_a_Hhb - absorption coefficient (1/cm) of deoxyhemoglobin
% mu_a_HbO2 - absorption coefficient (1/cm) of oxyhemoglobin
% mu_a_tHb - total absorption coefficient (1/cm) of hemoglobin
% 
% See also
% prahlhb, H2O_mu_a, melanosome_mu_a, collagen_mu_a
%
% P. Silveira, Jan. 2015
% BSX Proprietary

DEFAULT_tHb = 15;      % default hemoglobin concentration (g/dL)
DEFAULT_VOLPC = 100.0;    % default volume percentage

if ~exist('vol_pc', 'var')
    vol_pc = DEFAULT_VOLPC;
end

if ~exist('tHb', 'var')
    warning(['Hemoglobin concentration not defined. Using default = ' num2str(DEFAULT_tHb) 'g/dL.'])
    tHb = DEFAULT_tHb;
end

if ~exist('SmO2', 'var')
    SmO2 = 50;
end

[e_Hhb, e_HbO2] = prahlhb(nm);  % get molar extinction coefficients (L / cm . mole)

%K = 3.57223e-4 * vol_pc / DEFAULT_VOLPC; % (conversion factor from extinction to absorption (ln(10) and from g/dL to moles of Hb / liter = (1g/dL)*10dL/L / 64480(g/moles) ;

%mu_a_Hhb = e_Hhb * K .* tHb;
%mu_a_HbO2 = e_HbO2 * K .* tHb;

K2 = 0.0023026 * vol_pc / DEFAULT_VOLPC; % conversion factor = log(10) / 1000 to convert from extinction to absorption and from mmol/L to mol/L

[HbO2_conc, Hhb_conc] = calc_hemes(SmO2, tHb, 'MCHC');
mu_a_Hhb = Hhb_conc(:) * e_Hhb .* K2;
mu_a_HbO2 = HbO2_conc(:) * e_HbO2 .* K2;
mu_a_tHb = mu_a_Hhb + mu_a_HbO2;



