% Script used to model Sun light absorption through skin and fabric.
%
% P. Silveira, Feb. 2016
% BSX Proprietary

%% Initialization

clear
close all

% Constants
% Device and fabric geometries
%NEOPRENE_THICKNESS = 0.66;  % neoprene thickness (mm)
%NEOPRENE_THICKNESS_NOM = 0.66;  % neoprene thickness used in characterization (mm)
DEV_WIDTH = 36;23; %100; %36; % 37/2;    % watch width (mm) 33x34mm = iWatch, 36x42mm (Garmin w/ GPS) 
%DEV_LENGTH = 48;    % watch length (mm)
%WATCHBAND_WIDTH = 30;   % watch band width (mm)
%FABRIC_LENGTH = DEV_WIDTH/2; %30; % max. radius of extent of light-blocking fabric
LED_CURRENT = 113;  % leds current, mA
LED_CURRENT_NOM = 50;   % led nominal current (mA) - used during LED characterization
PD_LED_DIST = 17.66;%12.5;%17.66;% 17.03; % 18.38-2.7/2   % photodiode-to-LEDs distance (mm) - Nellie wrist
% Tissue modeling
PC.WATER = 60;  % water fractional volume. 72% typical for Skin 72%, 83% for Blood 83%, 76% muscle and 10% adipose tissue.
PC.BLOOD = 2;  % Blood volume. 1% - vasoconstriction, 15% vasodilation. 5% typical
PC.COLLAGEN = 10;
PC.LIPID = 15;
PC.MELANIN = 4;    % In epidermis. 11% = tanned caucasian
PC.OTHER = 100;
CHROMOPHORES = fields(PC);
SmO2 = 78;  % %
tHb = 12;   % g/dL
CYT_CONC = 72; % cytochrome c concentration (ug/g). 72ug/g is typical of skeletal muscle.
% Modeling constants
WL_START = 350; % shortest wavelength of interest
WL_END = 1150;  % longest wavelength of interest
WL_POINTS = 300;
RHO_START = DEV_WIDTH/2;  % shortest distance of interest (usually set to PD radius. In this case, the watchband width divided by 2)
RHO_END = 80;   % longest distance of interest
RHO_POINTS = 200;
WRIST_WIDTH = 60;   % max. width of wrist (mm)
PD_Area = (0.277).^2;  % S12158 area (cm^2)

wl = linspace(WL_START, WL_END, WL_POINTS); % wavelengths
rho = linspace(RHO_START,RHO_END,RHO_POINTS);   % distances
[RHO, WL] = ndgrid(rho, wl);    % 2-D grid of distances and wavelengths

%USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
%ledPath = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Insight2.0\HW_Optics\IncreasedCurrents\V&V\SpectrophotometerTest\Post-modification'];   % path with LED spectra


%% Tissue Modeling

d_skin = 60e-6; % epidermis thickness (m)
d_total = 1.5e-2*RHO_START;  % total path length (m)
PC.MELANIN = PC.MELANIN * 2*d_skin / d_total;   % adjust melanin fraction using fraction of epidermis wrt total path length
for ii = 1:numel(CHROMOPHORES)-1
    PC.OTHER = PC.OTHER - PC.(CHROMOPHORES{ii});
end

% Tissue absorption spectra
mu_a.water = H2O_mu_a(wl, PC.WATER)/10; % convert from 1/cm to 1/mm
[mu_a.Hhb, mu_a.HbO2] = Hb_mu_a(wl, tHb, SmO2, PC.BLOOD); 
mu_a.Hhb = mu_a.Hhb/10;    % convert from 1/cm to 1/mm
mu_a.HbO2 = mu_a.HbO2/10;
mu_a.collagen = collagen_mu_a(wl, PC.COLLAGEN)/10;
mu_a.lipid = lipid_mu_a(wl, PC.LIPID)/10;
mu_a.melanin = melanosome_mu_a(wl, PC.MELANIN)/10;
mu_a.cytochrome = cyt_c_mu_a(wl, CYT_CONC)/10;
mu_a.total = zeros(size(wl));
fl = fields(mu_a);
for ii = 1:numel(fl)-1
    mu_a.total = mu_a.total + mu_a.(fl{ii});
end


%% Numeric modeling

% PD responsivity
PD = PD_resp(wl); % PDA takes into account area of photodetector
PDA = PD * PD_Area;

% Define fabric attenuation
OD = zeros(RHO_POINTS,WL_POINTS);
% Black fabric ODs: 2.11	0.95	0.95	0.88
% nominal neoprene ODs: 3.66	4.00	3.78	3.66
% OD(WL<850) = 3.78*NEOPRENE_THICKNESS/NEOPRENE_THICKNESS_NOM + 0.95; 
% OD(WL<=810) = 4*NEOPRENE_THICKNESS/NEOPRENE_THICKNESS_NOM + 0.95; 
% OD(WL<=665) = 3.66*NEOPRENE_THICKNESS/NEOPRENE_THICKNESS_NOM + 2.11;
%OD(RHO>FABRIC_LENGTH) = 0; % 2.11; 
%OD(RHO>FABRIC_LENGTH & WL>810) = 0.95;
%OD(RHO>FABRIC_LENGTH & WL>950) = 0.88;
%OD(RHO<DEV_WIDTH/2 & RHO<DEV_LENGTH/2) = 10;    % device attenuation (OD = 10 below device)
T = 10.^(-OD);  % fabric transmission

plastic = sabic(wl);    % plastic window transmission
% plastic(wl<680) = 0.9;    % IR-cut window
% plastic(wl>=680) = 0.1;    % IR-cut window
%plastic = ones(size(wl));   % 100% transmission

mu_s = calc_mu_s(wl, 'forearm')/20; % Convert from 1/cm to 1/mm
n = skinIndex(wl);
for ii = 1:RHO_POINTS   % tissue transmission @ all wavelengths and distances
    Rr(ii,:) = getRr2(mu_a.total, mu_s, rho(ii), n);
end
% Also calculate mu_eff as a "sanity check" of the model. Not needed to calculate photocurrents.
solar_Irr = 1.2443*1e-4 * solarIrr(wl); % Solar irradiance (W/cm^2/nm), at the Equator. Multiplied by 1e-4 to convert from 1/m^2 to 1/cm^2
solar_flux =  Rr.*T.*repmat(solar_Irr.*PDA.*plastic, RHO_POINTS,1); % (A/cm^2nm)
i_photo_sun = 2*WRIST_WIDTH*trapz(rho,trapz(wl,solar_flux,2)*1e-2);    % Amps (multiplied by 1E-2 to convert from 1/cm^2 to 1/mm^2 before integrating)
fprintf('Current due to ambient light = %fnAmps\n', i_photo_sun*1e9);

led_spectrum = fietje(wl);   % led spectral densities (mW/nm)
[~, leds] = getLeds;
%leds{end+1} = '505';    % center wavelength of fictitious LED
%led_spectrum(5,:) = 13/22*exp(-((wl-str2num(leds{end}))/12).^2);  % spectrum of fictitious LED
[RrLEDs, mu_eff] = getRr2(mu_a.total, mu_s, PD_LED_DIST, n);  % tissue transmission @ PD_LED_DISTmm, all wavelengths. Also mu_eff in 1/mm (doesn't change with distance)
led_flux = LED_CURRENT/LED_CURRENT_NOM*1e-3*led_spectrum.*repmat(RrLEDs.*plastic.*PDA, length(leds),1); % (A/nm) Multiply by 1e-3 to convert spectral density from mW/nm to W/nm
i_led = trapz(wl, led_flux, 2); % Amps
fprintf('Current due to %dnm LED = %fnAmps.\tSNR = %f\n', [str2num(cell2mat(leds))'; 1e9*i_led';  i_led' ./ i_photo_sun])

%% Plot results

figure
pie([PC.WATER PC.BLOOD PC.COLLAGEN PC.LIPID PC.MELANIN PC.OTHER])
title('Tissue constitution volume distribution')
legend(CHROMOPHORES,'Location','WestOutside')
set(gcf, 'Position', [553 252 740 526])

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
title('Contribution to optical absorption (1/mm)')
xlabel('wavelength (nm)')
ylabel('\mu_a(1/mm)')
grid
axis tight
legend(fl, 'Location', 'Best')

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
title('Contribution to optical absorption (1/mm)')
xlabel('wavelength (nm)')
ylabel('\mu_a(1/mm)')
grid
axis tight
legend(fl, 'Location', 'Best')
axis([665 1100 0 0.12])

figure
mesh(wl, rho, -log10(Rr));
ylabel('Distance (mm)')
xlabel('Wavelength (nm)')
zlabel('OD')
title('Tissue absorbance')
view(135,30)

figure
mesh(wl, rho, -log10(T));
ylabel('Distance (mm)')
xlabel('Wavelength (nm)')
zlabel('Fabric OD')
view(135,30)

% figure
% surface(wl, rho, -log10(T));
% ylabel('Distance (mm)')
% xlabel('Wavelength (nm)')
% zlabel('Fabric OD')
% view(135,30)
% shading interp
% colormap (1-gray)

figure
mesh(wl, rho, 1e12*solar_flux);
ylabel('Distance (mm)')
xlabel('Wavelength (nm)')
zlabel('I_{Sun} [nA/(cm^{2}nm)]')
view(135,30)
axis tight
title('Photocurrent density')

figure
plot(wl, mu_eff);
xlabel('Wavelength (nm)')
ylabel('\mu_{eff} (1/mm)')
grid
axis tight

figure
plot(wl, mu_eff);
xlabel('Wavelength (nm)')
ylabel('\mu_{eff} (1/mm)')
grid
axis([665 wl(end) 0 .08])

figure
plot(wl, -log10(RrLEDs));
xlabel('Wavelength (nm)')
ylabel('OD')
title(['Tissue Absorbance @ ' num2str(PD_LED_DIST) 'mm'])
grid
axis tight

figure
plot(wl, -log10(RrLEDs));
xlabel('Wavelength (nm)')
ylabel('OD')
title(['Tissue Absorbance @ ' num2str(PD_LED_DIST) 'mm'])
grid
axis([665 wl(end) 3 7])

figure
plot(wl, led_spectrum)
grid
hold on
plot(wl, plastic, 'k-.')
plot(wl, PD, 'r-.')
ylabel('Power density (mW/nm)')
xlabel('Wavelength (nm)')
axis tight
legend(leds{:}, 'Plastic', 'PD', 'Location', 'Best')
hold off

figure
plot(wl, 1e9*led_flux)
grid
axis tight
ylabel('Photocurrent density (nA/nm)')
xlabel('Wavelength (nm)')
legend(leds,  'Location', 'Best')


% B&W plots
figure
contour(wl, rho, -log10(Rr), 'ShowText', 'on');
ylabel('Distance (mm)')
xlabel('Wavelength (nm)')
%zlabel('OD')
title('Tissue optical density')
%view(135,30)
colormap([0 0 0])

figure
contour(wl, rho, 1e12*solar_flux, 'ShowText', 'on');
ylabel('Distance (mm)')
xlabel('Wavelength (nm)')
%zlabel('I_{Sun} [nA/(cm^{2}nm)]')
%view(135,30)
axis tight
title('Photocurrent density [nA/(cm^{2}nm)]')
colormap([0 0 0])

