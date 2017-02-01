% Script used to read and analyze LED spectral data
%
% P. Silveira, May 2015
% BSX Proprietary

%% Initialization
clear all
close all

pathN = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\LED_characterization\';
pathN = uigetdir(pathN,'Select folder with LED spectra');
cd(pathN)

FONTSIZE = 11;  % label font size

i665 = 0;   % file counters
i810 = 0;
i850 = 0;
i950 = 0;
%Correction = 1/5.52;
%Area = pi*(0.635/2)^2;   % Area of cosine corrector (cm^2)

%% Data input

filelist = dir('Fietje*.txt');

for ii=1:numel(filelist)
    ledNum = filelist(ii).name(21:23);  % find LED
    [irr, wavel] = readOO(filelist(ii).name);
%    fid = fopen(filelist(ii).name);
%    header = textscan(fid, '%s', 16, 'delimiter', '\n');   % skip header
%    data = textscan(fid, '%f %f', 'CollectOutput', 1);  % import irradiance values
    switch(ledNum)
        case{'665'}
            i665 = i665+1;
%            irr665(:,i665) = data{1}(:,2);
            irr665(:,i665) = irr;
        case{'810'}
            i810 = i810+1;
%            irr810(:,i810) = data{1}(:,2);
            irr810(:,i810) = irr;
        case{'850'}
            i850 = i850+1;
%            irr850(:,i850) = data{1}(:,2);
            irr850(:,i850) = irr;
        case{'950'}
            i950 = i950+1;
%            irr950(:,i950) = data{1}(:,2);
            irr950(:,i950) = irr;
        otherwise
            error(['Unidentified LED: ' ledNum])
    end
%    fclose(fid);
end
%wavel = data{1}(:,1);   % wavelength vector (nm)

%% Data analysis

sp665 = process_spectrum(irr665, wavel);
sp810 = process_spectrum(irr810, wavel);
sp850 = process_spectrum(irr850, wavel);
sp950 = process_spectrum(irr950, wavel);

% power665 = irr665*Area/1000; % convert from Irradiances (uW/cm^2) to Powers mW
% power810 = irr810*Area/1000;
% power850 = irr850*Area/1000;
% power950 = irr950*Area/1000;
% 
% waveRange = wavel(end) - wavel(1);  % range of wavelength (nm)
% 
% totPow665 = sum(power665,1); % calculate total powers
% totPow810 = sum(power810,1);
% totPow850 = sum(power850,1);
% totPow950 = sum(power950,1);
% 
% R = PD_resp(wavel); % get responsivity values (A/W)
% cur665 = power665.*repmat(R,1,i665);    % calculate photocurrents
% cur810 = power810.*repmat(R,1,i810);
% cur850 = power850.*repmat(R,1,i850);
% cur950 = power950.*repmat(R,1,i950);
totCur665 = sum(sp665.currentPerWavel*1E-3,1);  % calculate total photocurrents
totCur810 = sum(sp810.currentPerWavel*1E-3,1);
totCur850 = sum(sp850.currentPerWavel*1E-3,1);
totCur950 = sum(sp950.currentPerWavel*1E-3,1);
% 
% cent665 = sum(cur665 .* repmat(wavel,1,i665),1)./ totCur665;    % calculate centroids
% cent810 = sum(cur810 .* repmat(wavel,1,i810),1)./ totCur810;
% cent850 = sum(cur850 .* repmat(wavel,1,i850),1)./ totCur850;
% cent950 = sum(cur950 .* repmat(wavel,1,i950),1)./ totCur950;
meanCent665 = mean([sp665.centWavel]);
meanCent810 = mean([sp810.centWavel]);
meanCent850 = mean([sp850.centWavel]);
meanCent950 = mean([sp950.centWavel]);

%% Display results

fprintf('Mean power of 665 LED = %.2f mW\n', mean([sp665.totPower*1E-3]));
fprintf('Max. power of 665 LED = %.2f mW\n', max([sp665.totPower*1E-3]));
fprintf('Min. power of 665 LED = %.2f mW\n\n', min([sp665.totPower*1E-3]));

fprintf('Mean power of 810 LED = %.2f mW\n', mean([sp810.totPower*1E-3]));
fprintf('Max. power of 810 LED = %.2f mW\n', max([sp810.totPower*1E-3]));
fprintf('Min. power of 810 LED = %.2f mW\n\n', min([sp810.totPower*1E-3]));

fprintf('Mean power of 850 LED = %.2f mW\n', mean([sp850.totPower*1E-3]));
fprintf('Max. power of 850 LED = %.2f mW\n', max([sp850.totPower*1E-3]));
fprintf('Min. power of 850 LED = %.2f mW\n\n', min([sp850.totPower*1E-3]));

fprintf('Mean power of 950 LED = %.2f mW\n', mean([sp950.totPower*1E-3]));
fprintf('Max. power of 950 LED = %.2f mW\n', max([sp950.totPower*1E-3]));
fprintf('Min. power of 950 LED = %.2f mW\n\n', min([sp950.totPower*1E-3]));

fprintf('Mean centroid of 665 LED = %.2f nm\n', meanCent665);
fprintf('Mean centroid of 810 LED = %.2f nm\n', meanCent810);
fprintf('Mean centroid of 850 LED = %.2f nm\n', meanCent850);
fprintf('Mean centroid of 950 LED = %.2f nm\n', meanCent950);

fprintf('Mean photocurrent of 665 LED = %.2f mA\n', mean(totCur665));
fprintf('Mean photocurrent of 810 LED = %.2f mA\n', mean(totCur810));
fprintf('Mean photocurrent of 850 LED = %.2f mA\n', mean(totCur850));
fprintf('Mean photocurrent of 950 LED = %.2f mA\n', mean(totCur950));

fprintf('Min. photocurrent of 665 LED = %.2f mA\n', min(totCur665));
fprintf('Min. photocurrent of 810 LED = %.2f mA\n', min(totCur810));
fprintf('Min. photocurrent of 850 LED = %.2f mA\n', min(totCur850));
fprintf('Min. photocurrent of 950 LED = %.2f mA\n', min(totCur950));

table665 = table(sp665.peakWavel', sp665.centWavel', sp665.fwhm', (sp665.totPower/1000)', 'VariableNames', {'Peak_Wavel', 'Cent_Wavel', 'FWHM', 'Total_Power'})
table810 = table(sp810.peakWavel', sp810.centWavel', sp810.fwhm', (sp810.totPower/1000)', 'VariableNames', {'Peak_Wavel', 'Cent_Wavel', 'FWHM', 'Total_Power'})
table850 = table(sp850.peakWavel', sp850.centWavel', sp850.fwhm', (sp850.totPower/1000)', 'VariableNames', {'Peak_Wavel', 'Cent_Wavel', 'FWHM', 'Total_Power'})
table950 = table(sp950.peakWavel', sp950.centWavel', sp950.fwhm', (sp950.totPower/1000)', 'VariableNames', {'Peak_Wavel', 'Cent_Wavel', 'FWHM', 'Total_Power'})

figure(1)
subplot(2,2,1)
plot(wavel, irr665)
grid
xlabel('wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('Irradiance (uW/nm/cm^2)', 'FontSize', FONTSIZE)
title([num2str(i665) ' scans of 665 LED'], 'FontSize', FONTSIZE)
axis([wavel(1) wavel(end) 0 max(irr665(:))])
%axis([min(wavel(:)) max(wavel(:)) 0 12000]);
subplot(2,2,2)
plot(wavel, irr810)
grid
xlabel('wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('Irradiance (uW/nm/cm^2)', 'FontSize', FONTSIZE)
title([num2str(i810) ' scans of 810 LED'], 'FontSize', FONTSIZE)
axis([wavel(1) wavel(end) 0 max(irr665(:))])
%axis([min(wavel(:)) max(wavel(:)) 0 12000]);
subplot(2,2,3)
plot(wavel, irr850)
grid
xlabel('wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('Irradiance (uW/nm/cm^2)', 'FontSize', FONTSIZE)
title([num2str(i850) ' scans of 850 LED'], 'FontSize', FONTSIZE)
axis([wavel(1) wavel(end) 0 max(irr665(:))])
%axis([min(wavel(:)) max(wavel(:)) 0 12000]);
subplot(2,2,4)
plot(wavel, irr950)
grid
xlabel('wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('Irradiance (uW/nm/cm^2)', 'FontSize', FONTSIZE)
title([num2str(i950) ' scans of 950 LED'], 'FontSize', FONTSIZE)
axis([wavel(1) wavel(end) 0 max(irr665(:))])
%axis([min(wavel(:)) max(wavel(:)) 0 12000]);

figure(2)
plot(wavel, mean(sp665.currentPerWavel,2), 'r')
hold on
plot(wavel, mean(sp810.currentPerWavel,2), 'g')
plot(wavel, mean(sp850.currentPerWavel,2), 'k')
plot(wavel, mean(sp950.currentPerWavel,2), 'b')
grid
xlabel('wavelength (nm)', 'FontSize', FONTSIZE)
ylabel('Photocurrent (mA)', 'FontSize', FONTSIZE)
title('Mean LED spectra weighted by PD responsivity, 50mA drive', 'FontSize', FONTSIZE)
legend(num2str(meanCent665),num2str(meanCent810),num2str(meanCent850),num2str(meanCent950));
hold off
axis tight
