function n = skinIndex( wavelengths )
% function n = skinIndex( wavelengths )
%  Estimates the index of refraction (real part) of human skin at specified
%  wavelengths.
% Uses Cauchy approximation and fitting coefficients from Ding et al,
% "Refractive indices of human skin tissues at eight wavelenghts and
% estimated dispersion relations between 300 and 1600nm," Phys. Med. Biol.
% vol. 51, pp. 1479-1489 (2006)
%
% Inputs
% wavelengths - vector (or array) with wavelengths of interest (nm)
%
% Outputs
% n - vector (or array) with indices of refraction (unitless).
%
% P. Silveira, Jan. 2016
% BSX Proprietary

if max(wavelengths(:)>1600) | min(wavelengths(:)) < 300;
    warning('skinIndex:EXTRAP','Outside original approximation ranage from 300nm to 1600nm! Extrapolating.')
end

A = 1.3696;
B = 3.9168e3;
C = 2.5588e3;

% Cauchy's dispersion relation (Cornu and Conrady also available).
n = A + B ./(wavelengths.^2) + C ./ (wavelengths.^4);



