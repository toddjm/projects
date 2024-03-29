% Script used to perform N wavelength multiple regression to find 
% best weights for prediction of blood volume fraction for
% LED sources

% Portions of script and subroutines borrowed from P Silveira
% JM Schmitt, Consultant, Apr. 2016
% BSX Proprietary


clear all
close all
warning off all


numreply = input('Enter s-d separation in mm: ');
if isempty(numreply)
    PD_LED_DIST = 14; %Default number is 100
else
    PD_LED_DIST = numreply; %
end


numreply = input('Enter desired # random spectra: ');
if isempty(numreply)
    no_spectra = 100; %Default number is 100
else
    no_spectra = numreply; %
end


%% Initialization


best_rms_error = 100;  %This is the variable that will be minimized

%%Fixed parameters

mean_scat_coeff_at_800 = 1.79; %Mean scat coeff is 1.79 mm^-1 at 800nm
std_scat_coeff_at_800 = 0.5; %Estimated physiol std is 0.25 mm^-1

%PD_LED_DIST = 14.0; % 18.38-2.7/2   % photodiode-to-LEDs distance (mm) - Nellie wrist
rho = PD_LED_DIST;

mean_pct_wat = 65; %Estimated physiol min is 65%
std_pct_wat = 4; %Estimated physiol std is 78%

min_pct_bld = 0.5; %Estimated physiol min is 0.5%
max_pct_bld = 10; %Estimated physiol max is 10%

mean_pct_SmO2 = 78; %Estimated physiol mean is 78%
std_pct_SmO2 = 8;  %Estimated physiol std is 8%

mean_fract_dry_lipid = 0.28; %Estimated physiol mean is 0.28
std_fract_dry_lipid = 0.05; %Estimated physiol mean is 0.05

PC.MELANIN = 4;    % In epidermis. 11% = tanned caucasian
d_skin = 60e-6; % epidermis thickness (m)
%d_total = 1.5e-2*RHO_START;  % total path length (m)
d_total = 1.5e-2*rho;  % total path length (m)
PC.MELANIN = PC.MELANIN * 2*d_skin / d_total;   % adjust melanin fraction using fraction of epidermis wrt total path length


tHb = 12;   % g/dL
CYT_CONC = 72; % cytochrome c concentration (ug/g). 72ug/g is typical of skeletal muscle.
%n = skinIndex(wl);
n = skinIndex(800);  %Index at center of wavelength band

WL_START = 600; % shortest wavelength of interest
WL_END = 1100;  % longest wavelength of interest
WL_POINTS = 650;  % 1 nm per point
WL_STEP = (WL_END-WL_START)/WL_POINTS;
wl = linspace(WL_START, WL_END, WL_POINTS); % wavelengths

[spectrum, totPower, wavel_nom] = fietje(wl);  %LED spectra
[spectrum1020, totPower, wavel_nom] = fietje_1020(wl);
[spectrum970, totPower, wavel_nom] = marubeni_smc970(wl);
[spectrum1050, totPower, wavel_nom] = marubeni_smc1050(wl);
spectrum501 = Gauss_LED(wl,501,27);  %Gaussian spectrum 501 nm, 27 nm FWHM
spectrum516 = Gauss_LED(wl,516,29);  %Gaussian spectrum 516 nm, 29 nm FWHM
spectrum563 = Gauss_LED(wl,563,14);  %Gaussian spectrum 563 nm, 14 nm FWHM
spectrum574 = Gauss_LED(wl,574,17);  %Gaussian spectrum 574 nm, 17 nm FWHM
spectrum583 = Gauss_LED(wl,583,17);  %Gaussian spectrum 583 nm, 17 nm FWHM
spectrum627 = Gauss_LED(wl,627,14);  %Gaussian spectrum 627 nm, 14 nm FWHM
spectrum648 = Gauss_LED(wl,648,24);  %Gaussian spectrum 648 nm, 24 nm FWHM

% Constants
% Device and fabric geometries
%NEOPRENE_THICKNESS = 0.66;  % neoprene thickness (mm)
%NEOPRENE_THICKNESS_NOM = 0.66;  % neoprene thickness used in characterization (mm)
%DEV_WIDTH = 100; %36; % 37/2;    % watch width (mm) 33x34mm = iWatch, 36x42mm (Garmin w/ GPS)
%DEV_LENGTH = 48;    % watch length (mm)
%WATCHBAND_WIDTH = 30;   % watch band width (mm)
%FABRIC_LENGTH = DEV_WIDTH/2; %30; % max. radius of extent of light-blocking fabric
%LED_CURRENT = 113;  % leds current, mA
%LED_CURRENT_NOM = 50;   % led nominal current (mA) - used during LED
%characterization


for LEDindx1 = [2],
    for LEDindx2 = [3 4],
        for LEDindx3 = [5 6 8],
             for LEDindx4 = [7 9],
                 for LEDindx5 = [11 12 13],
        
LED_list = [LEDindx1 LEDindx2 LEDindx3 LEDindx4 LEDindx5]; %


no_LEDs = size(LED_list,2);

for ii = 1:no_LEDs;
    
switch (LED_list(ii))
    case 1
        Wave(ii) = 501;
    case 2
        Wave(ii) = 516;
    case 3
        Wave(ii) = 563;
    case 4
        Wave(ii) = 574;
    case 5
        Wave(ii) = 583;
    case 6
        Wave(ii) = 627;
    case 7
        Wave(ii) = 648;
    case 8
        Wave(ii) = 665;
    case 9
        Wave(ii) = 810;
    case 10
        Wave(ii) = 850;
    case 11
        Wave(ii) = 950;
    case 12
        Wave(ii) = 970;
    case 13
        Wave(ii) = 1020;
    case 14
        Wave(ii) = 1050;
end
end

        for i = 1:no_spectra,
            % Tissue modeling
            %PC.WATER = 65;  % water fractional volume. 72% typical for Skin 72%, 83% for Blood 83%, 76% muscle and 10% adipose tissue.
            %PC.BLOOD = 5;  % Blood volume. 1% - vasoconstriction, 15% vasodilation. 5% typical
            %PC.WATER = min_pct_wat+(i-1)*(max_pct_wat-min_pct_wat)/no_spectra;
            %PC.WATER = min_pct_wat+(max_pct_wat-min_pct_wat)*rand; %Uniform random distribution of water pct
            %PC.BLOOD = mean_pct_bld + std_pct_bld * randn;  %Blood volume 5% mean with std dev of +/- 1%
            
            PC.WATER = mean_pct_wat+std_pct_wat * randn; %Normal distribution of water pct
            PC.BLOOD = min_pct_bld + (max_pct_bld-min_pct_bld)*rand;  %Uniform distribution of blood volumes
            
            %PC.BLOOD= 1+(i-1)*9/no_spectra;
            if PC.WATER < 53, PC.WATER = 53; end %Do not let water fraction go beyon 3 SDs
            if PC.WATER > 77, PC.WATER = 77; end 

            pct_wet = PC.WATER+0.8*PC.BLOOD; %Wet fraction is water + liquid part of blood
            pct_dry = 100 - pct_wet+std_fract_dry_lipid*PC.BLOOD; % Remaining fraction is dry
            %fract_dry_lipid = 0.28;
            fract_dry_lipid = mean_fract_dry_lipid + std_fract_dry_lipid*randn; % Variable fraction of dry tissue is lipid
            PC.LIPID = fract_dry_lipid*pct_dry; % Lipid set as fraction of dry tissue
            if PC.LIPID < 0, PC.LIPID = 0; end %Do not let values go negative
            %PC.LIPID = 10;
            PC.COLLAGEN = pct_dry-PC.LIPID; % Remaining fraction of dry tissue is collagen
            if PC.COLLAGEN < 0, PC.COLLAGEN = 0; end %Do not let values go negative
            %PC.COLLAGEN = 25;
            PC.OTHER = 100;
            CHROMOPHORES = fields(PC);
            for ii = 1:numel(CHROMOPHORES)-1
            PC.OTHER = PC.OTHER - PC.(CHROMOPHORES{ii});
            end
            SmO2 = mean_pct_SmO2 + std_pct_SmO2*randn;  % mean muscle S02 with  s.d.
            
            % Modeling constants

            %RHO_START = DEV_WIDTH/2;  % shortest distance of interest (usually set to PD radius. In this case, the watchband width divided by 2)
            %RHO_END = 70; %80;   % longest distance of interest (usually set to maximum radius of limb of interest)
            %RHO_POINTS = 200;
            %WRIST_WIDTH = 60;   % max. width of wrist (mm)
            %rho = linspace(RHO_START,RHO_END,RHO_POINTS);   % distances
            %[RHO, WL] = ndgrid(rho, wl);    % 2-D grid of distances and wavelengths
            %USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
            %ledPath = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Insight2.0\HW_Optics\IncreasedCurrents\V&V\SpectrophotometerTest\Post-modification'];   % path with LED spectra


            % Tissue absorption spectra
            mu_s = (mean_scat_coeff_at_800+std_scat_coeff_at_800*randn)*(wl/800).^(-1.53);  %Trans-corr scat coeff (1/mm) from Chan IEEE Sel Top Quant
            if mu_s < 0.75, mu_s = 0.75; end %Limit low end of mu_s at 3 SDs
            if mu_s > 2.54, mu_s = 2.54; end %Limit hi end of mu_s at 3 SDs
            
            mu_a.water = H2O_mu_a(wl, PC.WATER)/10; % convert from 1/cm to 1/mm
            [mu_a.Hhb, mu_a.HbO2] = Hb_mu_a(wl, tHb, SmO2, PC.BLOOD);
            mu_a.Hhb = mu_a.Hhb/10;    % convert from 1/cm to 1/mm
            mu_a.HbO2 = mu_a.HbO2/10;

%             [offset_error,I] = max(diff(mu_a.HbO2)); %Correct offset artifact in HbO2 mu_a spectrum
%             mu_a.HbO2_corr = mu_a.HbO2;
%             mu_a.HbO2_corr(I+1:WL_POINTS) = mu_a.HbO2(I+1:WL_POINTS)-0.5*offset_error;
%             mu_a.HbO2_corr_f = medfilt2(mu_a.HbO2_corr,[1 3]);
%             mu_a.HbO2 = mu_a.HbO2_corr_f;

            %mu_a.collagen = collagen_mu_a(wl, PC.COLLAGEN)/10;
            mu_a.collagen = 1.38*collagen_mu_a(wl, PC.COLLAGEN)/100;  %Collagen powder abs from Taroni
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
            %[PD, PDA] = PD_resp(wl); % PDA takes into account area of photodetector

            % Define fabric attenuation
            %OD = zeros(RHO_POINTS,WL_POINTS);
            % Black fabric ODs: 2.11	0.95	0.95	0.88
            % nominal neoprene ODs: 3.66	4.00	3.78	3.66
            % OD(WL<850) = 3.78*NEOPRENE_THICKNESS/NEOPRENE_THICKNESS_NOM + 0.95;
            % OD(WL<=810) = 4*NEOPRENE_THICKNESS/NEOPRENE_THICKNESS_NOM + 0.95;
            % OD(WL<=665) = 3.66*NEOPRENE_THICKNESS/NEOPRENE_THICKNESS_NOM + 2.11;
            %OD(RHO>FABRIC_LENGTH) = 0; % 2.11;
            %OD(RHO>FABRIC_LENGTH & WL>810) = 0.95;
            %OD(RHO>FABRIC_LENGTH & WL>950) = 0.88;
            %OD(RHO<DEV_WIDTH/2 & RHO<DEV_LENGTH/2) = 10;    % device attenuation (OD = 10 below device)
            %T = 10.^(-OD);  % fabric transmission

            %plastic = sabic(wl);    % plastic window transmission
            % plastic(wl<680) = 0.9;    % IR-cut window
            % plastic(wl>=680) = 0.1;    % IR-cut window
            %plastic = ones(size(wl));   % 100% transmission

            %mu_s = calc_mu_s(wl, 'forearm')/20; % Convert from 1/cm to 1/mm
           
            % for ii = 1:RHO_POINTS   % tissue transmission @ all wavelengths and distances
            %     Rr(ii,:) = getRr2(mu_a.total, mu_s, rho(ii), n);
            % end
          
            
            Rr(:,i) = getRr(mu_a.total, mu_s, rho, n); % tissue transmission @ all wavelengths (fixed distance)

            %y(i) = PC.WATER; %Water is predicted variable
            y(i) = PC.BLOOD; %Blood volume is predicted variable
            x1(i) = -log10(sum(spectrum501'.*Rr(:,i))); %Weighted OD at 501 nm
            x2(i) = -log10(sum(spectrum516'.*Rr(:,i))); %Weighted OD at 516
            x3(i) = -log10(sum(spectrum563'.*Rr(:,i))); %Weighted OD at 563
            x4(i) = -log10(sum(spectrum574'.*Rr(:,i))); %Weighted OD at 574
            x5(i) = -log10(sum(spectrum583'.*Rr(:,i))); %Weighted OD at 583
            x6(i) = -log10(sum(spectrum627'.*Rr(:,i))); %Weighted OD at 627
            x7(i) = -log10(sum(spectrum648'.*Rr(:,i))); %Weighted OD at 648
            x8(i) = -log10(sum(spectrum(1,:)'.*Rr(:,i))); %Weighted OD at 665
            x9(i) = -log10(sum(spectrum(2,:)'.*Rr(:,i))); %Weighted OD at 810
            x10(i) = -log10(sum(spectrum(3,:)'.*Rr(:,i))); %Weighted OD at 850
            x11(i) = -log10(sum(spectrum(4,:)'.*Rr(:,i))); %Weighted OD at 950
            x12(i) = -log10(sum(spectrum970'.*Rr(:,i))); %Weighted OD at 970
            x13(i) = -log10(sum(spectrum1020'.*Rr(:,i))); %Weighted OD at 1020
            x14(i) = -log10(sum(spectrum1050'.*Rr(:,i))); %Weighted OD at 1050
       
        end
        Xi = [x1' x2' x3' x4' x5' x6' x7' x8' x9' x10' x11' x12' x13' x14'];  %Array of OD values for different LEDs
        Xi_sub = Xi(:,LED_list);
        X = [ones(size(x1')) Xi_sub];
        b = X\y'; %Calculate multiple regression coefficients

        y_pred = X*b;  %predicted water percent using regression coeffs
        rms_error = mean(abs(y_pred'-y));
        
            if rms_error < best_rms_error
            best_rms_error = rms_error; best_LEDindx1 = LEDindx1;
            best_LEDindx2 = LEDindx2; best_LEDindx3 = LEDindx3; 
            best_LEDindx4 = LEDindx4; best_LEDindx5 = LEDindx5; best_y_pred = y_pred;
            best_y = y;best_b = b;
            end
    end
        end
    end
    end
end


%Set all regression parameters to those of best wavelength pair 
LEDindx1 = best_LEDindx1;
LEDindx2 = best_LEDindx2;
LEDindx3 = best_LEDindx3;
LEDindx4 = best_LEDindx4;
LEDindx5 = best_LEDindx5;

LED_list = [LEDindx1 LEDindx2 LEDindx3 LEDindx4 LEDindx5];
b = best_b;y = best_y; y_pred = best_y_pred;
rms_error = best_rms_error;

for ii = 1:no_LEDs;
    
switch (LED_list(ii))
    case 1
        Wave(ii) = 501;
    case 2
        Wave(ii) = 516;
    case 3
        Wave(ii) = 563;
    case 4
        Wave(ii) = 574;
    case 5
        Wave(ii) = 583;
    case 6
        Wave(ii) = 627;
    case 7
        Wave(ii) = 648;
    case 8
        Wave(ii) = 665;
    case 9
        Wave(ii) = 810;
    case 10
        Wave(ii) = 850;
    case 11
        Wave(ii) = 950;
    case 12
        Wave(ii) = 970;
    case 13
        Wave(ii) = 1020;
    case 14
        Wave(ii) = 1050;
end
end

    %% Plot results
    
 
    
    figure(1)
    subplot(221)
    title('Regression')
    plot(y,y_pred','*',0:10,0:10,'k-')
    for ii = 1:no_LEDs
    text(1,9-(ii-1),['\lambda' num2str(ii) '= ' num2str(Wave(ii),'%3d') 'nm'])
    end
    
    switch no_LEDs
        case 1
    text(1,7,['B= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1'])
        case 2
    text(1,7,['B= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2'])
        case 3
    text(1,7,['B= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2 +'  num2str(b(4,1),'%4.2e') ' OD_\lambda_3'])
        case 4
    text(1,7,['B= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2 +'  num2str(b(4,1),'%4.2e') ' OD_\lambda_3+'  num2str(b(5,1),'%4.2e') ' OD_\lambda_4'])     
        case 5
    text(1,7,['B= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2 +'  num2str(b(4,1),'%4.2e') ' OD_\lambda_3+'  num2str(b(5,1),'%4.2e') ' OD_\lambda_4+' num2str(b(6,1),'%4.2e') ' OD_\lambda_5'] )   
    end
    
    xlabel('Actual % Blood')
    ylabel('Predicted % Blood')
    axis([0 10 0 10])
    subplot(222)
    title('Bland-Altman')
    plot(0.5*(y+y_pred'),y_pred'-y,'*',0:10,zeros(1,11),'k-')
    text(1,0.75,['RMSE= ' num2str(rms_error,'%4.2f') '%'])
    xlabel('0.5*(Actual+Predicted)')
    ylabel('Predicted - Actual')
    axis([0 10 -2 2])
