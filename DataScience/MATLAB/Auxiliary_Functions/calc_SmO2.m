function [ SmO2, Resid, mu_eff, HbF, Pk, mu_s, mu_a ] = calc_SmO2( ODDiff, MU, BODY_PART  )
% function [ SmO2, Resid, mu_eff, HbF, Pk ] = calc_SmO2( ODDiff, MU, BODY_PART )
% Calculates raw SmO2 from difference in optical densitities. Does NOT include
% post-processing of SmO2 values using processSmO2.m function.
%
% Example
% assessment = getAssessment('5515958badac18db278b4d27');   % get information for assessment 5515958badac18db278b4d27
% sweep = getSweep(assessment);
% [OD15, OD27] = processCounts(sweep);
% SmO2 = calc_SmO2(OD27-OD15);
%
% Inputs
% ODDiff - difference in optical densities, probably pre-processed using processCounts.m
% MU - calculation method. 'mu_a' for absorption coefficient (Default), in
% which case BODY_PART is needed to estimated mu_s', the reduced scattering
% coefficient. 'mu_eff' for effective attenuation, in which case BODY_PART
% is not needed.
% BODY_PART - body part been monitored.
%
% Outputs
% SmO2 - calculated raw SmO2 values.
% Resid - modulus of residual of SmO2 calculation
% mu_eff - the effective attenuation factor (1/mm)
% HbF - fractional hemoglobin
% Pk - matrix containing projections of MU onto matrix of known
% chromophores. Each column of Pk corresponds to a fractional concentration
% of a chromophore. Pk(:,1) = deoxymemoglobin. Pk(:,2) = oxyhemoglobin and
% Pk(:,3) = water.
% mu_s - scattering coefficient (1/mm) of BODY_PART selected
% mu_a - absorption coefficient (1/mm) of BODY_PART selected
%
% See also
% processSmO2, processCounts, calc_mu_s, calc_mu_a
%
% P. Silveira and B. Olson, May 2015
% BSX Proprietary

%% Initializations

leds = getLeds; % get LED centroid wavelengths

% Calculate the projection vectors from pure component spectra
% [HB,HBO2] = prahlhb(leds);   % get absorption spectra
% HB = HB/10;%*log(10); %change from cm-1 to mm-1
% HBO2 = HBO2/10;%*log(10); %change from cm-1 to mm-1
% WATER = WaterHaleQuerrySpectra(leds)/10; 
% %this is the pinv of the three major components
% fMat = [HB(:) HBO2(:) WATER(:)];   % spectral components of tissue absorption
% fInv = pinv(fMat);
%
% The code above generates the following constant, which only varies if LED
% lot varies significantly such that the LED centroid needs to be updated
% fInv = [   0.003548828091533  -0.002901237881411   4.796108358867549; ...
%   -0.000457233147806   0.006593713596437 -43.118394411162001; ...
%   -0.000883269270518   0.007999912890099 -46.414747141644895; ...
%    0.000167424644740  -0.002343759681427  67.450955312463620];

fInv = [0.003548828091533  -0.000457233147806  -0.000883269270518 0.000167424644740; ...
  -0.002901237881411   0.006593713596437   0.007999912890099 -0.002343759681427; ...
   4.796108358867543 -43.118394411161979 -46.414747141644902  67.450955312463620];

fMat = 1.0e+02 * [3.053960000000000   0.308400000000000   0.000003647904593; ...
   0.771857642611746   0.811876715176715   0.000020036064497; ...
   0.691760000000000   1.050000000000000   0.000039980330966; ...
   0.752280000000000   1.219600000000000   0.000188316148812];

if ~exist('MU', 'var')
    MU = '\mu_a';
end

if ~exist('BODY_PART', 'var')
    BODY_PART = 'calf';
end

%% Calculations
mu_eff = calc_mu_eff(ODDiff); % (1/mm)
orig_state = warning;
warning('off', 'calc_mu_s:EXTRAP');   % we know we will get an extrapolation warning, so let's turn it off.
mu_s = calc_mu_s(leds, BODY_PART)/10; % if second argument is not set, calc_mu_s assumes we are monitoring a calf
warning(orig_state);    % restore warnings to original state
mu_a = calc_mu_a(mu_eff,repmat(mu_s, length(mu_eff),1)); % mu_eff.^2 ./ (3*repmat(mu_s, numel(time),1));   % absorption coefficient (1/mm)
switch MU
    case {'\mu_eff', 'mu_eff'}
        mu = mu_eff;
    case {'\mu_a', 'mu_a'}
        mu = mu_a;
    otherwise
        error(['MU must be either "mu_a" or "mu_eff". MU = ' MU])
end

Pk = mu * fInv';   % find mu projections towards fInv
pHhb = Pk(:,1);    % deoxyhemoglobin
pHbO2 = Pk(:,2);   % oxyhemoglobin
pH2O = Pk(:,3);    % water

HbF = pHbO2+pHhb; % Total Hemoglobin
SmO2 = pHbO2 ./ HbF;   % raw SmO2
Resid = mu - Pk * fMat';    % Residual calculation
%Resid = sum(Resid.^2,2);  % calculate modulus over all wavelengths
%Resid = Resid ./ numel(Resid); % normalize
Resid = Resid ./ 348.4259;  % normalize. 348.4259 = norm(fMat)

end

