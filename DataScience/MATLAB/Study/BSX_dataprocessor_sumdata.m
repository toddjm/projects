% Calculates the mean OD trend averaged over all subjects (trials)
% All ODs normalized to zero at time when drink was given
clear all
close all

file_root = 'C:\Documents and Settings\Owner\Desktop\Consulting\BSX athletics\Hydration data\';


selected_trials = [1 2 3 4 6 7];
no_datasets_to_avg = size(selected_trials,2);

first_time_thru_loop_flag = 1;
for trial_no = selected_trials,
    %sitename = 'calf';   %Uncomment one of the sites to select
    sitename = 'pectoral';
    %sitename = 'wrist';
    %sitename = 'temple';
    trialname = strcat('Trial_',num2str(trial_no),sitename);
    filename = strcat(file_root,trialname,'.mat');
    load (filename);
    
    fillno = 31000-size(OD15,1);  %Make files the same size
    OD15_padded = padarray(OD15,[fillno,0],0,'post');
    offset_15 = mean(OD15_padded(2800:2900,:),1);
    OD15_padded_nrm(:,1) = OD15_padded(:,1)-offset_15(1);  %Normalize to zero when drink is given
    OD15_padded_nrm(:,2) = OD15_padded(:,2)-offset_15(2);
    OD15_padded_nrm(:,3) = OD15_padded(:,3)-offset_15(3);
    OD15_padded_nrm(:,4) = OD15_padded(:,4)-offset_15(4);
    
    fillno = 31000-size(OD27,1);  %Make files the same size
    OD27_padded = padarray(OD27,[fillno,0],0,'post');
    offset_27 = mean(OD27_padded(2800:2900,:),1);
    OD27_padded_nrm(:,1) = OD27_padded(:,1)-offset_27(1);  %Normalize to zero when drink is given
    OD27_padded_nrm(:,2) = OD27_padded(:,2)-offset_27(2);
    OD27_padded_nrm(:,3) = OD27_padded(:,3)-offset_27(3);
    OD27_padded_nrm(:,4) = OD27_padded(:,4)-offset_27(4);
    
    if first_time_thru_loop_flag == 1;
        OD15avg = OD15_padded_nrm;
        OD27avg = OD27_padded_nrm;
    else
OD15avg = OD15avg+OD15_padded_nrm;
OD27avg = OD27avg+OD27_padded_nrm;
    end
    first_time_thru_loop_flag = 0;
end
OD15avg = OD15avg/no_datasets_to_avg;
OD27avg = OD27avg/no_datasets_to_avg;

clear OD15;
clear OD27;

OD15 = OD15avg;
OD27 = OD27avg;

time = (1:size(OD15,1))*0.2; %Time in secs

figure(1)
subplot(221),plot(time,OD15(:,1),'r',time,OD15(:,2),'b',...
    time,OD15(:,3),'g',time,OD15(:,4),'c')
axis([0 5000 -0.075 0.1])
ylabel('Optical density change')
legend('665nm','810nm','850nm','950nm')
title(strcat('Raw \lambda; all subj data nrm+summed 15 mm',';',sitename))
subplot(222),plot(time,OD27(:,1),'r',time,OD27(:,2),'b',...
    time,OD27(:,3),'g',time,OD27(:,4),'c')
axis([0 5000 -0.075 0.1])
title('Raw \lambda data; all subj data nrm+summed 27 mm')
ODdiff_nr_far = OD27-OD15;
subplot(223),plot(time,ODdiff_nr_far(:,1),'r',time,ODdiff_nr_far(:,2),'b',...
    time,ODdiff_nr_far(:,3),'g',time,ODdiff_nr_far(:,4),'c')
xlabel('Time (s)')
ylabel('Optical density change')
axis([0 5000 -0.075 0.1])
title('Raw \lambda; all subj data nrm+summed OD27-OD15')


%% Normalized differential wavelength plots
figure(2)


subplot(221),plot(time,OD15(:,4)-OD15(:,1),'r',...
    time,OD15(:,4)-OD15(:,3),'b')
legend('950nm-665nm','950nm-850nm')
xlabel('Time (s)')
axis([0 5000 -0.04 0.1])
title('Diff \lambda; all subj data nrm+summed, 15 mm')

subplot(222),plot(time,OD27(:,4)-OD27(:,1),'r',...
    time,OD27(:,4)-OD27(:,3),'b')
legend('950nm-665nm','950nm-850nm')
xlabel('Time (s)')
axis([0 5000 -0.04 0.1])
title('Diff \lambda; all subj data nrm+summed, 27 mm')

subplot(223),plot(time,ODdiff_nr_far(:,4)-ODdiff_nr_far(:,1),'r',...
    time,ODdiff_nr_far(:,4)-ODdiff_nr_far(:,3),'b')
legend('950nm-665nm','950nm-850nm')
xlabel('Time (s)')
axis([0 5000 -0.015 0.05])
title('Diff \lambda; all subjs nrm+summed, 27-15 mm')
