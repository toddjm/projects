% Script used to estimate ADC counts from differnt sensor geometries.
%
% P. Silveira, Feb. 2016
% BSX Proprietary

%% Initialization

%clear
%close all

% LED properties

% Current 665nm, 27mm LED
P = 40;  % LED optical power (mW)
rho = 27;   % PD/LED separation (mm)
WL = 665;   % wavelenght (nm)
AREA = 5^2;  % PD area

% % New 665nm, 23.58mm
% P = 40;  % LED optical power (mW)
% rho = 23.58;   % PD/LED separation (mm)
% WL = 665;   % wavelenght (nm)
% AREA = 2.77^2;  % PD area

% % New 570nm, far
% P = .3*5;       % LED optical power (mW)
% rho = 6.6;      % PD/LED separation (mm)
% WL = 570;       % wavelenght (nm)
% AREA = 2.77^2;  % PD area
% 
% % New 500nm, far
% P = 1*5;  % LED optical power (mW)
% rho = 5.63;   % PD/LED separation (mm)
% WL = 500;   % wavelenght (nm)
% AREA = 2.77^2;  % PD area

% Tissue properties
PC.WATER = 72;  % water fractional volume. 72% typical for Skin 72%, 83% for Blood 83%, 76% muscle and 10% adipose tissue.
PC.BLOOD = 1;  % Blood volume. 1% - vasoconstriction, 15% vasodilation. 5% typical
PC.COLLAGEN = 12;
PC.LIPID = 6;
PC.MELANIN = 11;    % In epidermis. 11% = tanned caucasian
PC.OTHER = 100;
CHROMOPHORES = fields(PC);
%WL_START = 350; % 600
%WL_END = 1075;
WL_POINTS = 1001;
SmO2 = 65;  % %
tHb = 15;   % g/dL
d_skin = 60e-6; % epidermis thickness (m)
d_total = 1.5*rho*1e-3;  % total path length (m)
PC.MELANIN = PC.MELANIN * 2*d_skin / d_total;   % adjust melanin fraction using fraction of epidermis wrt total path length
for ii = 1:numel(CHROMOPHORES)-1
    PC.OTHER = PC.OTHER - PC.(CHROMOPHORES{ii});
end
%[wl_cent, wl_nom] = getLeds;    % centroid and nominal LED wavelengths
LED_LINE = 1.;   % linewidth used to plot LED spectra
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
ledPath = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Insight2.0\HW_Optics\IncreasedCurrents\V&V\SpectrophotometerTest\Post-modification'];   % path with LED spectra

Resp = PD_resp(WL);     % photodiode responsivity. Use InGaAs_Resp for InGaAs PD, PD_resp for Si

% Absorption spectra
mu_a.water = H2O_mu_a(WL, PC.WATER);
[mu_a.Hhb, mu_a.HbO2] = Hb_mu_a(WL, tHb, SmO2, PC.BLOOD);
mu_a.collagen = collagen_mu_a(WL, PC.COLLAGEN);
mu_a.lipid = lipid_mu_a(WL, PC.LIPID);
mu_a.melanin = melanosome_mu_a(WL, PC.MELANIN);
%mu_a.cytochrome = cyt_c_mu_a(WL, CYT_CONC);
%mu_a.other = zeros(size(WL)); % assume no relevant contribution to optical absoprtion from remaining constituents
mu_a.total = zeros(size(WL));
fl = fields(mu_a);
for ii = 1:numel(fl)-1
    mu_a.total = mu_a.total + mu_a.(fl{ii});
end

n = skinIndex(WL);  % index of refraction of skin
mu_s = calc_mu_s(WL);   % scattering coefficient

R = getRr2(mu_a.total/10, mu_s/10, rho, n);
photocurrent = (P*1e-3)*R*Resp*AREA;

%% Output

figure
pie([PC.WATER PC.BLOOD PC.COLLAGEN PC.LIPID PC.MELANIN PC.OTHER], CHROMOPHORES)
title('Tissue constitution volume distribution')

fprintf('Wavelength = %dnm \tDistance = %f mm\tArea = %fmm^2\n', WL, rho, AREA)
fprintf('Photocurrent = %f nA\n', photocurrent/1e-9);

