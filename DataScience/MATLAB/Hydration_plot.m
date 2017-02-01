% Hydration_plot
% Script used to plot and save results from Hydration_check script.
% P. Silveira, Jan. 2015
% BSX Proprietary


%% Initializations
close all

% System parameters
[wavel leds] = getLeds; % get LED centroid and nominal wavelengths
LEDlabels = cellstr(num2str(leds'));

if ~exist('device', 'var')  % device structure may not exist, but sweep structure must
    device = getDevice(sweep.device_id);
end

FONTSIZE = 11;  % size of fonts used in plots
%SWEEP_SUFFIX = '_sweep.mat';    % suffix of .mat files with sweep structure
PPT_SUFFIX = '.ppt';    % suffix of PowerPoint files

[currents currents256] = getCurrents(device.hw_version);    % hw_version should always be defined


%% Print results

if exist('assessment', 'var')
    assessment  % display assessment info. Unfortunately, not all sweep files contain a valid assessment.
end
device  % display device info
fprintf('Assessment date: %s. Time: %s UTC. Duration (m:s): %d:%d\n', sweep.date, sweep.UTCtime, floor(sweep.time(end)/60), round(mod(sweep.time(end),60)))
fprintf('Device : %s Firmware version: %s\n', sweep.device_id, sweep.FW_version)
fprintf('Assesment #: %s  Sport: %s \n', sweep.assessment, sweep.sport)
fprintf('Body part: %s\n\n', BODY_PART)
%fprintf('Average SmO2 = %2.2f\n', process.SmO2.average);
if isfield(process.stat.SmO2, 'baseline')
    fprintf('Baseline SmO2 = %2.2f\n', process.stat.SmO2.baseline);
    fprintf('SmO2 max. = %2.2f\tmin. = %2.2f\t Delta = %2.2f\n', process.stat.SmO2.max, process.stat.SmO2.min, process.stat.SmO2.delta);
    fprintf('Baseline HR = %2.2f\n', process.stat.HR.baseline);
    fprintf('HR max. = %2.2f\tmin. = %2.2f\tDelta = %2.2f\n', process.stat.HR.max, process.stat.HR.min, process.stat.HR.delta);
    fprintf('Baseline HbF = %2.4e\tMean HbF = %2.4e\n', process.stat.HbF.baseline, process.stat.HbF.average);
    fprintf('Baseline HbConc = %2.3f\tMean HbConc = %2.3f\n', process.stat.HbConc.baseline, process.stat.HbConc.average);
    fprintf('Baseline pH2O = %2.4f\tMean pH2O = %2.4f\n', process.stat.pH2O.baseline, process.stat.pH2O.average);
    fprintf('Max. pH2O = %2.4f\tMin. pH2O = %2.4f\tDelta pH2O = %2.4f\n', process.stat.pH2O.max, process.stat.pH2O.min, process.stat.pH2O.delta);
    fprintf('Baseline tHb = %2.4f\tMean tHb = %2.4f\n', process.stat.tHb.baseline,  process.stat.tHb.average);
    fprintf('Max. tHb = %2.4f\tMin. tHb = %2.4f\tDelta tHb = %2.4f\n', process.stat.tHb.max, process.stat.tHb.min, process.stat.tHb.delta);
end

%% Plot results

figure
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
semilogy(sweep.time, currents256(sweep.ccode15+1), 'linewidth', 2)
grid
axis([0 sweep.time(end) currents256(1) currents256(end)])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('current (Amps)','FontSize', FONTSIZE)
title('Currents @ 15mm','FontSize', FONTSIZE)
legend(LEDlabels, 'Location', 'SouthWest')
ax(2) = subplot(2,1,2);
semilogy(sweep.time, sweep.count15)
grid
axis([0 sweep.time(end) 100 2^15-1])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Counts @ 15mm','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure
set(gcf, 'Position', [636 0 791 874]);
ax(1) = subplot(2,1,1);
semilogy(sweep.time, currents256(sweep.ccode27+1), 'linewidth', 2)
grid
axis([0 sweep.time(end) currents256(1) currents256(end)])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('current (Amps)','FontSize', FONTSIZE)
title('Currents @ 27mm','FontSize', FONTSIZE)
legend(LEDlabels, 'Location', 'SouthWest')
ax(2) = subplot(2,1,2);
semilogy(sweep.time, sweep.count27)
grid
axis([0 sweep.time(end) 100 2^15-1])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Counts @ 27mm','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure  % Ambient light
plot(sweep.time, sweep.ambient)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Ambient light','FontSize', FONTSIZE)

figure  % ODs
set(gcf, 'Position', [636 0 791 1025]);
ax(1) = subplot(3,1,1);

plot(sweep.time, process.OD15)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('ODs @ 15mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
ax(2) = subplot(3,1,2);

plot(sweep.time, process.OD27)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('ODs @ 27mm','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
ax(3) = subplot(3,1,3);

plot(sweep.time, process.OD27-process.OD15)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('Differential OD','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together

figure  % mu
set(gcf, 'Position', [636 0 791 874]);
subplot(2,1,1)
plot(sweep.time, process.mu_eff*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{eff} (1/cm)','FontSize', FONTSIZE)
title('\mu_{eff} over time','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')), 'Location', 'Best')
subplot(2,1,2)
plot(sweep.time, process.mu_a*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{a} (1/cm)','FontSize', FONTSIZE)
title('\mu_{a} over time','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')), 'Location', 'Best')

figure  % mu from hydration2
set(gcf, 'Position', [636 0 791 874]);
subplot(2,1,1)
plot(sweep.time, process.colip.mu_eff*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{eff} (1/cm)','FontSize', FONTSIZE)
title('\mu_{eff} incl. collagen and lipid','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')), 'Location', 'Best')
subplot(2,1,2)
plot(sweep.time, process.colip.mu_a*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{a} (1/cm)','FontSize', FONTSIZE)
title('\mu_{a} incl. collagen and lipid','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')), 'Location', 'Best')

if isfield(sweep, 'SmO2')   % display device-calculated SmO2 values, if present
    figure % Device cSmO2
    set(gcf, 'Position', [0        -139         876        1007]);
    ax(1) = subplot(3,1,1);
    plot(sweep.time, sweep.cHbO2_SmO2)
    grid; axis tight
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('[HbO2]','FontSize', FONTSIZE)
    title('Device calculations - projection method','FontSize', FONTSIZE)
    ax(2) = subplot(3,1,2);
    plot(sweep.time, sweep.cHHb_SmO2)
    grid; axis tight
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('[HHb]','FontSize', FONTSIZE)
    ax(3) = subplot(3,1,3);
    plot(sweep.time, sweep.SmO2)
    grid; axis tight
    %axis ([sweep.time(1) sweep.time(end) 20 100])
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('% Saturation','FontSize', FONTSIZE)
    linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together
    
    %     figure
    %     [hAx,hLine1,hLine2] = plotyy(sweep.time, sweep.SmO2, [sweep.time' sweep.time'], [sweep.HR' sweep.PacePower']);
    % else
    %     figure
    %     [hAx,hLine1,hLine2] = plotyy(sweep.time, process.SmO2, [sweep.time sweep.time], [sweep.HR sweep.PacePower]);
end
    % set(gcf, 'Position', [20 129 560 431]);
    % xlabel('time (s)','FontSize', FONTSIZE)
    % ylabel(hAx(1),'SmO_{2} (%)','FontSize', FONTSIZE) % left y-axis
    % if strcmp(sweep.sport,'bike')
    %     ylabel(hAx(2),'HR (bpm) and Power(W)', 'FontSize', FONTSIZE) % right y-axis
    % else
    %     ylabel(hAx(2),'HR (bpm) and Cadence (min/mi)', 'FontSize', FONTSIZE) % right y-axis
    % end
    % %legend('SmO_{2}', 'HR/Pace/Power', 'Location', 'Best')
    % grid
    % axis tight
    % set(hAx(1), 'XLim', [0 sweep.time(end)]);
    % set(hAx(2), 'XLim', [0 sweep.time(end)]);
    
    % figure   % Projection SmO2
    % set(gcf, 'Position', [0        -139         876        1007]);
    % ax(1) = subplot(3,1,1);
    %
    % plot(sweep.time, process.rawSmO2*100)
    % grid; axis tight
    % xlabel('time (s)','FontSize', FONTSIZE)
    % ylabel('raw SmO_{2} (%)','FontSize', FONTSIZE)
    % title(['PINV (Hb&H2O) method from ' MU],'FontSize', FONTSIZE)
    % ax(2) = subplot(3,1,2);
    %
    % plot(sweep.time, process.Resid)
    % grid; axis tight
    % xlabel('time (s)','FontSize', FONTSIZE)
    % ylabel('Residual','FontSize', FONTSIZE)
    % title(['Residual of fit to  ' MU],'FontSize', FONTSIZE)
    % ax(3) = subplot(3,1,3);
    % %plot(sweep.time, pcSmO2*100, 'g')
    % %hold on
    % plot(sweep.time, process.SmO2, 'k')
    % grid
    % axis tight
    % %axis ([sweep.time(1) sweep.time(end) 20 100])
    % xlabel('time (s)','FontSize', FONTSIZE)
    % ylabel('% Saturation','FontSize', FONTSIZE)
    % %title([IP_METHOD ' method from ' MU],'FontSize', FONTSIZE)
    % title(['SmO_{2} (%)'], 'FontSize', FONTSIZE)
    % %legend(IP_METHOD, 'Location', 'Best')
    % linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together
    
    mainFig = figure;   % Hydration
    set(gcf, 'Position',   [962        -188         958        1052]);
    ax(1) = subplot(4,1,1);
    plot(sweep.time, process.pH2O,'k')
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Hydration index','FontSize', FONTSIZE)
    axistight(process.pH2O)
    grid
    title('pInv, no colip')
    ax(2) = subplot(4,1,2);
    plot(sweep.time, process.pH2O_cos,'k')
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Hydration index','FontSize', FONTSIZE)
    axistight(process.pH2O_cos)
    grid
    title('Cosine method, no colip, Hb rejected')
    ax(3) = subplot(4,1,3);
    plot(sweep.time, process.pH2O_proj,'k')
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Hydration index','FontSize', FONTSIZE)
    axistight(process.pH2O_proj)
    grid
    title('Projection method, no colip, Hb rejected')
    ax(4) = subplot(4,1,4);
    plot(sweep.time, process.colip.pH2O,'k')
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Hydration index','FontSize', FONTSIZE)
    axistight(process.colip.pH2O)
    grid
    title('pInv w/ colip')
    linkaxes([ax(1) ax(2) ax(3) ax(4)], 'x');  % zoom in time together
    
    figure   % tHb
    set(gcf, 'Position', [2        -188         958        1052]);
    ax(1) = subplot(3,1,1);
    plot(sweep.time, process.tHb,'r')
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('tHb (g/dL)','FontSize', FONTSIZE)
    grid
    hold on
    plot(sweep.time, process.colip.tHb,'b')
    axistight(process.tHb);
    legend('No colip', 'Colip', 'Location', 'Best')
    ax(2) = subplot(3,1,2);
    plot(sweep.time, process.SmO2,'k')
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('SmO_{2} (%)','FontSize', FONTSIZE)
    grid
    axistight(process.SmO2,.5);
    ax(3) = subplot(3,1,3);
    plot(sweep.time, process.HbO2,'b')
    hold on
    plot(sweep.time, process.Hhb, 'r')
    grid; axis tight
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Heme conc. (mmol/L)','FontSize', FONTSIZE)
    legend('HbO2', 'Hhb', 'Location', 'Best')
    linkaxes([ax(1) ax(2) ax(3)], 'x');
    
    figure   % tHb vs SmO2
    set(gcf, 'Position', [845 0 877 774]);
    plot3(process.tHb, process.SmO2, sweep.HR)
    xlabel('tHb (g/dL)')
    ylabel('SmO2 (%)')
    grid
    
    figure   %
    set(gcf, 'Position', [845 0 877 774]);
    ax(1) = subplot(4,1,1);
    plot(sweep.time, sweep.cpuTemp)
    %xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('CPU Temp. (C)','FontSize', FONTSIZE)
    title(['Assessment ' sweep.assessment],'FontSize', FONTSIZE)
    grid
    axis tight
    ax(2) = subplot(4,1,2);
    plot(sweep.time, sweep.battVolt)
    %xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Battery charge (V)','FontSize', FONTSIZE)
    grid
    axis tight
    ax(3) = subplot(4,1,3);
    plot(sweep.time, sweep.HR)
    %xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Heart rate (bpm)','FontSize', FONTSIZE)
    ax(4) = subplot(4,1,4);
    plot(sweep.time, sweep.PacePower)
    xlabel('time (s)','FontSize', FONTSIZE)
    switch sweep.sport
        case {'Bike', 'bike', '2', 2 }
            ylabel('Power (W)','FontSize', FONTSIZE)
        otherwise
            ylabel('Pace (miles/min)','FontSize', FONTSIZE)
    end
    grid
    axis tight
    linkaxes([ax(1) ax(2) ax(3) ax(4)], 'x');  % zoom in time together
    
    if isfield(sweep, 'imu_time')
        figure
        set(gcf, 'Position', [845 0 877 774])
        ax(1) = subplot(4,1,1);
        if ~isempty(sweep.Acc_y) && ~isempty(sweep.Acc_z)
            Acc = sqrt(sweep.Acc_y.^2+sweep.Acc_z.^2);
            plot(sweep.imu_time, Acc)
            xlabel('time (s)','FontSize', FONTSIZE)
            ylabel('Total acceleration (g)','FontSize', FONTSIZE)
            grid; axis tight
            title('IMU data', 'FontSize', FONTSIZE)
        end
        ax(2) = subplot(4,1,2);
        %     plot(sweep.imu_time, sweep.Gyro_x,'b')
        %     hold on
        %     plot(sweep.imu_time, sweep.Gyro_y,'r')
        %     hold off
        %    legend ('x', 'y', 'Location', 'Best')
        if ~isempty(sweep.Gyro_x) && ~isempty(sweep.Gyro_y)
            ang_vel = sqrt(sweep.Gyro_x.^2+sweep.Gyro_y.^2);
            plot(sweep.imu_time, ang_vel,'b')
            xlabel('time (s)','FontSize', FONTSIZE)
            ylabel('Ang. velocity (deg/s)','FontSize', FONTSIZE)
            grid; axis tight
        end
        ax(3) = subplot(4,1,3);
        if ~isempty(sweep.Pace_on_dev)
            plot(sweep.imu_time, sweep.Pace_on_dev)
            xlabel('time (s)','FontSize', FONTSIZE)
            ylabel('Pace (m/s)','FontSize', FONTSIZE)
            grid; axis tight
        end
        ax(4) = subplot(4,1,4);
        plot(sweep.time, sweep.PacePower)
        xlabel('time (s)','FontSize', FONTSIZE)
        switch sweep.sport
            case {'Bike', 'bike', '2', 2 }
                ylabel('Power (W)','FontSize', FONTSIZE)
            otherwise
                ylabel('Pace (miles/min)','FontSize', FONTSIZE)
        end
        grid
        axis tight
        linkaxes([ax(1) ax(2) ax(3) ax(4)], 'x');  % zoom in time together
    else
        fprintf('No IMU data present.\n')
    end
    
    last_fig = figure;
    set(gcf, 'Position', [846 282 875 492])
    if isfield(sweep, 'Alert')  % plot alert bits in a B&W image, if present
        subplot(2,1,1)
        imagesc(sweep.time, [0:15], sweep.Alert')
        colormap (1-gray)
        xlabel('time (s)','FontSize', FONTSIZE)
        ylabel('Status bits','FontSize', FONTSIZE)
        title('Device status register', 'FontSize', FONTSIZE)
    end
    subplot(2,1,2)
    plot(sweep.time, process.tissueTF)
    grid; axis([0 sweep.time(end) 0 2])
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Tissue detection signal')
    hold on
    plot(sweep.time, process.tissue, 'r')
    legend('Tissue(T/F)?', 'Value', 'Location', 'Best')
    hold off
    
    drawnow
    
    figure(mainFig)
    figure(mainFig+1)
    
    %% Output file saving options
    
    
    if ~exist('ii', 'var') || ii == 1
        PPT_reply = questdlg('Save figures to PowerPoint file?');
    end
    if strcmp(PPT_reply,'Yes') && strcmp(fileExt,'.url')    % assessment ID selected
        new_pathname = uigetdir(FILE_PATH, 'Pick output PowerPoint file path (or Cancel)');
        if new_pathname     % only save a powerpoint if user selected a path
            txtStr = ['Assessment from server.\nAssessment number ' assessment.alpha__id '\nSport: ' assessment.sport '  User id: ' assessment.user_id '\n\nDevice number: ' sweep.device_id ' Firmware version: ' sweep.FW_version '\nAssessment Date: ' sweep.date ' Assessment Time: ' sweep.UTCtime '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART];
            if isfield(sweep, 'Is_Daily_Activity')
                txtStr = [txtStr '\nMode: Daily Activity'];
            else
                txtStr = [txtStr '\nMode: LT Assessment'];
            end
            
            saveAssessmentPPT([new_pathname '\' assessment_ID PPT_SUFFIX], txtStr, [1:last_fig]);
            %         if exist('SWEEP_SUFFIX', 'var')
            
            %             save([new_pathname '\' assessment_ID SWEEP_SUFFIX], 'sweep', 'assessment', 'device');
            %         else % save it anyway. Use a hard-coded suffix in this case.
            
            %             save([new_pathname '\' assessment_ID '_sweep.mat'], 'sweep', 'assessment', 'device');
            %         end
            
            %         %        movefile(TEMP_CSV, [new_pathname '\' assessment_ID '.csv'],'f'); % move CSV file to final destination, renaming it in the process
        end
        return  % stop here
    end
    
    % if ~strcmp(fileExt,'.mat') && exist('SWEEP_SUFFIX', 'var')   % sweep file most likely doesn't exist yet. Save it.
    %     save([pathname file SWEEP_SUFFIX], 'sweep', 'device');
    % end
    
    %if any(strcmp(fileExt, {'.bin' '.optical' '.csv' '.mat'}))  % file selected
    %     if any(strcmp(fileExt, {'.bin' '.optical'}))
    %         movefile(TEMP_CSV, [pathname '\' file '.csv'],'f'); % move CSV file to final destination, renaming it in the process
    %     end
    
    
    if strcmp(PPT_reply,'Yes')
        txtStr = ['Assessment of file ' pathname filename '\nAssessment number ' sweep.assessment '\nSport: ' sweep.sport '\n\nDevice number: ' sweep.device_id ' Firmware version: ' sweep.FW_version '\nAssessment UTC Date: ' sweep.date ' Assessment UTC Time: ' sweep.UTCtime '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART];
        if isfield(sweep, 'Is_Daily_Activity')
            txtStr = [txtStr '\nMode: Daily Activity'];
        else
            txtStr = [txtStr '\nMode: LT Assessment'];
        end
        saveAssessmentPPT([pathname file PPT_SUFFIX], txtStr, [1:last_fig]);
    end
    
