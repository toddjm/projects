function generateAssessmentPlot(sweep, process)
% function generateAssessmentPlot(sweep, process)
%
% Function used to generate plots summarizing assessment results.
%
% Inputs
% sweep - sweep structure obtained from getSweep
% process - structure with calculated parameters, including
%   SmO2 - array with SmO2 values (one per time sample, percentage)
%   HbF - array with hemoglobin concontration values (one per time sample, g/dL)
%   pH2O - array with hydration index values
%   HbConc - array with hemoglobin concentration values
%   tissueTF - boolean array with tissue detection determination (true or false)
%   tissue - array with tissue detection error signal (values > 0.5
%   "generally" are non-tissue, depending on the tissue detection method
%   used).
%
% P. Silveira, June 2015
% BSX Proprietary

[temp leds] = getLeds;

% % Plots for erroneous assessments Sep. 2015
% subplot(2,3,1)
% plot(sweep.time, sweep.count15)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('15mm counts')
% subplot(2,3,4)
% plot(sweep.time, sweep.count27)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('27mm counts')
% subplot(2,3,2)
% plot(sweep.time, sweep.ambient)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('Ambient light (counts)')
% subplot(2,3,5)
% if exist('process', 'var')
%     plot(sweep.time, process.tissueTF)
%     grid; axis([0 sweep.time(end) 0 2])
%     xlabel('time (s)')
%     ylabel('Tissue detection signal')
%     hold on
%     plot(sweep.time, process.tissue, 'r')
%     %legend('Tissue(T/F)?', 'Value', 'Location', 'Best')
%     hold off
%     subplot(2,3,3)
%     [hAx,hLine1,hLine2] = plotyy(sweep.time, process.HbF, sweep.time, process.pH2O);
%     xlabel('time (s)')
%     ylabel(hAx(1),'HbF') % left y-axis
%     ylabel(hAx(2),'pH2O') % right y-axis
%     grid
%     axis tight
%     set(hAx(1), 'XLim', [0 sweep.time(end)]);
%     set(hAx(2), 'XLim', [0 sweep.time(end)]);
% end
% subplot(2,3,6)
% if exist('process', 'var')
%     SmO2 = process.SmO2;
% elseif isfield(sweep, 'SmO2')
%     SmO2 = sweep.SmO2;
% end
% [hAx,hLine1,hLine2] = plotyy(sweep.time, SmO2, [sweep.time sweep.time], [sweep.HR sweep.PacePower]);
% xlabel('time (s)')
% ylabel(hAx(1),'SmO_{2} (%)') % left y-axis
% if strcmp(sweep.sport,'bike')
%     ylabel(hAx(2),'HR (bpm) and Power(W)') % right y-axis
% else
%     ylabel(hAx(2),'HR (bpm) and Cadence (min/mi)') % right y-axis
% end
% grid; axis tight
% set(hAx(1), 'XLim', [0 sweep.time(end)]);
% set(hAx(2), 'XLim', [0 sweep.time(end)]);

if isfield(sweep, 'HR') && any(isfinite(sweep.HR))
    HR = sweep.HR;
else
    HR = process.HR;
end

% Plot used for HR and total hemoblogin evaluation, August 2015
subplot(2,3,1)
plot(sweep.time, process.OD15)
legend(leds, 'Location', 'Best')
grid; axis tight
xlabel('time (s)')
ylabel('OD @ 15mm')
subplot(2,3,4)
plot(sweep.time, process.OD27)
%legend(leds)
grid; axis tight
xlabel('time (s)')
ylabel('OD @ 27mm')
subplot(2,3,2)
if isfield(process, 'Gyro')
    [hAx,hLine1,hLine2] = plotyy(sweep.time, process.Gyro, sweep.time, sweep.ambient);
    xlabel('time (s)')
    ylabel(hAx(1),'Ang. vel. mag. (deg/s)') % left y-axis
    ylabel(hAx(2), 'Ambient light (counts)') % right y-axis
    grid
    axis tight
    set(hAx(1), 'XLim', [sweep.time(1) sweep.time(end)]);
    set(hAx(2), 'XLim', [sweep.time(1) sweep.time(end)]);
else
    plot(sweep.time, sweep.ambient)
    grid; axis tight
    xlabel('time (s)')
    ylabel('Ambient light (counts)')
end
subplot(2,3,3)
if exist('process', 'var')
    SmO2 = process.SmO2;
elseif isfield(sweep, 'SmO2')
    SmO2 = sweep.SmO2;
else
    SmO2 = [];
end
[hAx,hLine1,hLine2] = plotyy(sweep.time, SmO2, [sweep.time sweep.time], [HR(:) sweep.PacePower]);
xlabel('time (s)')
ylabel(hAx(1),'SmO_{2} (%)') % left y-axis
if strcmp(sweep.sport,'bike')
    ylabel(hAx(2),'HR (bpm) and Power(W)') % right y-axis
else
    ylabel(hAx(2),'HR (bpm) and Cadence (min/mi)') % right y-axis
end
%legend('SmO_{2}', 'HR/Pace/Power', 'Location', 'Best')
grid
axis tight
set(hAx(1), 'XLim', [sweep.time(1) sweep.time(end)]);
set(hAx(2), 'XLim', [sweep.time(1) sweep.time(end)]);
subplot(2,3,6)
[hAx,hLine1,hLine2] = plotyy(sweep.time, process.tissueTF, sweep.time, process.pH2O);
xlabel('time (s)')
ylabel(hAx(1),'tissue (T/F)') % left y-axis
ylabel(hAx(2),'pH2O') % right y-axis
grid
axis tight
set(hAx(1), 'XLim', [sweep.time(1) sweep.time(end)]);
set(hAx(1), 'YLim', [0 2]);
set(hAx(2), 'XLim', [sweep.time(1) sweep.time(end)]);
subplot(2,3,5)
plot(sweep.time, process.tHb)
grid; axis tight
xlabel('time (s)')
ylabel('tHb (g/dL)')

% Plot use for current evaluation, May 2015
% subplot(2,3,1)
% plot(sweep.time, sweep.current15)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('15mm currents (A)')
% subplot(2,3,4)
% plot(sweep.time, sweep.count15)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('15mm counts')
% subplot(2,3,2)
% plot(sweep.time, sweep.current27)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('27mm currents (A)')
% subplot(2,3,5)
% plot(sweep.time, sweep.count27)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('27mm counts')
% subplot(2,3,3)
% plot(sweep.time, sweep.ambient)
% legend(leds)
% grid; axis tight
% xlabel('time (s)')
% ylabel('Ambient light (counts)')
% subplot(2,3,6)
% [hAx,hLine1,hLine2] = plotyy(sweep.time, process.SmO2, [sweep.time sweep.time], [sweep.HR sweep.PacePower]);
% xlabel('time (s)')
% ylabel(hAx(1),'SmO_{2} (%)') % left y-axis
% if strcmp(sweep.sport,'bike')
%     ylabel(hAx(2),'HR (bpm) and Power(W)') % right y-axis
% else
%     ylabel(hAx(2),'HR (bpm) and Cadence (min/mi)') % right y-axis
% end
% grid; axis tight
% set(hAx(1), 'XLim', [0 sweep.time(end)]);
% set(hAx(2), 'XLim', [0 sweep.time(end)]);

end