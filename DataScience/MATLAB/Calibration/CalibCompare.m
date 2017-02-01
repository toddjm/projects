% Script used to compare AllCnt calibration table from a list of units
%
% P. Silveira, Sep. 2015

%% Initialize
clear
close all

%HW_VERSION = '194';
SAVE_PDF = false;   % Flag for saving individual PDF results
DATE_FORMAT = 'yyyymmdd';    % formate of date string

[wavel, leds] = getLeds;
FONTSIZE = 12;  % size of font used in plots
% list of devices to be inlcuded. First device on list determines HW_VERSION to be used when setting MIN and MAX pass/fail and currents.
%DEVICE_LIST = {'0CEFAF81096B' '0CEFAF810986' '0CEFAF810970' '0CEFAF81097C' '0CEFAF810984' '0CEFAF810980' '0CEFAF81097A' '0CEFAF81096E' '0CEFAF810983' '0CEFAF810973' '0CEFAF81097B' '0CEFAF8109AD' '0CEFAF810991' '0CEFAF810992' '0CEFAF81099D' '0CEFAF81099E' '0CEFAF810993' '0CEFAF810999' '0CEFAF8109A6' '0CEFAF81098B' '0CEFAF8109A7' '0CEFAF8109A5' '0CEFAF810995' '0CEFAF8109AC' '0CEFAF8109A4' '0CEFAF81098D' '0CEFAF81099F' '0CEFAF810996' '0CEFAF81099B' '0CEFAF81098F' '0CEFAF81099C' '0CEFAF8109A2' '0CEFAF810994' '0CEFAF81099A' '0CEFAF810990' '0CEFAF8109A8' '0CEFAF81098C' '0CEFAF8109A9' '0CEFAF810997' '0CEFAF8109AA'}; % failed units '0CEFAF8109AB' '0CEFAF810998'
%DEVICE_LIST = {'0CEFAF810986' '0CEFAF810970' '0CEFAF81097A' '0CEFAF81097C' '0CEFAF81099E' '0CEFAF8109A9' '0CEFAF810983'};
%DEVICE_LIST = {'0CEFAF810977' '0CEFAF810984' '0CEFAF810990' '0CEFAF810995' '0CEFAF8109A9'};
%DEVICE_LIST = {'0CEFAF8103D0' '0CEFAF8107FC' '0CEFAF810107' '0CEFAF810917'};
%DEVICE_LIST = {'0CEFAF8106DE' '0CEFAF810270' '0CEFAF810726' '0CEFAF8104A2' '0CEFAF810529' '0CEFAF8101C5' '0CEFAF8102BC' '0CEFAF8101CF' '0CEFAF8104F3' '0CEFAF8103C1'}; % Additional 10 Permatex devices used during verification.
%DEVICE_LIST = {'0CEFAF8000A3' '0CEFAF810032' '0CEFAF80000F' '0CEFAF810714' '0CEFAF81004C' '0CEFAF8100D6' '0CEFAF810043' '0CEFAF81044F' '0CEFAF810091' '0CEFAF80009E' '0CEFAF8100CA' '0CEFAF810072' '0CEFAF810087' '0CEFAF810034' '0CEFAF800081' '0CEFAF810038' '0CEFAF81004F' '0CEFAF8100E5' '0CEFAF8104BA' '0CEFAF8000CA'};
DEVICE_LIST = {'0CEFAF810D1D' '0CEFAF810D17' '0CEFAF810D15' '0CEFAF810D16' '0CEFAF810D1E' '0CEFAF810C4F' '0CEFAF810D3D' '0CEFAF810C28' '0CEFAF810D3F' '0CEFAF810D35' '0CEFAF810D37' '0CEFAF810D14' '0CEFAF810C55' '0CEFAF810D40' '0CEFAF810CDB' '0CEFAF810CDD' '0CEFAF810D3E' '0CEFAF810D21' '0CEFAF810D32' '0CEFAF810D44' '0CEFAF810D26' '0CEFAF810D36' '0CEFAF810D2D' '0CEFAF810C3C' '0CEFAF810C42' '0CEFAF810C4D' '0CEFAF810CF2' '0CEFAF810C51' '0CEFAF810C56' '0CEFAF810D38' '0CEFAF810C2B' '0CEFAF810C3A' '0CEFAF810C2C' '0CEFAF810C2E' '0CEFAF810D41' '0CEFAF810D33' '0CEFAF810D13'};


%PRE_DATE = '20150914';   % latest date when PRE calibration runs were performed. Formated according to DATE_FORMAT. Comment out to compare devices against immediately previous calibration
pdfPath = pwd;  % default path for saving PDF output files

indiv_reply = questdlg('Save individual results to PDF?');
if strcmp(indiv_reply, 'Yes')
    pdfPath = uigetdir(pdfPath);
    SAVE_PDF = true;
end

%% Get and process data

if exist('PRE_DATE', 'var')
    PRE_DATE_NUM = datenum(PRE_DATE, DATE_FORMAT);
end

num_devs = numel(DEVICE_LIST);
for ii = 1:num_devs
    fprintf('Querying device #%d/%d: %s\n', ii, num_devs, DEVICE_LIST{ii})
    
    if SAVE_PDF
        pdf_file = publish(['devAnalysis(''' DEVICE_LIST{ii} ''', 1, ''none'')'], 'outputDir', pdfPath, 'format', 'pdf','showCode', false);
        new_pdf_file = [pdfPath '\MostRecentCalibration_Analysis_device_' DEVICE_LIST{ii} '.pdf'];
        movefile(pdf_file, new_pdf_file,'f'); % move pdf file to final destination, renaming it in the process
        fprintf('Saved most recent calibration to PDF file %s\n', new_pdf_file)
    end
    
    device{ii} = getDevice(DEVICE_LIST{ii});
    if exist('PRE_DATE','var')
        for jj = 2:numel(device{ii}.checkouts)  % traverse checkout list in reverse chronological order, skipping the most recent calibration
            if datenum(device{ii}.checkouts{jj}.created_at) <= PRE_DATE_NUM  % find latest calibration that was performed at least on PRE_DATE or earlier
                pre_chkout = jj;
                break
            end
        end
        if datenum(device{ii}.checkouts{jj}.created_at) > PRE_DATE_NUM
            pre_chkout = jj;    % no calibration found performed before PRE_DATE. Use oldest available instead.
            warning(['Couldn''t find a calibration performed on or before ' PRE_DATE '. Using oldest checkout = ' num2str(jj)])
        end
    else    % no date selected. Use immediately previous calibration
        pre_chkout = 2;
    end
    fprintf('Using calibration # %d performed on %s\n', pre_chkout, device{ii}.checkouts{pre_chkout}.created_at)
    devAllCnt_post(ii,:,:) = getAllCnt(device{ii},1);   % get most recent calibration AllCnt table
    devAllCnt_pre(ii,:,:) = getAllCnt(getDevice(DEVICE_LIST{ii}),pre_chkout);
    deltaAllCnt(ii,:,:) = devAllCnt_post(ii,:,:) - devAllCnt_pre(ii,:,:);
    maxCnt_pre(ii,:) = devAllCnt_pre(ii,end,:);
    maxCnt_post(ii,:) = devAllCnt_post(ii,end,:);
    
     if SAVE_PDF
        pdf_file = publish(['devAnalysis(''' DEVICE_LIST{ii} ''', ' num2str(pre_chkout) ', ''none'')'], 'outputDir', pdfPath, 'format', 'pdf','showCode', false);
        new_pdf_file = [pdfPath '\PreviousCalibration_Analysis_device_' DEVICE_LIST{ii} '.pdf'];
        movefile(pdf_file, new_pdf_file,'f'); % move pdf file to final destination, renaming it in the process
        fprintf('Saved previous calibration to PDF file %s\n', new_pdf_file)
     end
    
end

%% Display results

HW_VERSION = device{1}.hw_version;  % first device in the list defines hw_version
[ MAX_PASS, MIN_PASS, MuEffNom, MuError, MuEffTol, RMSErrorMAX ] = calibPassFail(HW_VERSION);
currents = getCurrents(HW_VERSION);

for ii = 1:num_devs
    
    rmsAllCnt(ii) =  rms(deltaAllCnt(ii,:));
    fprintf('\nRMS of calibration difference in unit %s = %f\n', DEVICE_LIST{ii}, rmsAllCnt(ii))
    
    figure; clf
    set(gcf, 'Position', [16 340 560 420]);
    plot(maxCnt_pre(ii,:),'b')
    hold on
    plot(maxCnt_post(ii,:),'g')
    plot(MAX_PASS,'r')
    plot(MIN_PASS,'r')
    hold off
    grid
    xlabel('LED', 'FontSize', FONTSIZE)
    ylabel('Counts/Transmission', 'FontSize', FONTSIZE)
    title(['MaxAllCnt of device ' DEVICE_LIST{ii}], 'Fontsize', FONTSIZE)
    legend('Pre', 'Post', 'Tolerances', 'Location', 'Best')
    
    figure; clf
    set(gcf, 'Position', [595 341 560 420]);
    surf([1:2*numel(leds)], currents, squeeze(double(deltaAllCnt(ii,:,:))))
    xlabel('LEDs')
    ylabel('Currents (Amp)')
    zlabel('Counts')
    title(['Delta of AllCnt matrix, device ' DEVICE_LIST{ii}])
    axis tight
    
end
table(DEVICE_LIST', rmsAllCnt', 'VariableNames', {'Device_ID', 'RMS'})

% if SAVE_PDF
%     close(1:7); % close windows opened by devAnalysis before saving other windows
% end
ppt_reply = questdlg('Save figures to PowerPoint file?');
if strcmp(ppt_reply,'Yes')
    str = ['Comparison of most recent calibration of ' num2str(num_devs) ' devices'];
    if exist('PRE_DATE', 'var')
        str = [str ' versus those performed on or before ' PRE_DATE ];
    end
    str = [str '\nAnalysis performed on ' date];
    if SAVE_PDF     % skip figures created by devAnalysis
        start_fig = 8;
    else
        start_fig = 1;
    end
    saveAssessmentPPT([pdfPath '\' 'Calibration_comparison.ppt'], str, [start_fig:gcf]);
end
