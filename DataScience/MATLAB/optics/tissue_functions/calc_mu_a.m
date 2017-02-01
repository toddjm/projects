function [ mu_a ] = calc_mu_a( mu_eff, mu_s )
% function [ mu_a ] = calc_mu_a( mu_eff, mu_s )
%  Estimates the absorption coefficient from the effective absorption
%  coefficient (mu_eff) and from the reduced scattering coefficient (mu_s).
%  mu_eff and mu_s may be vectors or arrays of the same dimensions and length.
% Uses quadratic solution to diffusion theory's expression for mu_eff = sqrt(3*mu_a*(mu_a+mu_s))
% See, for example, T. Farrell, M. Patterson, and B. Wilson, “A diffusion theory model of spatially resolved, steady-state diffuse reflectance for the noninvasive determination of tissue optical properties invivo”	Medical Physics, pp. 879–888, 1992.
%
% Inputs
% mu_eff - effective absorption coefficient. Usually a vector or array with mu_eff at
% multiple wavelengths and time samples.
% mu_s - reduced scattering coefficient. Usually a vector or array with mu_s at
% multiple wavelengths and time samples. Must have same units as mu_eff.
%
% Outputs
% mu_a - absorption coefficient. Has same dimensions as mu_eff and
% mu_s.
%
% P. Silveira, Apr. 2015
% BSX Proprietary

delta = mu_s.^2 + 4/3*(mu_eff.^2);
if any(delta<0)
    warning('Complex values calculated for mu_a. Check mu_s and mu_eff!')
end

mu_a = 0.5*(sqrt(delta) - mu_s);

end

