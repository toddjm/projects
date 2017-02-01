function [ mu_a ] = melanosome_mu_a( wavelengths, fv )
% function [ mu_a ] = melanosome_mu_a( wavelengths, fv )
%  Estimates the reduced absorption coefficient (mu_a) of melanossomes at designated
%  wavelengths, in 1/cm. Uses formula from
%  http://omlc.org/spectra/melanin/jacques.mcauliffe.gif, which uses a
%  numeric approximation based on spectral measurements of human skin,
%  in vivo.
% 
% From http://omlc.org/spectra/melanin/
% How are melanosomes distributed? The volume fraction of melanosomes in a particular epithelial layer, such as the cutaneous epidermis or the RPE, can vary. The average epidermal absorption coefficient depends on both the melanosomal µa and the volume fraction (fv) of melansomes in the epidermis. In skin, the volume fraction of melanosomes is estimated to vary as [Jacques 1996]:
% for light skinned caucasions, fv = 1-3%
% for well-tanned caucasions and Mediterraneans, fv = 11-16%
% for darkly pigmented Africans, fv = 18-43%.
%
% Inputs
% wavelengths - vector (or array) with wavelengths of interest (nm)
% fv - volume fraction of melanosomes. Default = 100%.
%
% Outputs
% mu_a - absorption coefficient (1/cm). Has same dimensions as
% wavelengths input vector (or array).
%
% Notes
% See http://omlc.org/spectra/melanin/extcoeff.html for numeric data used
% for estimation of extinction coefficients.
%
% See also
% prahlhb, collagenSpectrum, H2O_mu_a
%
% P. Silveira, June 2015
% BSX Proprietary

DEFAULT_FV = 100;

if ~exist('fv','var')
    fv = DEFAULT_FV;
end

if max(wavelengths(:)>800) | min(wavelengths(:)) < 400;
    warning('melanosome_mu_a:EXTRAP','mu_a calculation based on experimental data in the range from 400nm to 800nm. Extrapolations are probably safe up to the range 300nm to 1100nm. Extrapolating.')
end

mu_a = (fv/DEFAULT_FV).*1.7e12.*wavelengths.^(-3.48); % in skin. µa = 6.49x1012 nm-3.48 [cm-1] for retina

end

