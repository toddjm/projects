% Script used to demonstrate relative contribution of different
% chromophores to total optical absorption in different tissues
%
% P. Silveira, Jan. 2016
% BSX Proprietary

%% Initialization

clear
close all

PC.WATER = 68;  % water fractional volume. 72% typical for Skin 72%, 83% for Blood 83%, 76% muscle and 10% adipose tissue.
PC.BLOOD = 1;  % Blood volume. 1% - vasoconstriction, 15% vasodilation. 5% typical
PC.COLLAGEN = 8;
PC.LIPID = 8;
PC.MELANIN = 11;    % In epidermis. 11% = tanned caucasian
PC.OTHER = 100;
CHROMOPHORES = fields(PC);
WL_START = 350; % 600
WL_END = 1075;
WL_POINTS = 1001;
SmO2 = 60;  % %
tHb = 15;   % g/dL
CYT_CONC = 72; % cytochrome c concentration (ug/g). 72ug/g is typical of skeletal muscle.
d_skin = 60e-6; % epidermis thickness (m)
d_total = 1.5*27e-2;  % total path length (m)
PC.MELANIN = PC.MELANIN * 2*d_skin / d_total;   % adjust melanin fraction using fraction of epidermis wrt total path length
for ii = 1:numel(CHROMOPHORES)-1
    PC.OTHER = PC.OTHER - PC.(CHROMOPHORES{ii});
end
%[wl_cent, wl_nom] = getLeds;    % centroid and nominal LED wavelengths
LED_LINE = 1.;   % linewidth used to plot LED spectra
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
ledPath = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Insight2.0\HW_Optics\IncreasedCurrents\V&V\SpectrophotometerTest\Post-modification'];   % path with LED spectra

wl = linspace(WL_START, WL_END, WL_POINTS);

%% Modeling

% Absorption spectra
mu_a.water = H2O_mu_a(wl, PC.WATER);
[mu_a.Hhb, mu_a.HbO2] = Hb_mu_a(wl, tHb, SmO2, PC.BLOOD);
mu_a.collagen = collagen_mu_a(wl, PC.COLLAGEN);
mu_a.lipid = lipid_mu_a(wl, PC.LIPID);
%mu_a.melanin = melanosome_mu_a(wl, PC.MELANIN);
%mu_a.cytochrome = cyt_c_mu_a(wl, CYT_CONC);
%mu_a.other = zeros(size(wl)); % assume no relevant contribution to optical absoprtion from remaining constituents
mu_a.total = zeros(size(wl));
fl = fields(mu_a);
for ii = 1:numel(fl)-1
    mu_a.total = mu_a.total + mu_a.(fl{ii});
end

% LED spectra
ledFiles = dir([ledPath '\*UnitC*.txt.']);
[ledIrr, ledWavel] = readOO({ledFiles.name}, ledPath);
ledWavel = ledWavel(ledWavel < 1020);  % reject noisy part of spectrum
ledIrr = ledIrr(ledWavel < 1020);

% PD responsivity
R = PD_resp(wl); 
Rled = PD_resp(ledWavel);

% Normalize for plotting purposes
ledIrr = ledIrr * max(mu_a.total.*R) / max(ledIrr.*Rled); 


%% Output

figure
pie([PC.WATER PC.BLOOD PC.COLLAGEN PC.LIPID PC.MELANIN PC.OTHER], CHROMOPHORES)
title('Tissue constitution volume distribution')

figure
plot(wl, mu_a.water, 'b')
hold on
plot(wl, mu_a.Hhb, 'r')
plot(wl, mu_a.HbO2, 'r-.')
plot(wl, mu_a.collagen, 'g')
plot(wl, mu_a.lipid, 'g-.')
plot(wl, mu_a.melanin, 'c')
plot(wl, mu_a.cytochrome, 'm')
plot(wl, mu_a.total, 'k-.')
title('Contribution to optical absorption (1/cm)')
xlabel('wavelength (nm)')
ylabel('\mu_a(1/cm)')
grid
axis tight
legend(fl, 'Location', 'Best')

figure
hold on
plot(wl, mu_a.water.*R, 'b')
plot(wl, mu_a.Hhb.*R, 'r')
plot(wl, mu_a.HbO2.*R, 'r-.')
plot(wl, mu_a.collagen.*R, 'g')
plot(wl, mu_a.lipid.*R, 'g-.')
plot(wl, mu_a.melanin.*R, 'c')
plot(wl, mu_a.cytochrome, 'm')
plot(wl, mu_a.total.*R, 'k-.')
plot(ledWavel, ledIrr.*Rled, 'k', 'linewidth', LED_LINE)
title('Relative contribution to photocurrent')
xlabel('wavelength (nm)')
ylabel('Photocurrent (a.u.)')
grid
axis([WL_START WL_END 0 1])
legend({fl{:} 'leds'}, 'Location', 'Best')

