% Script used to plot files processed from batchProcessADS script.
% To be called after batchProcessADS.m
%
% BSX Proprietary

close all
FONT_SIZE = 12;
MAX_SAFE_TEMP = 103.1; % 39.5deg C

if ~exist('TRIAL_PATH', 'var')
    USERPATH = getenv('USERPROFILE');
    TRIAL_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Hydration\Active dehydration\'];
    TRIAL_PATH = [uigetdir(TRIAL_PATH, 'Select trial to be processed') '\'];
end

if ~exist('NONBSX_FILE', 'var')
    NONBSX_FILE = [TRIAL_PATH 'Non-BSX Sensors.mat'];
end

if ~exist('wahoo', 'var')
    if ~exist(NONBSX_FILE, 'file')
        error('Please run batchProcessADS script first!')
    else
        load(NONBSX_FILE)   % if this crashes that's because we need to run batchProcessADS
    end
end

if exist('corTemp', 'var')
    [max_temp, maxInd] = max(corTemp.temperature(isfinite(corTemp.temperature)));
    figure
    plot(corTemp.time, corTemp.temperature)
    axis([corTemp.time(1) corTemp.time(end) 90 max([max_temp MAX_SAFE_TEMP])+1 ])
    hold on
    line([corTemp.time(1) corTemp.time(end)], [MAX_SAFE_TEMP MAX_SAFE_TEMP], 'Color', [1 0 0])
    xlabel('time (s)', 'FontSize', FONT_SIZE)
    ylabel('Core temperature (^oF)', 'FontSize', FONT_SIZE)
    title('Core temperature','FontSize', FONT_SIZE)
    plot(corTemp.time(maxInd), max_temp, 'g*')
    legend({'Core Temperature', ['Max Safe = ' num2str(MAX_SAFE_TEMP) ' ^oF'], ['Max = ' num2str(max_temp) ' ^oF']}, 'Location', 'Best')
end


fl = fields(wahoo);
for ii = 4:length(fl)
    if ~any(wahoo.(fl{ii}))  % skip fields that only contain zeros
        continue
    end
    figure
    plot(wahoo.time, wahoo.(fl{ii}))
    axis tight
    xlabel('time (s)','FontSize', FONT_SIZE)
    ylabel(strrep(fl{ii}, '_', '\_'),'FontSize', FONT_SIZE)
    title('Wahoo data','FontSize', FONT_SIZE)
end


if exist('zephyr', 'var')
    fl = fields(zephyr);
    for ii = 1:length(fl)-4
        figure
        plot(zephyr.time, zephyr.(fl{ii}))
        axis tight
        xlabel('time (s)','FontSize', FONT_SIZE)
        ylabel(strrep(fl{ii}, '_', '\_'),'FontSize', FONT_SIZE)
        title('Zephyr data','FontSize', FONT_SIZE)
    end
end

if exist('logger', 'var')
    fl = fields(logger);
    for ii = 1:length(fl)-4
        figure
        plot(logger.time, logger.(fl{ii}))
        axis tight
        xlabel('time (s)','FontSize', FONT_SIZE)
        ylabel(fl{ii},'FontSize', FONT_SIZE)
        title('Logger data','FontSize', FONT_SIZE)
    end
end




