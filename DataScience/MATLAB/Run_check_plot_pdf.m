% Run_check_plot
orient landscape
FONTSIZE = 11;  % size of fonts used in plots
LEDlabels = cellstr(num2str(leds'));

figure
%set(gcf, 'Position', [636 0 791 874]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(2,1,1);
semilogy(time, currents256(sweep.ccode15+1), 'linewidth', 2)
grid
axis([0 time(end) currents(1) currents(end)])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('current (Amps)','FontSize', FONTSIZE)
title('Currents @ 15mm','FontSize', FONTSIZE)
legend(LEDlabels)
ax(2) = subplot(2,1,2);
semilogy(time, sweep.count15)
grid
axis([0 time(end) 100 2^15-1])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Counts @ 15mm','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure
% set(gcf, 'Position', [636 0 791 874]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(2,1,1);
semilogy(time, currents256(sweep.ccode27+1), 'linewidth', 2)
grid
axis([0 time(end) currents(1) currents(end)])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('current (Amps)','FontSize', FONTSIZE)
title('Currents @ 27mm','FontSize', FONTSIZE)
legend(LEDlabels)
ax(2) = subplot(2,1,2);
semilogy(time, sweep.count27)
grid
axis([0 time(end) 100 2^15-1])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Counts @ 27mm','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure  % Ambient light
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
plot(time, sweep.ambient)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('ADC counts','FontSize', FONTSIZE)
title('Ambient light','FontSize', FONTSIZE)

figure  % ODs
%set(gcf, 'Position', [636 0 791 1025]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(3,1,1);
plot(time, OD15)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('ODs @ 15mm','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')))
ax(2) = subplot(3,1,2);
plot(time, OD27)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('ODs @ 27mm','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
ax(3) = subplot(3,1,3);
plot(time, ODDiff)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('OD','FontSize', FONTSIZE)
title('Differential OD','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')))
linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together

figure  % mu
%set(gcf, 'Position', [636 0 791 874]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
subplot(2,1,1)
plot(time, mu_eff*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{eff} (1/cm)','FontSize', FONTSIZE)
title('\mu_{eff} over time','FontSize', FONTSIZE)
%legend(cellstr(num2str(leds')), 'Location', 'Best')
subplot(2,1,2)
plot(time, mu_a*10)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('\mu_{a} (1/cm)','FontSize', FONTSIZE)
title('\mu_{a} over time','FontSize', FONTSIZE)
legend(cellstr(num2str(leds')), 'Location', 'Best')

figure   % Device SmO2, 15mm
%set(gcf, 'Position', [20 0 560 1007]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
subplot(3,1,1)
plot(time, sweep.cHbO2_15mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Device calculations - 15mm','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, sweep.cHhb_15mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, sweep.SmO2_15)
grid
axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)

figure % Device SmO2, 27mm
%set(gcf, 'Position', [20 0 560 1007]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(3,1,1);
plot(time, sweep.cHbO2_27mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Device calculations - 27mm','FontSize', FONTSIZE)
ax(2) = subplot(3,1,2);
plot(time, sweep.cHhb_27mm)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
ax(3) = subplot(3,1,3);
plot(time, sweep.SmO2_27)
grid; axis tight
%axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)
linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together

figure % SmO2, 15mm, direct method
%set(gcf, 'Position', [20 0 560 1007]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
subplot(3,1,1)
plot(time, cHb15(:,2))  % oxy
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Direct calculation - 15mm','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, cHb15(:,1))  % deoxy
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, SmO2_15)
grid; axis tight
%axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)

figure % SmO2, 27mm, direct method
%set(gcf, 'Position', [20 0 560 1007]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
subplot(3,1,1)
plot(time, cHb27(:,2))  % oxy
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HbO2]','FontSize', FONTSIZE)
title('Direct calculation - 27mm','FontSize', FONTSIZE)
subplot(3,1,2)
plot(time, cHb27(:,1))  % deoxy
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[HHb]','FontSize', FONTSIZE)
subplot(3,1,3)
plot(time, SmO2_27)
grid; axis tight
%axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)

if isfield(sweep, 'SmO2')   % display device-calculated SmO2 values, if present
    figure % Device cSmO2
    %set(gcf, 'Position', [20 0 560 1007]);
    set(gcf,'PaperOrientation','landscape');
    set(gcf,'PaperUnits','normalized');
    set(gcf,'PaperPosition', [0 0 1 1]);
    ax(1) = subplot(3,1,1);
    plot(time, sweep.cHbO2_SmO2)
    grid; axis tight
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('[HbO2]','FontSize', FONTSIZE)
    title('Device calculations - projection method','FontSize', FONTSIZE)
    ax(2) = subplot(3,1,2);
    plot(time, sweep.cHHb_SmO2)
    grid; axis tight
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('[HHb]','FontSize', FONTSIZE)
    ax(3) = subplot(3,1,3);
    plot(time, sweep.SmO2)
    grid; axis tight
    %axis ([time(1) time(end) 20 100])
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('% Saturation','FontSize', FONTSIZE)
    linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together
    
    figure
    [hAx,hLine1,hLine2] = plotyy(time, sweep.SmO2, [time' time'], [sweep.HR' sweep.PacePower']);
else
    figure
    [hAx,hLine1,hLine2] = plotyy(dec_time, ppSmO2, [time time], [sweep.HR sweep.PacePower]);
end
set(gcf, 'Position', [20 129 560 431]);
xlabel('time (s)','FontSize', FONTSIZE)
ylabel(hAx(1),'SmO_{2} (%)','FontSize', FONTSIZE) % left y-axis
if strcmp(sweep.sport,'bike')
    ylabel(hAx(2),'HR (bpm) and Power(W)', 'FontSize', FONTSIZE) % right y-axis
else
    ylabel(hAx(2),'HR (bpm) and Cadence (min/mi)', 'FontSize', FONTSIZE) % right y-axis
end
%legend('SmO_{2}', 'HR/Pace/Power', 'Location', 'Best')
grid
axis tight
set(hAx(1), 'XLim', [0 time(end)]);
set(hAx(2), 'XLim', [0 time(end)]);

fprintf('Assessment date: %s. Assessment time: %s UTC.\n', sweep.date, sweep.UTCtime)
fprintf('Device : %s Firmware version: %s\n', sweep.Device_id, sweep.FW_version)
fprintf('Assesment #: %s  Sport: %s \n', sweep.assessment, sweep.sport)
fprintf('Body part: %s \n\n', BODY_PART)

figure   % Projection SmO2
%set(gcf, 'Position', [20 0 560 1007]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(3,1,1);
plot(time, pHbO2*100)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% HbO2','FontSize', FONTSIZE)
title(['PINV (Hb&H2O) method from ' MU],'FontSize', FONTSIZE)
ax(2) = subplot(3,1,2);
plot(time, R)
grid; axis tight
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('Residual','FontSize', FONTSIZE)
title(['Residual of fit to  ' MU],'FontSize', FONTSIZE)
ax(3) = subplot(3,1,3);
%plot(time, pcSmO2*100, 'g')
%hold on
plot(dec_time, ppSmO2, 'k')
grid
axis tight
%axis ([time(1) time(end) 20 100])
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('% Saturation','FontSize', FONTSIZE)
%title([IP_METHOD ' method from ' MU],'FontSize', FONTSIZE)
title(['SmO_{2}'], 'FontSize', FONTSIZE)
%legend(IP_METHOD, 'Location', 'Best')
linkaxes([ax(1) ax(2) ax(3)], 'x');  % zoom in time together

figure   % Water and hemoglobin
%set(gcf, 'Position', [940 -56 877 774]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(3,1,1);
plot(time, pH2O,'k')
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('Hydration index','FontSize', FONTSIZE)
%title('Projected fractions','FontSize', FONTSIZE)
axis tight
grid
ax(1) = subplot(3,1,2);
% plot(time, pHhb*100,'b')
% plot(time,pSmO2*100, 'y')
% plot(time, pH2O*100,'g')
% legend('oxy', 'deoxy', '%Sat', 'water')
% hold off
% grid
% axis([0 time(end) 0 100])
plot(time, HbF, 'k')
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('Hemoglobin Index','FontSize', FONTSIZE)
axis tight
grid
subplot(3,1,3)
plot(time, HbConc, 'k')
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('Hemoglobin conc. (g/dL)','FontSize', FONTSIZE)
axis tight
grid
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together
% ax(2) = subplot(2,1,2);
% plot(time, pHbO2_27*100,'r')
% xlabel('time (s)','FontSize', FONTSIZE)
% ylabel('% projections','FontSize', FONTSIZE)
% title('Projected fractions - 27mm','FontSize', FONTSIZE)
% hold on
% plot(time, pHHb_27*100,'b')
% plot(time,pSmO2_27*100, 'y')
% plot(time, pH2O_27*100,'g')
% legend('oxy', 'deoxy', '%Sat', 'water')
% hold off
% grid
% axis([0 time(end) 20 100])

figure   % tHb
%set(gcf, 'Position', [845 0 877 774]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(2,1,1);
plot(time, HbF*1e5,'r')
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[tHb] from projection method (0.01g/dL)','FontSize', FONTSIZE)
title('Total Hb concentration calculated through different methods','FontSize', FONTSIZE)
%hold on
%legend('Projection', 'Device', 'Re-calc.')
%hold off
grid
axis tight %axis([0 time(end) 20 100])
ax(2) = subplot(2,1,2);
plot(time, sweep.tHb_15,'r')
hold on
%plot(time,tHb_15, 'g')
xlabel('time (s)','FontSize', FONTSIZE)
ylabel('[tHb]','FontSize', FONTSIZE)
plot(time, sweep.tHb_27,'b')
%plot(time,tHb_27, 'k')
legend('Direct method, 15mm', 'Direct method, 27mm')
hold off
grid
axis tight %axis([0 time(end) 20 100])
linkaxes([ax(1) ax(2)], 'x');  % zoom in time together

figure   % 
%set(gcf, 'Position', [845 0 877 774]);
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
ax(1) = subplot(4,1,1);
plot(time, sweep.cpuTemp)
%xlabel('time (s)','FontSize', FONTSIZE)
ylabel('CPU Temp. (C)','FontSize', FONTSIZE)
title(['Assessment ' sweep.assessment],'FontSize', FONTSIZE)
grid
axis tight
ax(2) = subplot(4,1,2);
plot(time, sweep.battVolt)
%xlabel('time (s)','FontSize', FONTSIZE)
ylabel('Battery charge (V)','FontSize', FONTSIZE)
grid
axis tight
ax(3) = subplot(4,1,3);
plot(time, sweep.HR)
%xlabel('time (s)','FontSize', FONTSIZE)
ylabel('Heart rate (bpm)','FontSize', FONTSIZE)
ax(4) = subplot(4,1,4);
plot(time, sweep.PacePower)
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

if isfield(sweep, 'Alert')  % plot alert bits in a B&W image, if present
    figure
    imagesc(time, [0:15], sweep.Alert')
    colormap (1-gray)
    xlabel('time (s)','FontSize', FONTSIZE)
    ylabel('Alert bits','FontSize', FONTSIZE)
    title('Alert status register', 'FontSize', FONTSIZE)
end


