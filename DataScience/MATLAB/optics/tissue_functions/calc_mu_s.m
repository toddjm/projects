function [ mu_s ] = calc_mu_s( wavelengths, body_part )
% function [ mu_s ] = calc_mu_s( wavelengths, body_part )
%  Estimates the reduced scattering coefficient at designated
%  wavelengths, in units of 1/cm. In the range from 650nm to 950nm it uses formulas from S. J. Matcher, M. Cope, and D. T. Delpy, "In vivo measurements of the
% wavelength dependence of tissue-scattering coefficients between 760 and 900 nm measured with time-resolved spectroscopy," Appl. Opt. 36, 386-396 (1997) 
% Outside this range it uses scattering formula from Wilson et al "Review of short-wave infrared spectroscopy and imaging methods for biological tissue characterization," J. biomed. Opt. 20(3) (2015) 
%
% Inputs
% wavelengths - vector (or array) with wavelengths of interest (nm)
% body_part - string defining body part. Options are 'calf', 'head' and
% 'forearm'. Default = 'calf'
%
% Outputs
% mu_s - reduced scattering coefficient (1/cm). Matrix has same dimensions as
% wavelengths input vector (or array).
%
% B. Olson, April 2015. Modified by P. Silveira
% BSX Proprietary


if ~exist('body_part', 'var')
    body_part = 'calf';
end

if max(wavelengths(:)>950) | min(wavelengths(:)) < 650;     % far from Matcher's range. Use Wilson's formula instead.
    warning('calc_mu_s:EXTRAP','Matcher''s mu_s calculation based on experimental data in the range from 760nm to 900nm. Using Wilson''s approximation instead.')
    mu_s = 1.1e11.*wavelengths.^(-4) + 7.37.*wavelengths.^(-0.22); % (1/mm)
    return
end

if max(wavelengths(:)>900) | min(wavelengths(:)) < 760; % close to Matcher's range. Issue warning and extrapolate.
    warning('calc_mu_s:EXTRAP','Matcher''s mu_s calculation based on experimental data in the range from 760nm to 900nm. Extrapolating.')
end
switch body_part
    case 'calf'
        a = -8.9e-4;
        b = 1.63;
    case 'forearm'
        a = -5.1e-4;
        b = 1.1;
    case 'head'
        a = -6.5e-4;
        b = 1.45;
    otherwise
        error(['Invalid body part selected = ' body_part])
end

mu_s = a.*wavelengths+b;
mu_s = mu_s*10; % convert from 1/mm to 1/cm


end

