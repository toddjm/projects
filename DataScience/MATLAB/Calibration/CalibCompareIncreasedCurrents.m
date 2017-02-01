% Script used to compare AllCnt calibration table from units modified for
% increased current, before and after burn-in test
%
% P. Silveira, July 2015

%% Initialize
clear
close all

[ MAX_PASS, MIN_PASS, MuEffNom, MuError, MuEffTol, RMSErrorMAX ] = calibPassFail;
[wavel, leds] = getLeds;
FONTSIZE = 12;  % size of font used in plots
currents = getCurrents;

%% Get data
C_old = getAllCnt(getDevice('0CEFAF8106DC') ,2);
C_new = getAllCnt(getDevice('0CEFAF8106DC') ,1);
B_old = getAllCnt(getDevice('0CEFAF8106DD') ,2);
B_new = getAllCnt(getDevice('0CEFAF8106DD') ,1);
A_old = getAllCnt(getDevice('0cefaf8106e1') ,2);
A_new = getAllCnt(getDevice('0cefaf8106e1') ,1);

%% Process data
A_old_maxCnt = A_old(end,:);
A_new_maxCnt = A_new(end,:);
B_old_maxCnt = B_old(end,:);
B_new_maxCnt = B_new(end,:);
C_old_maxCnt = C_old(end,:);
C_new_maxCnt = C_new(end,:);

delta_C = C_old - C_new;
delta_B = B_old - B_new;
delta_A = A_old - A_new;

%% Display results
fprintf('RMS of calibration difference in unit A = %f\n', rms(delta_A(:)))
fprintf('RMS of calibration difference in unit B = %f\n', rms(delta_B(:)))
fprintf('RMS of calibration difference in unit C = %f\n', rms(delta_C(:)))


figure(1); clf
set(gcf, 'Position', [16 340 560 420]);
plot(A_old_maxCnt,'b')
hold on
plot(A_new_maxCnt,'g')
plot(MAX_PASS,'r')
plot(MIN_PASS,'r')
hold off
grid
xlabel('LED', 'FontSize', FONTSIZE)
ylabel('Counts/Transmission', 'FontSize', FONTSIZE)
title(['MaxAllCnt of device A'], 'Fontsize', FONTSIZE)
legend('Pre', 'Post', 'Tolerances', 'Location', 'Best')

figure(2); clf
set(gcf, 'Position', [595 341 560 420]);
surf([1:2*numel(leds)], currents, double(delta_A))
xlabel('LEDs')
ylabel('Currents (Amp)')
xlabel('Counts')
title('Delta of AllCnt matrix, device A')
axis tight

figure(3); clf
set(gcf, 'Position', [16 340 560 420]);
plot(B_old_maxCnt,'b')
hold on
plot(B_new_maxCnt,'g')
plot(MAX_PASS,'r')
plot(MIN_PASS,'r')
hold off
grid
xlabel('LED', 'FontSize', FONTSIZE)
ylabel('Counts/Transmission', 'FontSize', FONTSIZE)
title(['MaxAllCnt of device B'], 'Fontsize', FONTSIZE)
legend('Pre', 'Post', 'Tolerances', 'Location', 'Best')

figure(4); clf
set(gcf, 'Position', [595 341 560 420]);
surf([1:2*numel(leds)], currents, double(delta_B))
xlabel('LEDs')
ylabel('Currents (Amp)')
xlabel('Counts')
title('Delta of AllCnt matrix, device B')
axis tight

figure(5); clf
set(gcf, 'Position', [16 340 560 420]);
plot(C_old_maxCnt,'b')
hold on
plot(C_new_maxCnt,'g')
plot(MAX_PASS,'r')
plot(MIN_PASS,'r')
hold off
grid
xlabel('LED', 'FontSize', FONTSIZE)
ylabel('Counts/Transmission', 'FontSize', FONTSIZE)
title(['MaxAllCnt of device C'], 'Fontsize', FONTSIZE)
legend('Pre', 'Post', 'Tolerances', 'Location', 'Best')

figure(6); clf
set(gcf, 'Position', [595 341 560 420]);
surf([1:2*numel(leds)], currents, double(delta_C))
xlabel('LEDs')
ylabel('Currents (Amp)')
xlabel('Counts')
title('Delta of AllCnt matrix, device C')
axis tight


reply = questdlg('Save figures to PowerPoint file?');
if strcmp(reply,'Yes')
    saveAssessmentPPT([pwd '\' 'Calibration_comparison.ppt'], 'Comparison of calibration of devices before and after burn-in test.\n');
end
