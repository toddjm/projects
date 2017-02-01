% Script Spectrum_Compare
% Compares LED spectra before and after optical adhesive application
%
% P. Silveira, Nov. 2015.

%% Initialization

close all
clear all

USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
PRE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Optical Adhesive characterization\No adhesive\OPT7020_Verification\'];
POST_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Optical Adhesive characterization\Bonded and cured\OPT7020\'];
wl_ranges{1} = [1:167]; % range of indices corresponding to LED wavelength ranges
wl_ranges{2} = [200:427];
wl_ranges{3} = [428:539];
wl_ranges{4} = [540:793];
nom_wavel = {'665', '810', '850', '950'};   % nominal wavelength labels
Area = pi*(3900e-4/2)^2;    % area of cosine corrector (cm^2)

%% Read and plot data
postFiles = dir([POST_PATH 'Device*.txt.']);   % get files from poist-modification directory

numFiles = length(postFiles);

figure
set(gcf, 'Position', [962        -188         958        1052]);
spCount = 0;
for ii = 1:numFiles
    fname = postFiles(ii).name;
    name = fname(1:14); % using beginning of file as field name in structure
    [post.(name).irr, wavel] = readOO(fname, POST_PATH);
    [pre.(name).irr, wavel] = readOO(fname, PRE_PATH);

    spCount = spCount + 1;  % update subplot counter and create a new figure, if needed
    if spCount > 4
        figure
        set(gcf, 'Position', [962        -188         958        1052]);
        spCount = 1;
    end
    
    subplot(4, 1, spCount)
    plot(wavel, pre.(name).irr)
    hold on
    plot(wavel, post.(name).irr, 'r')
    hold off
    axis([wavel(1) wavel(wl_ranges{end}(end)) 0 85])
    xlabel('Wavelength (nm)')
    ylabel('Irradiance (\mu W/nm/cm^{2})')
    grid
    title(name, 'Interpreter', 'none')    
    
    for jj = 1:length(wl_ranges)
%         pre.(name).totIrr(jj) = trapz(pre.(name).irr(wl_ranges{jj}), wavel(wl_ranges{jj}))*Area;
%         post.(name).totIrr(jj) = trapz(post.(name).irr(wl_ranges{jj}), wavel(wl_ranges{jj}))*Area;
        pre.(name).totIrr(jj) = trapz(wavel(wl_ranges{jj}), pre.(name).irr(wl_ranges{jj}))*Area;
        post.(name).totIrr(jj) = trapz(wavel(wl_ranges{jj}), post.(name).irr(wl_ranges{jj}))*Area;
        transmission(jj).(name) = post.(name).totIrr(jj) ./ pre.(name).totIrr(jj)*100;
        text(mean(wavel(wl_ranges{jj})), max([pre.(name).irr(wl_ranges{jj}) ; post.(name).irr(wl_ranges{jj})]), sprintf('T=%2.1f', transmission(jj).(name)))
    end
 
    legend('Pre', 'Post', 'Location', 'Best')
end

%saveAssessmentPPT([POST_PATH 'Analysis_results.ppt'], 'Spectra of devices using different adhesives');

%% Processing

%adhesives = {'80050-NoPD' 'OP4036' 'Dow3145' '80050' 'OPT4200' 'OPT7020'};
adhesives = {'OPT7020'};
fl = fields(transmission);
%for jj = 0:(length(fl)/4-1)
    for ii = 1:length(nom_wavel)
        avg_trans(ii) = mean([transmission(ii).(fl{1}) transmission(ii).(fl{2}) transmission(ii).(fl{3}) transmission(ii).(fl{4})  transmission(ii).(fl{5})  transmission(ii).(fl{6}) transmission(ii).(fl{7}) transmission(ii).(fl{8})]);
    end
%end

% for jj = 1:length(avg_trans)
%     avg_trans(jj)
% end

avg_trans


