function [ HbO2, Hhb ] = calc_hemes( SmO2, tHb, mode)
% function [ HbO2, Hhb ] = calc_hemes( SmO2, tHb )
% Converts SmO2 and tHb time series into hemoglobin concentrations (mmol/L).
% Uses the conversion factor 0.6206 mmol/L per 1g/dL, correct when
% translating from whole blood Hb concentration to molar concentration.
% Use the factor (10dL/64.480 mg/moles) = 0.1551 when converting MCHC (mean corpuscular hemoglobin concentration) from g/dL to mmol/L.
% See https://en.wikipedia.org/wiki/Hemoglobin and http://www.scymed.com/en/smnxpf/pfxdq210_c.htm
%
% Inputs
% SmO2 - tissue oxygenation, ranging from 0 to 100.
% tHb - total hemoglobin, in units of g/dL
% mode - conversion mode. Two options available:
%   'whole' for whole blood (uses conversion factor 0.6206. Default.
%   'MCHC' for mean corpuscular hemoglobin concentration. Uses conversion
%   factor 0.1551.
%
% Outputs
% HbO2 - oxyhemoglobin concentration (mmol/L)
% Hhb - deoxyhemoglobin concentration (mmol/L)
%
% See also
% prahlhb, Hb_mu_a
%
% P. Silveira, Jan. 2016
% BSX Proprietary

if ~exist('mode', 'var')
    mode = 'whole';
end

SmO2 = SmO2/100;    % convert from percentage to decimal values

switch mode     % convert from g/dL to mmol/L
    case 'whole'
    tHb = tHb * 0.6206;
    case 'MCHC'
        tHb = tHb * 0.1551;
    otherwise
        error(['Unexpected mode = ' mode])
end
% Calculate heme species
HbO2 = SmO2 .* tHb;
Hhb = (HbO2 .* (1-SmO2)) ./ SmO2;

% Deal with divide by zero
zeroInd = (SmO2 == 0);  % find all indices where division by zero took place
Hhb(zeroInd) = tHb(zeroInd);    % replace Hhb values with tHb (HbO2 is already set correctly to zero)

end

