function Spectrum_Compare
% Compares LED spectra before and after resistor modification
%
% P. Silveira, June 2015.

PRE_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Insight2.0\HW_Optics\IncreasedCurrents\V&V\SpectrophotometerTest\Pre-modification';
POST_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Insight2.0\HW_Optics\IncreasedCurrents\V&V\SpectrophotometerTest\Post-modification';
range665 = [1:167]; % range of indices corresponding to LED wavelength ranges
range810 = [200:427];
range850 = [428:539];
range950 = [540:773];
nom_wavel = {'665', '810', '850', '950'};   % nominal wavelength labels
preCurrent = 50;
postCurrent = [70 100 113];

preFiles = dir([PRE_PATH '\*.txt.']);    % get files from pre-modification directory
postFiles = dir([POST_PATH '\*.txt.']);   % get files from poist-modification directory

[preIrrA, preIrrB, preIrrC] = ParseSpectrumFiles(preFiles, PRE_PATH); % get averaged irradiances
[postIrrA, postIrrB, postIrrC, wavelength] = ParseSpectrumFiles(postFiles, POST_PATH); % get averaged irradiances and wavelength

% Display results

figure(1)
plot(wavelength, preIrrA)
xlabel('Wavelength (nm)')
ylabel('Irradiance (uW/cm^2/nm)')
title('Unit A: 113mA')
hold on
plot(wavelength, postIrrA, 'r')
axis([wavelength(1,1) 1000 0 200])
grid
hold off
legend('Pre', 'Post', 'Location', 'Best')

figure(2)
plot(wavelength, preIrrB)
xlabel('Wavelength (nm)')
ylabel('Irradiance (uW/cm^2/nm)')
title('Unit B - 100mA')
hold on
plot(wavelength, postIrrB, 'r')
axis([wavelength(1,1) 1000 0 200])
grid
hold off
legend('Pre', 'Post', 'Location', 'Best')

figure(3)
plot(wavelength, preIrrC)
xlabel('Wavelength (nm)')
ylabel('Irradiance (uW/cm^2/nm)')
title('Unit C - 70mA')
hold on
plot(wavelength, postIrrC, 'r')
axis([wavelength(1,1) 1000 0 200])
grid
hold off
legend('Pre', 'Post', 'Location', 'Best')

% Find peaks, total irradiances and centroids for all units, all
% wavelengths
preA(1,1) = process_spectrum(preIrrA(range665), wavelength(range665));
preB(1,1) = process_spectrum(preIrrB(range665), wavelength(range665));
preC(1,1) = process_spectrum(preIrrC(range665), wavelength(range665));
preA(2,1) = process_spectrum(preIrrA(range810), wavelength(range810));
preB(2,1) = process_spectrum(preIrrB(range810), wavelength(range810));
preC(2,1) = process_spectrum(preIrrC(range810), wavelength(range810));
preA(3,1) = process_spectrum(preIrrA(range850), wavelength(range850));
preB(3,1) = process_spectrum(preIrrB(range850), wavelength(range850));
preC(3,1) = process_spectrum(preIrrC(range850), wavelength(range850));
preA(4,1) = process_spectrum(preIrrA(range950), wavelength(range950));
preB(4,1) = process_spectrum(preIrrB(range950), wavelength(range950));
preC(4,1) = process_spectrum(preIrrC(range950), wavelength(range950));
%[prePeakIrrA(1,1), prePeakWavelA(1,1), preTotIrrA(1,1), preCentWavelA(1,1)] = process_spectrum(preIrrA(range665), wavelength(range665));
%[prePeakIrrB(1,1), prePeakWavelB(1,1), preTotIrrB(1,1), preCentWavelB(1,1)] = process_spectrum(preIrrB(range665), wavelength(range665));
%[prePeakIrrC(1,1), prePeakWavelC(1,1), preTotIrrC(1,1), preCentWavelC(1,1)] = process_spectrum(preIrrC(range665), wavelength(range665));
%[prePeakIrrA(2,1), prePeakWavelA(2,1), preTotIrrA(2,1), preCentWavelA(2,1)] = process_spectrum(preIrrA(range810), wavelength(range810));
%[prePeakIrrB(2,1), prePeakWavelB(2,1), preTotIrrB(2,1), preCentWavelB(2,1)] = process_spectrum(preIrrB(range810), wavelength(range810));
%[prePeakIrrC(2,1), prePeakWavelC(2,1), preTotIrrC(2,1), preCentWavelC(2,1)] = process_spectrum(preIrrC(range810), wavelength(range810));
% [prePeakIrrA(3,1) prePeakWavelA(3,1) preTotIrrA(3,1) preCentWavelA(3,1)] = process_spectrum(preIrrA(range850), wavelength(range850));
% [prePeakIrrB(3,1) prePeakWavelB(3,1) preTotIrrB(3,1) preCentWavelB(3,1)] = process_spectrum(preIrrB(range850), wavelength(range850));
% [prePeakIrrC(3,1) prePeakWavelC(3,1) preTotIrrC(3,1) preCentWavelC(3,1)] = process_spectrum(preIrrC(range850), wavelength(range850));
% [prePeakIrrA(4,1), prePeakWavelA(4,1), preTotIrrA(4,1), preCentWavelA(4,1)] = process_spectrum(preIrrA(range950), wavelength(range950));
% [prePeakIrrB(4,1), prePeakWavelB(4,1), preTotIrrB(4,1), preCentWavelB(4,1)] = process_spectrum(preIrrB(range950), wavelength(range950));
% [prePeakIrrC(4,1), prePeakWavelC(4,1), preTotIrrC(4,1), preCentWavelC(4,1)] = process_spectrum(preIrrC(range950), wavelength(range950));

postA(1) = process_spectrum(postIrrA(range665), wavelength(range665));
postB(1) = process_spectrum(postIrrB(range665), wavelength(range665));
postC(1) = process_spectrum(postIrrC(range665), wavelength(range665));
postA(2) = process_spectrum(postIrrA(range810), wavelength(range810));
postB(2) = process_spectrum(postIrrB(range810), wavelength(range810));
postC(2) = process_spectrum(postIrrC(range810), wavelength(range810));
postA(3) = process_spectrum(postIrrA(range850), wavelength(range850));
postB(3) = process_spectrum(postIrrB(range850), wavelength(range850));
postC(3) = process_spectrum(postIrrC(range850), wavelength(range850));
postA(4) = process_spectrum(postIrrA(range950), wavelength(range950));
postB(4) = process_spectrum(postIrrB(range950), wavelength(range950));
postC(4) = process_spectrum(postIrrC(range950), wavelength(range950));
% [postPeakIrrA(1,1), postPeakWavelA(1,1), postTotIrrA(1,1), postCentWavelA(1,1)] = process_spectrum(postIrrA(range665), wavelength(range665));
% [postPeakIrrB(1,1), postPeakWavelB(1,1), postTotIrrB(1,1), postCentWavelB(1,1)] = process_spectrum(postIrrB(range665), wavelength(range665));
% [postPeakIrrC(1,1), postPeakWavelC(1,1), postTotIrrC(1,1), postCentWavelC(1,1)] = process_spectrum(postIrrC(range665), wavelength(range665));
% [postPeakIrrA(2,1), postPeakWavelA(2,1), postTotIrrA(2,1), postCentWavelA(2,1)] = process_spectrum(postIrrA(range810), wavelength(range810));
% [postPeakIrrB(2,1), postPeakWavelB(2,1), postTotIrrB(2,1), postCentWavelB(2,1)] = process_spectrum(postIrrB(range810), wavelength(range810));
% [postPeakIrrC(2,1), postPeakWavelC(2,1), postTotIrrC(2,1), postCentWavelC(2,1)] = process_spectrum(postIrrC(range810), wavelength(range810));
% [postPeakIrrA(3,1) postPeakWavelA(3,1) postTotIrrA(3,1) postCentWavelA(3,1)] = process_spectrum(postIrrA(range850), wavelength(range850));
% [postPeakIrrB(3,1) postPeakWavelB(3,1) postTotIrrB(3,1) postCentWavelB(3,1)] = process_spectrum(postIrrB(range850), wavelength(range850));
% [postPeakIrrC(3,1) postPeakWavelC(3,1) postTotIrrC(3,1) postCentWavelC(3,1)] = process_spectrum(postIrrC(range850), wavelength(range850));
% [postPeakIrrA(4,1), postPeakWavelA(4,1), postTotIrrA(4,1), postCentWavelA(4,1)] = process_spectrum(postIrrA(range950), wavelength(range950));
% [postPeakIrrB(4,1), postPeakWavelB(4,1), postTotIrrB(4,1), postCentWavelB(4,1)] = process_spectrum(postIrrB(range950), wavelength(range950));
% [postPeakIrrC(4,1), postPeakWavelC(4,1), postTotIrrC(4,1), postCentWavelC(4,1)] = process_spectrum(postIrrC(range950), wavelength(range950));


UnitA = struct2table(preA, 'RowNames', nom_wavel)
UnitB = struct2table(preB, 'RowNames', nom_wavel)
UnitC = struct2table(preC, 'RowNames', nom_wavel)

currentGain = postCurrent ./ preCurrent;
peakIrrGain = [[postC.peakIrr]./[preC.peakIrr] ; [postB.peakIrr]./[preB.peakIrr] ; [postA.peakIrr]./[preA.peakIrr]];
totIrrGain = [[postC.totIrr]./[preC.totIrr] ; [postB.totIrr]./[preB.totIrr] ; [postA.totIrr]./[preA.totIrr]];
peakWavelDelta = [[postC.peakWavel]-[preC.peakWavel] ; [postB.peakWavel]-[preB.peakWavel] ; [postA.peakWavel]-[preA.peakWavel]];
centWavelDelta = [[postC.centWavel]-[preC.centWavel] ; [postB.centWavel]-[preB.centWavel] ; [postA.centWavel]-[preA.centWavel]];

%table(currentGain, peakIrrGain, totIrrGain, peakWavelDelta, centWavelDelta)

    function [IrrA, IrrB, IrrC, wavelength] = ParseSpectrumFiles(files, pathn)
    % Returns spectra of units A, B and C contained in input files located at path pathn.
        
        IrrA = [];  % return empty strings if no files found
        IrrB = [];
        IrrC = [];
        a_cnt = 0;  % reset counters
        b_cnt = 0;
        c_cnt = 0;
        for ii=1:length(files)
            if strfind(files(ii).name, 'UnitA')
                a_cnt = a_cnt + 1;
                Afile{a_cnt} = files(ii).name;
            end
            if strfind(files(ii).name, 'UnitB')
                b_cnt = b_cnt + 1;
                Bfile{b_cnt} = files(ii).name;
            end
            if strfind(files(ii).name, 'UnitC')
                c_cnt = c_cnt + 1;
                Cfile{c_cnt} = files(ii).name;
            end
        end
        
        if a_cnt
            [IrrA] = readOO(Afile, pathn);  % read averaged spectra
        end
        if b_cnt
            [IrrB] = readOO(Bfile, pathn);
        end
        if c_cnt
            [IrrC, wavelength] = readOO(Cfile, pathn);
        end
        
    end

end

