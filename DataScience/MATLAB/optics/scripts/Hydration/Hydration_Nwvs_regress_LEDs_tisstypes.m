% Script used to perform N wavelength multiple regression to find 
% best weights for prediction of tissue water fraction for
% LED sources

% Portions of script and subroutines borrowed from P Silveira
% JM Schmitt, Consultant, Mar. 2016
% BSX Proprietary


clear all
close all
warning off all

numreply = input('Enter LED list (1=665nm,2=810,3=850,4=950,5=970,6=1020,7=1050)\n e.g., [3 5 6]: ');
if isempty(numreply)
    LED_list = [3 5 6]; %Default list
else
    LED_list = numreply; %
end

numreply = input('Enter source-detector distance (mm): ');
if isempty(numreply)
    PD_LED_DIST = 14; %Default distance
else
    PD_LED_DIST = numreply; %
end

numreply = input('Enter location (1 = calf; 2 = wrist; 3 = temple): ');
if isempty(numreply)
    LOCATION_INDEX = 1; %Default distance
else
    LOCATION_INDEX = numreply; %
end

no_LEDs = size(LED_list,2);

for ii = 1:no_LEDs;
    
switch (LED_list(ii))
    case 1
        Wave(ii) = 665;
    case 2
        Wave(ii) = 810;
    case 3
        Wave(ii) = 850;
    case 4
        Wave(ii) = 950;
    case 5
        Wave(ii) = 970;
    case 6
        Wave(ii) = 1020;
    case 7
        Wave(ii) = 1050;
end
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

%PD_LED_DIST = 14.0; % 18.38-2.7/2   % photodiode-to-LEDs distance (mm) - Nellie wrist
rho = PD_LED_DIST;


switch (LOCATION_INDEX)
    
    case 1 %Calf
        
    mean_pct_bld = 8; %Estimated physiol mean is 8%
    std_pct_bld = 2.0; %Estimated physiol std is 2%

    mean_pct_SmO2 = 78; %Estimated physiol mean is 78%
    std_pct_SmO2 = 8;  %Estimated physiol std is 8%

    mean_fract_dry_lipid = 0.28; %Estimated physiol mean is 0.28
    std_fract_dry_lipid = 0.05; %Estimated physiol mean is 0.05

    case 2 %Wrist
        
    mean_pct_bld = 4; %Estimated physiol mean is 5%
    std_pct_bld = 2; %Estimated physiol std is 2%

    mean_pct_SmO2 = 90; %Estimated physiol mean is 78%
    std_pct_SmO2 = 8;  %Estimated physiol std is 8%

    mean_fract_dry_lipid = 0.20; %Estimated physiol mean is 0.20
    std_fract_dry_lipid = 0.05; %Estimated physiol mean is 0.05
    
    case 3 %Temple
        
    mean_pct_bld = 6; %Estimated physiol mean is 6%
    std_pct_bld = 2; %Estimated physiol std is 2%

    mean_pct_SmO2 = 90; %Estimated physiol mean is 78%
    std_pct_SmO2 = 8;  %Estimated physiol std is 8%

    mean_fract_dry_lipid = 0.20; %Estimated physiol mean is 0.20
    std_fract_dry_lipid = 0.05; %Estimated physiol mean is 0.05
end

min_pct_wat = 52; %Estimated physiol min is 52%
max_pct_wat = 78; %Estimated physiol max is 78%

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
WL_POINTS = 500;  % 1 nm per pint
WL_STEP = (WL_END-WL_START)/WL_POINTS;
wl = linspace(WL_START, WL_END, WL_POINTS); % wavelengths
mu_s = 1.79*(wl/800).^(-1.53);  %Trans-corr scat coeff (1/mm) from Chan IEEE Sel Top Quant

[spectrum, totPower, wavel_nom] = fietje(wl);  %LED spectra
[spectrum1020, totPower, wavel_nom] = fietje_1020(wl);
[spectrum970, totPower, wavel_nom] = marubeni_smc970(wl);
[spectrum1050, totPower, wavel_nom] = marubeni_smc1050(wl);

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



        for i = 1:no_spectra,
            % Tissue modeling
            %PC.WATER = 65;  % water fractional volume. 72% typical for Skin 72%, 83% for Blood 83%, 76% muscle and 10% adipose tissue.
            %PC.BLOOD = 5;  % Blood volume. 1% - vasoconstriction, 15% vasodilation. 5% typical
            %PC.WATER = min_pct_wat+(i-1)*(max_pct_wat-min_pct_wat)/no_spectra;
            PC.WATER = min_pct_wat+(max_pct_wat-min_pct_wat)*rand; %Uniform random distribution of water pct
            PC.BLOOD = mean_pct_bld + std_pct_bld * randn;  
            %PC.BLOOD= 1+(i-1)*9/no_spectra;
            if PC.BLOOD < 0, PC.BLOOD = 0; end %Do not let values go negative

            pct_wet = PC.WATER+0.8*PC.BLOOD; %Wet fraction is water + liquid part of blood
            pct_dry = 100 - pct_wet+std_fract_dry_lipid*PC.BLOOD; % Remaining fraction is dry
            %fract_dry_lipid = 0.28;
            fract_dry_lipid = mean_fract_dry_lipid + std_fract_dry_lipid*randn; % Variable fraction of dry tissue is lipid
            PC.LIPID = fract_dry_lipid*pct_dry; % Lipid set as fraction of dry tissue
            %PC.LIPID = 10;
            PC.COLLAGEN = pct_dry-PC.LIPID; % Remaining fraction of dry tissue is collagen
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
            mu_a.water = H2O_mu_a(wl, PC.WATER)/10; % convert from 1/cm to 1/mm
            [mu_a.Hhb, mu_a.HbO2] = Hb_mu_a(wl, tHb, SmO2, PC.BLOOD);
            mu_a.Hhb = mu_a.Hhb/10;    % convert from 1/cm to 1/mm
            mu_a.HbO2 = mu_a.HbO2/10;

            [offset_error,I] = max(diff(mu_a.HbO2)); %Correct offset artifact in HbO2 mu_a spectrum
            mu_a.HbO2_corr = mu_a.HbO2;
            mu_a.HbO2_corr(I+1:WL_POINTS) = mu_a.HbO2(I+1:WL_POINTS)-0.5*offset_error;
            mu_a.HbO2_corr_f = medfilt2(mu_a.HbO2_corr,[1 3]);
            mu_a.HbO2 = mu_a.HbO2_corr_f;

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

            y(i) = PC.WATER; %Water is predicted variable
            x1(i) = -log10(sum(spectrum(1,:)'.*Rr(:,i))); %Weighted OD at 665
            x2(i) = -log10(sum(spectrum(2,:)'.*Rr(:,i))); %Weighted OD at 810
            x3(i) = -log10(sum(spectrum(3,:)'.*Rr(:,i))); %Weighted OD at 850
            x4(i) = -log10(sum(spectrum(4,:)'.*Rr(:,i))); %Weighted OD at 950
            x5(i) = -log10(sum(spectrum970'.*Rr(:,i))); %Weighted OD at 970
            x6(i) = -log10(sum(spectrum1020'.*Rr(:,i))); %Weighted OD at 1020
            x7(i) = -log10(sum(spectrum1050'.*Rr(:,i))); %Weighted OD at 1050
        end
        Xi = [x1' x2' x3' x4' x5' x6' x7'];  %Array of OD values for different LEDs
        Xi_sub = Xi(:,LED_list);
        X = [ones(size(x1')) Xi_sub];
        b = X\y'; %Calculate multiple regression coefficients

        y_pred = X*b;  %predicted water percent using regression coeffs
        rms_error = mean(abs(y_pred'-y));

 



    %led_spectrum = fietje(wl);   % led spectral densities (mW/nm)
    %[~, leds] = getLeds;
    %leds{end+1} = '505';    % center wavelength of fictitious LED
    %led_spectrum(5,:) = 13/22*exp(-((wl-str2num(leds{end}))/12).^2);  % spectrum of fictitious LED
    % [RrLEDs, mu_eff] = getRr2(mu_a.total, mu_s, PD_LED_DIST, n);  % tissue transmission @ PD_LED_DISTmm, all wavelengths. Also mu_eff in 1/mm (doesn't change with distance)
    % led_flux = LED_CURRENT/LED_CURRENT_NOM*1e-3*led_spectrum.*repmat(RrLEDs.*plastic.*PDA, length(leds),1); % (A/nm) Multiply by 1e-3 to convert spectral density from mW/nm to W/nm
    % i_led = trapz(wl, led_flux, 2); % Amps
    % fprintf('Current due to %dnm LED = %fnAmps.\tSNR = %f\n', [str2num(cell2mat(leds))'; 1e9*i_led';  i_led' ./ i_photo_sun])

    %% Plot results
    
    figure(1)
    plot(wl,-log10(Rr))
    set(gca,'FontSize',12)
    xlabel('Wavelength (nm)','FontSize',12)
    ylabel('Transflectance Loss (OD Units)','FontSize',12)
    text(680,7.75,['Water ' num2str(min_pct_wat) ': ' num2str(max_pct_wat) '%'],'FontSize',12)
    text(680,7.5,['Bld avg +/- std = ' num2str(mean_pct_bld) '+/- ' num2str(std_pct_bld) '%'],'FontSize',12)
    axis([WL_START WL_END 5 8])
    
    figure(2)
    subplot(221)
    title('Regression')
    plot(y,y_pred','*',50:80,50:80,'k-')
    for ii = 1:no_LEDs
    text(55,78-3*(ii-1),['\lambda' num2str(ii) '= ' num2str(Wave(ii),'%3d') 'nm'])
    end
    
    switch no_LEDs
        case 1
    text(50,30,['W= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1'])
        case 2
    text(50,30,['W= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2'])
        case 3
    text(50,30,['W= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2 +'  num2str(b(4,1),'%4.2e') ' OD_\lambda_3'])
        case 4
    text(50,30,['W= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2 +'  num2str(b(4,1),'%4.2e') ' OD_\lambda_3+'  num2str(b(5,1),'%4.2e') ' OD_\lambda_4'])     
        case 5
    text(50,30,['W= ' num2str(b(2,1),'%4.2e') ' OD_\lambda_1 +' num2str(b(3,1),'%4.2e') ' OD_\lambda_2 +'  num2str(b(4,1),'%4.2e') ' OD_\lambda_3+'  num2str(b(5,1),'%4.2e') ' OD_\lambda_4+' num2str(b(6,1),'%4.2e') ' OD_\lambda_5'] )   
    end
    
    xlabel('Actual % Water')
    ylabel('Predicted % Water')
    axis([50 80 50 80])
    subplot(222)
    title('Bland-Altman')
    plot(0.5*(y+y_pred'),y_pred'-y,'*',50:80,zeros(1,31),'k-')
    text(65,15,['RMSE= ' num2str(rms_error,'%4.2f') '%'])
    xlabel('0.5*(Actual+Predicted)')
    ylabel('Predicted - Actual')
    axis([50 80 -20 20])