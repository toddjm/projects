function [ M, phi, mu_eff ] = mod_phase( r, mu_sp, mu_a, f, n)
% function [ M, phi, mu_eff ] = mod_phase( r, mu_eff, mu_a, f, n)
% Calculates modulation loss (M) and phase delay (phi) undergone by a
% signals modulated at frequency f (Hz) after propagation through r milimeters of tissue
% of index of refraction n with reduced scattering coefficient mu_sp (1/mm) and
% absorption coefficient mu_a (1/mm).
%
% Inputs
% r - propagation distance. Usually distance between light source and
% photodetector (mm).
% mu_sp - reduced scattering coefficient of tissue (1/mm). 
% mu_a - absoprtion coefficient of tissue (1/mm).
% n - index of refraction of tissue. Default = 1.3776 (skin index at 700nm).
%
% Outputs
% M - loss of modulation index (1 = no loss)
% phi - phase delay (radians)
% mu_eff - effective attenuation (1/mm)
%
% See also
% getRr2, skinIndex, Hb_mu_a, calc_mu_eff

if ~exist('n', 'var')
    n = 1.3776; % default value. Skin index @ 700nm
end

% Constants
c0 = 2.9989e11; % speed of light in vacuum (mm/s)

c = c0 ./ n;
z0 = 1./mu_sp;
rho = sqrt(r.^2 + z0.^2);
mu_eff = sqrt(3*mu_a*(mu_a+mu_sp));
chi = 2*pi*f./(mu_a*c);
psi_inf = mu_eff.*rho;
psi_zero = mu_eff.*rho.*(1+chi.^2).^0.25;
theta = atan(chi);
psi_i = psi_zero.*cos(theta/2);
psi_r = -psi_zero.*sin(theta/2);

M = sqrt(1+psi_zero.^2 + 2*psi_i) ./ (1 + psi_inf) .* exp(psi_inf - psi_i);
phi = psi_r - atan(psi_r ./ (1+psi_i));

end

