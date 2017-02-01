% Script Spectrum_Compare
% Compares LED spectra before and after optical adhesive application
%
% P. Silveira, Nov. 2015.

%% Initialization

close all
clear all

PRE_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Optical Adhesive characterization\No adhesive\';
POST_PATH = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\Optical Adhesive characterization\Bonded and cured\';
wl_ranges{1} = [1:167]; % range of indices corresponding to LED wavelength ranges
wl_ranges{2} = [200:427];
wl_ranges{3} = [428:539];
wl_ranges{4} = [540:793];
nom_wavel = {'665', '810', '850', '950'};   % nominal wavelength labels
Area = pi*(3900e-4/2)^2;    % area of cosine corrector (cm^2)

%% Read and plot data
%preFiles = dir([PRE_PATH '*.txt.']);    % get files from pre-modification directory
postFiles = dir([POST_PATH '*.txt.']);   % get files from poist-modification directory

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
        pre.(name).totIrr(jj) = trapz(pre.(name).irr(wl_ranges{jj}), wavel(wl_ranges{jj}))*Area;
        post.(name).totIrr(jj) = trapz(post.(name).irr(wl_ranges{jj}), wavel(wl_ranges{jj}))*Area;
        transmission(jj).(name) = post.(name).totIrr(jj) ./ pre.(name).totIrr(jj)*100;
%        annotation('textbox', [(mean(wavel(wl_ranges{jj}))-wavel(1))./(wavel(end)-wavel(1)) max([pre.(name).irr(wl_ranges{jj}) ; post.(name).irr(wl_ranges{jj})])./100 .1 .1], 'String', sprintf('%2.2f%', transmission.(name).(nom_wavel{jj})))
        text(mean(wavel(wl_ranges{jj})), max([pre.(name).irr(wl_ranges{jj}) ; post.(name).irr(wl_ranges{jj})]), sprintf('T=%2.1f', transmission(jj).(name)))
    end
 
    legend('Pre', 'Post', 'Location', 'Best')
end

%saveAssessmentPPT([POST_PATH 'Analysis_results.ppt'], 'Spectra of devices using different adhesives');

%% Processing

% avg_trans(1).name = '80050-NoPD';
% avg_trans(2).name = 'OP4036';
% avg_trans(3).name = 'Dow3145';
% avg_trans(4).name = '80050';
% avg_trans(5).name = 'OPT4200';
% avg_trans(6).name = 'OPT7020';
adhesives = {'80050-NoPD' 'OP4036' 'Dow3145' '80050' 'OPT4200' 'OPT7020'};
fl = fields(transmission);
for jj = 0:(length(fl)/4-1)
    for ii = 1:length(nom_wavel)
%        avg_trans(jj+1).wavel(ii) = mean([transmission(ii).(fl{4*jj+1}) transmission(ii).(fl{4*jj+2}) transmission(ii).(fl{4*jj+3}) transmission(ii).(fl{4*jj+4})]);
        avg_trans(jj+1,ii) = mean([transmission(ii).(fl{4*jj+1}) transmission(ii).(fl{4*jj+2}) transmission(ii).(fl{4*jj+3}) transmission(ii).(fl{4*jj+4})]);
    end
end

% for jj = 1:length(avg_trans)
%     avg_trans(jj)
% end

avg_trans


