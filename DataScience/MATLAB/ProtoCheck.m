% Script to check prototype performance

close all

LOW_LIM = 3;    % lowest count
MAX_LIM = 32000;    % maximum count
MAX_DR = 10*log10(MAX_LIM/LOW_LIM);

USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
pathname = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\'];
pathname = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Hydration\Development\Proto boards\Calibration\2016-05-27\'];

[fileName, pathname, filterind] = uigetfile([pathname '*AllOpen*.csv'], 'Select test file', 'MultiSelect', 'off');

temp = strfind(fileName, 'MB');
boardNum = fileName(temp+2:temp+3);

closedFile = dir([pathname '\*MB' boardNum '*AllClosed*.csv']);
fclosedFile = dir([pathname '*MB' boardNum '*FarClosed*.csv']);

sweep = getSweep([pathname fileName]);
closed = getSweep([pathname closedFile.name]);
fclosed = getSweep([pathname fclosedFile.name]);
len = length(sweep.count);

board_id = sweep.device_id(7:8);
switch(board_id)
    case '11'
        device.id = 'Nellie Muscle';
        device.geometry = [4.7 4.7 4.7 13.2 13.2 13.2 13.2 13.2 6.9 6.9 6.9 22.2 22.2 22.2 22.2 22.2];     % LED/PD distance (mm)
        device.wavel = {'470' '505' '630' '665' '810' '850' '950' '1020' '470' '505' '630' '665' '810' '850' '950' '1020'};     % nominal wavelengths
        device.centWavel = [470 505 630 663 803 851 940 1010 470 505 630 663 803 851 940 1010];     % centroid wavelengths
    case '12'
        device.id = 'Nellie Wrist';
        device.geometry = [3.8 3.8 3.8 9.4 9.4 9.4 9.4 9.4 6 6 6 17.1 17.1 17.1 17.1 17.1];     % LED/PD distance (mm)
        device.wavel = {'470' '505' '630' '665' '810' '850' '950' '1020' '470' '505' '630' '665' '810' '850' '950' '1020'};     % nominal wavelengths
        device.centWavel = [470 505 630 663 803 851 940 1010 470 505 630 663 803 851 940 1010];     % centroid wavelengths
    case '21'
        device.id = 'Calypso Muscle';
        device.geometry = [8 8 8 8 8 13.5 13.5 13.5 13.5 13.5 22.2 22.2 22.2 22.2 22.2];     % LED/PD distance (mm)
        device.wavel = {'665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020'};     % nominal wavelengths
        device.centWavel = [663 803 851 974 1010 663 803 851 974 1010 663 803 851 974 1010];     % centroid wavelengths
    case '22'
        device.id = 'Calypso Wrist';
        device.geometry = [7.3 7.3 7.3 7.3 7.3 12.5 12.5 12.5 12.5 12.5 17.7 17.7 17.7 17.7 17.7];     % LED/PD distance (mm)
        device.wavel = {'665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020'};     % nominal wavelengths
        device.centWavel = [663 803 851 974 1010 663 803 851 974 1010 663 803 851 974 1010];     % centroid wavelengths
    otherwise
        error(['Unidentified board type = ' board_id])
end

% Calypso variations
if sweep.device_id(7) == '2'
    var_id = sweep.device_id(9:10);
    switch(var_id)
        case '01' % nominal. No change
        case '02' % variation 1
            device.wavel([4,9,14]) = {'950'};
            device.centWavel([4,9,14]) = 940;
        case '03' % variation 2
            device.wavel([5,10,15]) = {'1050'};
            device.centWavel([5,10,15]) = 1045;
        case '04'  % variation 3
            device.wavel([4,9,14]) = {'950'};
            device.centWavel([4,9,14]) = 940;
            device.wavel([5,10,15]) = {'1050'};
            device.centWavel([5,10,15]) = 1045;
        case '05'   % variation 4
            %        nom_wavel = input('Calypso variation 4: Enter additional nominal wavelength: ', 's');
            %        cent_wavel = input('Enter centroid wavelength: ');
            device.wavel([4,9,14]) = {'960'};
            device.centWavel([4,9,14]) = 952;
            device.wavel([5,10,15]) = {'1050'}; %nom_wavel;
            device.centWavel([5,10,15]) = 1045; %cent_wavel;
        otherwise
            error(['Unidentified Calypso variation = ' var_id])
    end
end


sweep.count(sweep.count < LOW_LIM) = NaN;
sweep.count(sweep.count>MAX_LIM) = NaN;
closed.count(closed.count < LOW_LIM) = LOW_LIM;
% closed.count(closed.count>32000) = NaN;
fclosed.count(fclosed.count < LOW_LIM) = LOW_LIM;
% fclosed.count(fclosed.count>32000) = NaN;

%% Plot results

sampX = [round(len/4) round(3*len/4)];  % horizontal axis

if strfind(device.id, 'Nellie')
    ledVisNear = [1:3];
    ledNIRNear = [4:8];
    ledVisFar = [9:11];
    ledNIRFar = [12:16];
    
    figure
    set(gcf, 'Position', [932 -308 958 927])
    subplot(2,1,1)
    plot(10*log10(abs(sweep.count(:,ledVisFar) ./ closed.count(:,ledVisFar))))
    ylabel('Count ratio (dB)')
    title(['Nellie MB' boardNum ' Far - Far blocked'])
    grid
    ylim([0 40])
    xlim(sampX)
    legend(device.wavel(ledVisFar))
    subplot(2,1,2)
    plot(10*log10(abs(sweep.count(:,ledNIRFar) ./ closed.count(:,ledNIRFar))))
    xlabel('Samples')
    ylabel('Count ratio (dB)')
    %title('Far blocked')
    legend(device.wavel(ledNIRFar))
    ylim([0 MAX_DR])
    xlim(sampX)
    grid
    
    figure
    set(gcf, 'Position', [58 -273 1805 885])
    subplot(2,2,1)
    plot(10*log10(abs(sweep.count(:,ledVisNear) ./ closed.count(:,ledVisNear))))
    ylabel('Count ratio (dB)')
    title(['Nellie MB' boardNum ' Near - All blocked'])
    grid
    ylim([0 MAX_DR])
    xlim(sampX)
    legend(device.wavel(ledVisNear))
    subplot(2,2,3)
    plot(10*log10(abs(sweep.count(:,ledNIRNear) ./ closed.count(:,ledNIRNear))))
    xlabel('Samples')
    ylabel('Count ratio (dB)')
    %title('Far blocked')
    legend(device.wavel(ledNIRNear))
    ylim([0 MAX_DR])
    xlim(sampX)
    grid
    subplot(2,2,2)
    plot(10*log10(abs(sweep.count(:,ledVisFar) ./ closed.count(:,ledVisFar))))
    ylabel('Count ratio (dB)')
    title(['Nellie MB' boardNum ' Far - All blocked'])
    grid
    ylim([0 MAX_DR])
    xlim(sampX)
    legend(device.wavel(ledVisFar))
    subplot(2,2,4)
    plot(10*log10(abs(sweep.count(:,ledNIRFar) ./ closed.count(:,ledNIRFar))))
    xlabel('Samples')
    ylabel('Count ratio (dB)')
    %title('Far blocked')
    legend(device.wavel(ledNIRFar))
    ylim([0 MAX_DR])
    xlim(sampX)
    grid
    
    figure
    set(gcf, 'Position', [58 -273 1805 885])
    subplot(2,2,1)
    plot(sweep.count(:,ledVisNear))
    axis tight
    xlim(sampX)
    grid
    title(['Nellie MB' boardNum ' Near'])
    ylabel('Counts')
    legend(device.wavel(ledVisNear))
    subplot(2,2,3)
    plot(sweep.count(:,ledVisFar))
    axis tight
    xlim(sampX)
    grid
    xlabel('Samples')
    legend(device.wavel(ledVisFar))
    subplot(2,2,2)
    plot(sweep.count(:,ledNIRNear))
    axis tight
    xlim(sampX)
    grid
    title(['Nellie MB' boardNum ' Far'])
    ylabel('Counts')
    legend(device.wavel(ledNIRNear))
    subplot(2,2,4)
    plot(sweep.count(:,ledNIRFar))
    axis tight
    xlim(sampX)
    grid
    xlabel('Samples')
    ylabel('Counts')
    legend(device.wavel(ledNIRFar))
    
else
    ledNear = [1:5];
    ledMid = [6:10];
    ledFar = [11:15];
    
    figure
    set(gcf, 'Position', [932 -308 958 927])
    plot(10*log10(abs(sweep.count(:,ledFar) ./ closed.count(:,ledFar))))
    ylabel('Count ratio (dB)')
    xlabel('Samples')
    title(['Calypso MB' boardNum ' Far - Far blocked'])
    grid
    ylim([0 MAX_DR])
    xlim(sampX)
    legend(device.wavel(ledFar))
    
    figure
    set(gcf, 'Position', [598 -294 1276 883])
    subplot(3,1,1)
    plot(10*log10(abs(sweep.count(:,ledNear) ./ closed.count(:,ledNear))))
    ylabel('Count ratio (dB)')
    title(['Calypso MB' boardNum ' Near - All blocked'])
    grid
    ylim([0 MAX_DR])
    xlim(sampX)
    legend(device.wavel(ledNear))
    subplot(3,1,2)
    plot(10*log10(abs(sweep.count(:,ledMid) ./ closed.count(:,ledMid))))
    ylabel('Count ratio (dB)')
    title(['Calypso MB' boardNum ' Mid - All blocked'])
    grid
    ylim([0 MAX_DR])
    xlim(sampX)
    legend(device.wavel(ledFar))
    subplot(3,1,3)
    plot(10*log10(abs(sweep.count(:,ledFar) ./ closed.count(:,ledFar))))
    ylabel('Count ratio (dB)')
    title(['Calypso MB' boardNum ' Far - All blocked'])
    grid
    ylim([0 MAX_DR])
    xlim(sampX)
    legend(device.wavel(ledFar))
    
    figure
    set(gcf, 'Position', [58 -273 1805 885])
    subplot(3,1,1)
    plot(sweep.count(:,ledNear))
    axis tight
    xlim(sampX)
    grid
    title(['Calypso MB' boardNum ' Near'])
    ylabel('Counts')
    legend(device.wavel(ledNear))
    subplot(3,1,2)
    plot(sweep.count(:,ledMid))
    title(['Calypso MB' boardNum ' Mid'])
    
    axis tight
    xlim(sampX)
    ylabel('Counts')
    grid
    legend(device.wavel(ledMid))
    subplot(3,1,3)
    plot(sweep.count(:,ledFar))
    title(['Calypso MB' boardNum ' Far'])
    axis tight
    xlim(sampX)
    grid
    ylabel('Counts')
    xlabel('Samples')
    legend(device.wavel(ledFar))
    
    figure
    set(gcf, 'Position', [58 -273 1805 885])
    subplot(3,1,1)
    plot(sweep.count(:,ledNear))
    axis tight
    xlim(sampX)
    grid
    title(['Calypso MB' boardNum ' Near'])
    ylabel('Counts')
    legend(device.wavel(ledNear))
    subplot(3,1,2)
    plot(sweep.count(:,ledMid))
    title(['Calypso MB' boardNum ' Mid'])
    
end

