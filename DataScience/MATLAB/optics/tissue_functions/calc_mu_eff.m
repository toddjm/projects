function [ mu_eff ] = calc_mu_eff( ODDiff, dFar, dNear )
% [ mu_eff ] = calc_mu_eff( ODDiff, dFar, dNear )
%  Calculates mu_eff from a given OD difference. Assumes distances of 15mm
%  and 27mm between the near and far emitter/detector pairs, if none is given. See P. Silveira, "Optical density estimation from
%  absorption and transport scattering coefficients," BSX Athletics (2014)
%  for more details.
%
% Example:
% mu_eff = calc_mu_eff(OD27-OD15);  % where [OD15, OD27] = processCounts(sweep), for example
%
% Inputs
% ODDiff - Difference in optical densities. ODfar-ODnear.
% dFar - Far distance between emitter/detector pairs. Default = 27mm.
% dNear - Near distance between emitter/detector pairs. Default = 15mm.
%
% Outputs
% mu_eff - effective attenuation coefficient. Units are 1 / Units of Dfar and DNear. [Default = (1/mm)].
%
% See also
% calc_mu_a, calc_mu_s, processCounts, calc_SmO2
%
% P. Silveira, July 2015
% BSX Proprietary

if ~exist('dFar', 'var') || ~exist('dNear', 'var')
    a = -0.097964444; % = -2/(27-15)* ln(27/15) (1/mm)
    b =  0.191882091; % = -1 / ((27 - 15) * log10(exp(1)))
else
    deltaD = dFar-dNear;
    a = -2./(deltaD).*log(dFar./dNear);
    b = 1./(deltaD * 0.4342944819);
end

mu_eff = a + b.*ODDiff;

end




