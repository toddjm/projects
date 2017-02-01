% Compares SmO2 plots produced by different filters.
% To be run after Run_check
%

% Median filtering
median_SmO2 = processSmO2(pSmO2, MAP_METHOD, GAIN, MEDFILTER, DIGITS);

% Average filter
temp = isfinite(pSmO2);
index = find(temp);  % index of valid entries (not NaN)
avg_SmO2(index) = filter(ones(1,(sweep.samp_rate*15))/(sweep.samp_rate*15),1,pSmO2(temp));   %
avg_SmO2(find(~isfinite(pSmO2))) = NaN;
avg_SmO2 = processSmO2(avg_SmO2, MAP_METHOD, GAIN, 0, DIGITS);

% 3rd order Butterworth filter
butterw3_SmO2 = butterw3rd(pSmO2, sweep.samp_rate);
butterw3_SmO2 = processSmO2(butterw3_SmO2, MAP_METHOD, GAIN, 0, DIGITS);

% 2-stage Butterworth filter
butter2st_SmO2 = butterw2stage(pSmO2, sweep.samp_rate);
butter2st_SmO2 = processSmO2(butter2st_SmO2, MAP_METHOD, GAIN, 0, DIGITS);

figure(1)
set(gcf, 'Position', [970 -158 942 926])
subplot(4,1,1)
plot(time, median_SmO2)
axis tight
ax = axis;
grid
xlabel('time (s)')
ylabel('Median-filtered SmO2')
subplot(4,1,2)
plot(time, avg_SmO2)
axis tight
axis(ax);
grid
xlabel('time (s)')
ylabel('Averaged SmO2')
subplot(4,1,3)
plot(time, butterw3_SmO2)
axis tight
axis(ax);
grid
xlabel('time (s)')
ylabel('Butterworth filter')
subplot(4,1,4)
plot(time, butter2st_SmO2)
axis tight
axis(ax);
grid
xlabel('time (s)')
ylabel('2-stage Butterworth')

figure(2)
subplot(1,1,1)
set(gcf, 'Position', [10 296 942 472])
plot(time, median_SmO2)
axis tight
ax = axis;
grid
xlabel('time (s)')
ylabel('SmO2 (%)')
title('Filtered SmO2 comparison')
hold on
plot(time, avg_SmO2,'r')
plot(time, butterw3_SmO2,'k')
plot(time, butter2st_SmO2,'g')
legend('Median', 'Average', 'Butterworth', '2-stage', 'Location', 'NorthEastOutside')
hold off

%% PowerPoint saving option

[pptFileName,pptPathName] = uiputfile('*.ppt','Select PowerPoint file name to save plots','C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Research\SmO2\SmO2_filter_comparison.ppt');
if pptFileName
    if isempty(assessment_ID)   % input file selected
        saveAssessmentPPT([pptPathName pptFileName], ['Filter comparison analysis from file ' pathname filename '\nAssessment number ' sweep.assessment '\nSport: ' sweep.sport '\n\nDevice number: ' sweep.device_id ' Firmware version: ' sweep.FW_version '\nAssessment Date: ' sweep.date ' Assessment Time: ' sweep.UTCtime '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART]);
    else
        saveAssessmentPPT([pptPathName pptFileName], ['Filter comparison analysis from server assessment.\nAssessment number ' assessment.alpha__id '\nSport: ' assessment.sport '  User id: ' assessment.user_id '\n\nDevice number: ' sweep.device_id ' Firmware version: ' sweep.FW_version '\nAssessment Date: ' sweep.date ' Assessment Time: ' sweep.UTCtime '\n\nAnalysis date: ' date '. Body part analyzed: ' BODY_PART]);
      %  movefile(TEMP_CSV, [pathname '\' assessment_ID '.csv'],'f'); % move CSV file to final destination, renaming it in the process
    end
end