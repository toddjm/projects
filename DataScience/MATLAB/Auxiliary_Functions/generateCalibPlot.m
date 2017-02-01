function generateCalibPlot(sweep, process)
% function generateCalibPlot(sweep, process)
%
% Function used to generate plots summarizing assessment results.
%
% Inputs
% sweep - sweep structure obtained from getSweep
% process - structured with sweep processing results
% 
% P. Silveira, June 2015
% BSX Proprietary

[temp leds] = getLeds;
ZOOM = [10:70]*sweep.samp_rate; % range of indices over which to zoom plots

% % August 2015
% subplot(2,3,1)
% semilogy(sweep.time, sweep.count15)
% grid; axis tight
% xlabel('time (s)')
% ylabel('15mm counts')
% subplot(2,3,4)
% semilogy(sweep.time, sweep.count27)
% grid; axis tight
% xlabel('time (s)')
% ylabel('27mm counts') 
% subplot(2,3,3)
% [hAx,hLine1,hLine2] = plotyy(sweep.time, SmO2, [sweep.time sweep.time], [sweep.HR sweep.PacePower]);
% xlabel('time (s)')
% ylabel(hAx(1),'SmO_{2} (%)') % left y-axis
% if strcmp(sweep.sport,'bike')
%     ylabel(hAx(2),'HR (bpm) and Power(W)') % right y-axis
% else
%     ylabel(hAx(2),'HR (bpm) and Cadence (min/mi)') % right y-axis
% end
% %legend('SmO_{2}', 'HR/Pace/Power', 'Location', 'Best')
% grid
% axis tight
% set(hAx(1), 'XLim', [0 sweep.time(end)]);
% set(hAx(2), 'XLim', [0 sweep.time(end)]);
% subplot(2,3,2)
% plot(sweep.time, sweep.ambient)
% grid; axis tight
% xlabel('time (s)')
% ylabel('Ambient (counts)') 
% subplot(2,3,5)
% plot(sweep.time, HbF*1e5)
% grid; axis tight
% xlabel('time (s)')
% ylabel('Total hemog. (g/dL)')
% subplot(2,3,6)
% plot(sweep.time, pH2O)
% grid; axis tight
% xlabel('time (s)')
% ylabel('Water conc.')

% Plot used for legacy calibration assessments, August 2015
subplot(2,3,2)
semilogy(sweep.time, sweep.count15)
grid; axis tight
xlabel('time (s)')
ylabel('15mm counts')
subplot(2,3,5)
semilogy(sweep.time, sweep.count27)
grid; axis tight
xlabel('time (s)')
ylabel('27mm counts') 
subplot(2,3,6)
plot(sweep.time, sweep.ambient)
legend(leds')
grid; axis tight
xlabel('time (s)')
ylabel('Ambient light (counts)')  
subplot(2,3,3)
[hAx,hLine1,hLine2] = plotyy(sweep.time, sweep.HR, sweep.time, sweep.PacePower);
xlabel('time (s)')
ylabel(hAx(1),'HR (bpm)') % left y-axis
if strcmp(sweep.sport,'bike')
    ylabel(hAx(2),'Power(W)') % right y-axis
else
    ylabel(hAx(2),'Cadence (min/mi)') % right y-axis
end
grid
axis tight
set(hAx(1), 'XLim', [0 sweep.time(end)]);
set(hAx(2), 'XLim', [0 sweep.time(end)]);
subplot(2,3,4)
plot(sweep.time(ZOOM), process.ppSmO2(ZOOM))
text(20, double(process.baselineSmO2), num2str(process.baselineSmO2),'Color', [1 0 0]);
line([20 40], [process.baselineSmO2 process.baselineSmO2], 'LineStyle', '-.', 'Color', [0 1 0])
grid; axis tight
xlabel('time (s)')
ylabel('SmO_{2} (%)')
subplot(2,3,1)
plot(sweep.time, process.ppSmO2)
grid; axis tight
xlabel('time (s)')
ylabel('SmO_{2} (%)')
text(0, double(process.baselineSmO2), num2str(process.baselineSmO2),'Color', [1 0 0]);
text(double(sweep.time(end)*2/3), double(process.exhaustionSmO2), num2str(process.exhaustionSmO2), 'Color', [1 0 0]);

% subplot(2,3,6)
% plot(sweep.time, process.tissueTF)
% grid; axis([0 sweep.time(end) 0 2])
% xlabel('time (s)')
% ylabel('Tissue detection signal')
% hold on
% plot(sweep.time, process.tissue, 'r')
% legend('Tissue T/F', 'Value', 'Location', 'Best')


 % Plot use for current evaluation, May 2015   
% subplot(2,3,1)
% plot(sweep.time, sweep.current15)
% legend(leds')
% grid; axis tight
% xlabel('time (s)')
% ylabel('15mm currents (A)')
% subplot(2,3,4)
% plot(sweep.time, sweep.count15)
% legend(leds')
% grid; axis tight
% xlabel('time (s)')
% ylabel('15mm counts')
% subplot(2,3,2)
% plot(sweep.time, sweep.current27)
% legend(leds')
% grid; axis tight
% xlabel('time (s)')
% ylabel('27mm currents (A)')
% subplot(2,3,5)
% plot(sweep.time, sweep.count27)
% legend(leds')
% grid; axis tight
% xlabel('time (s)')
% ylabel('27mm counts')
% subplot(2,3,3)
% plot(sweep.time, sweep.ambient)
% legend(leds')
% grid; axis tight
% xlabel('time (s)')
% ylabel('Ambient light (counts)')
% subplot(2,3,6)
% plot(sweep.time, SmO2)
% legend(leds')
% grid; axis tight
% xlabel('time (s)')
% ylabel('Saturation (%)')

end