function [ spectrum, wavel_max, totIrr ] = blackbody( temperature, wavel, intPower )
% function [ spectrum, wavel_max, totIrr  ] = blackbody( temperature, , wavel, intPower )
% Calculates black body radiation power spectral density (W/nm)
% Use temperature = 5778 and intPower = 1367 to simulate extra-terrestrial solar
% radiation.
%
% Inputs
% temperature - black-body temperature (Kelvin)
% wavel - wavelengths over which to calculate spectrum (nm)
% intPower - integrated power required within specified range of wavelengths (W)
%
% Outputs
% spectrum - power spectral density (W/nm)
% wavel_max - wavelength of peak irradiance (nm)
% totIrr - total irradiance emitted by blackbody at required temperature (W/m^2)
%
% BSX Proprietary

% c =  2.99700e8;    % speed of light in air (m/s)
% k = 1.38064852e-23;   % Boltzmann's constant [m^2kg/(s^2 K)] 
% h = 6.62607004e-34;   % Planck's constant (m^2kg/s)
sigma = 5.67e-8; % Stefan-Bolzmann constant [J/(m^2s.K^4)]

Const1 = 3.739464171059169e-16; % 2*pi*h*c^2;
Const2 = 0.014383336252647; % h*c/k;
wavel = wavel*1e-9; % convert from nm to meters
%nu = c./(wavel*1e-9);
%spectrum = Const1*(nu).^3./(exp(Const2.*nu./temperature) - 1);
%spectrum = (2*h/c^2)*nu.^3./(exp(h.*nu./(k.*temperature)) - 1);
spectrum = Const1./((wavel.^5).*(exp(Const2./(wavel.*temperature))-1));
spPower = trapz(wavel*1e9, spectrum);
spectrum = spectrum .* (intPower./spPower);  % normalize to required total power (W)

wavel_max = 2.8977729e6./temperature;
totIrr = sigma.*temperature.^4;   
 

end

