function [ pH2O, Pk2, Resid2, mu_eff, mu_s, mu_a ] = calc_hydration_colip( ODDiff, MU, BODY_PART  )
% [ pH2O, Pk, Resid, mu_eff, mu_s, mu_a ] = calc_hydration2( ODDiff, MU, BODY_PART  )
% Calculates raw hydration values from difference in optical densitities. 
% Includes collagen and lipid.
%
% Example
% assessment = getAssessment('5515958badac18db278b4d27');   % get information for assessment 5515958badac18db278b4d27
% sweep = getSweep(assessment);
% [OD15, OD27] = processCounts(sweep);
% pH2O = calc_hydration2(OD27-OD15);
%
% Inputs
% ODDiff - difference in optical densities, probably pre-processed using processCounts.m
% MU - calculation method. 'mu_a' for absorption coefficient (Default), in
% which case BODY_PART is needed to estimated mu_s', the reduced scattering
% coefficient. 'mu_eff' for effective attenuation, in which case BODY_PART
% is not needed.
% BODY_PART - body part been monitored. Default = 'calf'
%
% Outputs
% pH2O - hydration coefficient calculated including collagen and lipid spectra.
% Pk - vector with calculated hemoglobin concentrations
% Resid - vector with residual of fit of input into hemoglobin space
% mu_eff - the effective attenuation factor (1/mm)
% mu_s - scattering coefficient (1/mm) of BODY_PART selected
% mu_a - absorption coefficient (1/mm) of BODY_PART selected
%
% See also
% processSmO2, processCounts, calc_mu_s, calc_mu_a, calc_SmO2
%
% P. Silveira, Jan. 2015
% BSX Proprietary

%% Initializations

leds = getLeds; % get LED centroid wavelengths

% Calculate the projection vectors from pure component spectra
% [HB,HBO2] = prahlhb(leds);   % get absorption spectra
% HB = HB/10;%*log(10); %change from cm-1 to mm-1
% HBO2 = HBO2/10;%*log(10); %change from cm-1 to mm-1
% WATER = WaterHaleQuerrySpectra(leds)/10;
% COLLAGEN = collagen_mu_a(leds,100)/10;
% LIPID = lipid_mu_a(leds,100)/10;
% COLIP = COLLAGEN+LIPID;
% %this is the pinv of the three major components
% fMat2 = [HB ; HBO2 ; WATER ; COLIP];   % spectral components of tissue absorption
% fInv2 = inv(fMat2);
%
% The code above generates the following constant, which only varies if LED
% lot varies significantly such that the LED centroid needs to be updated

fMat2 = 1.0e+02 * [  3.053960000000000   0.771857642611746   0.691760000000000   0.752280000000000
   0.308400000000000   0.811876715176715   1.050000000000000   1.219600000000000
   0.000003647904593   0.000020036064497   0.000039980330966   0.000188316148812
   0.000475461230769   0.000224545059529   0.000199106815353   0.000415231559799];

fInv2 = 1.0e+02 * [
  0.000059822536365  -0.000017147537614   0.235031682773507  -0.164607965166185
  -0.000301933997363  -0.000079049792112  -2.717164097750561   2.011489475847573
   0.000238812324572   0.000200745325966   1.439633881695444  -1.675183465614752
  -0.000019735182876  -0.000033876357911   0.509923676230127   0.144823111749000];

%WATER = [0.000364790459259   0.002003606449692   0.003998033096624   0.018831614881231];

if ~exist('MU', 'var')
    MU = '\mu_a';
end

if ~exist('BODY_PART', 'var')
    BODY_PART = 'calf';
end

%% Calculations
mu_eff = calc_mu_eff(ODDiff); % mu_eff = 0.192*ODDiff - 0.098;   (1/mm)
orig_state = warning;
warning('off', 'calc_mu_s:EXTRAP');   % we know we will get an extrapolation warning, so let's turn it off.
mu_s = calc_mu_s(leds, BODY_PART)/10; % if second argument is not set, calc_mu_s assumes we are monitoring a calf
warning(orig_state);    % restore warnings to original state
sz = size(mu_eff);  % use size instead of length so it is correct even when using short arrays (e.g., single time sample)
mu_a = calc_mu_a(mu_eff,repmat(mu_s, sz(1),1)); % mu_eff.^2 ./ (3*repmat(mu_s, numel(time),1));   % absorption coefficient (1/mm)
switch MU
    case {'\mu_eff', 'mu_eff'}
        mu = mu_eff;
    case {'\mu_a', 'mu_a'}
        mu = mu_a;
    otherwise
        error(['MU must be either "mu_a" or "mu_eff". MU = ' MU])
end

Pk2 = mu * fInv2;   % find mu projections towards fInv
Resid2 = mu - Pk2 * fMat2;    % Residual calculation. Resid = mu - mu*fInv_Hb*fMat_Hb
pH2O = Pk2(:,3);
%[pH2Oproj, pH2Ocos] = proj(Resid, WATER);

end

