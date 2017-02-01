% Script used to analyze hydration status of different activity or LT
% assessment files.
% P. Silveira, Jan. 2015
% N. Rajan, Sep. 2015
% BSX Athletics Proprietary
%

%% Initialize
clear all
close all
%[wavel leds] = getLeds; % get LED centroid and nominal wavelengths

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing'];
%global SWEEP_SUFFIX     % global variable set by getSweep
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
CONT_RUN = 'Yes';   % continue to Run flag
CSV_EXT = '.csv';   % CSV file extension
PDF_EXT = '.pdf';   % pdf file extension
TEMP_CSV = [USERPATH '\temp' CSV_EXT];  % temporary CSV file location
SWEEP_TEMP =[USERPATH '\temp' SWEEP_SUFFIX]; % temporary sweep file location

% Processing parameters
BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'
% PP_THR = 100;    % post-processing threshold (counts)
% AMB_THR = 10000; % ambient light threshold (counts)
MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
GAIN = 1.6;   % scaling function gain factor
MAP_METHOD = 'softsig';  % mapping method
DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
%FILTER_LENGTH = 3;  % length of filter used to calculate SmO2 (seconds)
TISSUE_FILTER_LENGTH = 2;    % length of filter (seconds)
BASELINE_RANGE = [20:35];   % baseline range (seconds)

while strcmp(CONT_RUN, 'Yes')
    
    %% Data input
    assessment_ID = inputdlg('Enter assessment or activity ID number(s) (click "Cancel" or press "Esc" twice to select a file instead)', 'Select assessment or activity');
    if isempty(assessment_ID)  % file input selected
        [fileNames, pathname, filterind] = uigetfile({['*' SWEEP_SUFFIX] 'MATLAB sweep file'; '*.csv' 'CSV'; '*.bin' 'Binary'; '*.optical' 'Binary'}, 'Pick file(s) with assessment data', FILE_PATH, 'MultiSelect', 'on');
        if ~iscell(fileNames) && ~ischar(fileNames) && (fileNames == 0)    % no file selected
            msgbox('No assessment selected. Exiting.', 'Run_check', 'warn')
            return
        end
        if ~iscell(fileNames)
            temp = fileNames;   % convert to a cell (needed when a single file is selected)
            clear fileNames;
            fileNames{1} = temp;
        end
    else    % url selected
        fileNames = strsplit(assessment_ID{1});
        for ii = 1:numel(fileNames)
            fileNames{ii} = [fileNames{ii} '.url'];
        end
    end
    
    for ii = 1:length(fileNames)
        filename = fileNames{ii};
        [temp, file, fileExt] = fileparts(filename);   % get file extension
        switch fileExt
            case {'.bin' '.optical' '.csv'} % file types that can be handled by getSweep
                try
                    sweep = getSweep([pathname filename]);  % get sweep data
                catch err
                    fprintf(2,'Error reading file %s.\nSkipping. Error code = %s.\n%s\n', [pathname filename], err.identifier, err.message)
                    % Save CSV file, if it exists
                    if ~condMove([USERPATH '\' 'temp_python' CSV_EXT], [pathname file CSV_EXT])
                        condMove([USERPATH '\' 'temp' CSV_EXT], [pathname file CSV_EXT]);
                    end
                    continue
                end
            case '.mat'
                file = filename(1:end-length(SWEEP_SUFFIX)); % find root
                load([pathname filename]);
            case '.url'
                assessment_ID = file;
                try     % we have no good way to tell whether an ID corresponds to an activity or assessment, so let's try an assessment first
                    assessment = getAssessment(assessment_ID);
                catch err
                    fprintf(2, '%s is not a valid assessment. Trying an activity instead.\n', file)
                    assessment = getActivity(assessment_ID);
                end
                if ~isfield(assessment, 'links') || ~isfield(assessment.links, 'optical')
                    msgbox(['No optical files available in assessment ' assessment.alpha__id '. Skipping.'], 'Run_check', 'warn')
                    continue
                end
                sweep = getSweep(assessment.links.optical, TEMP_CSV); % get sweep data (TO DO: use user ID and assessment ID to name output file)
            otherwise
                error(['Unsupported file extension = ' fileExt])
        end
        
%        device = getDevice(sweep.device_id);    % get device data
%        [AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent device calibration data
        
        %% Data processing and Analysis
        
        process = sweep2process(sweep);
        
 %       [process.OD15, process.OD27] = processCounts(sweep, AllCnt, lookup_current); %, PP_THR, AMB_THR);
        ODDiff = process.OD27-process.OD15; % differential OD
 %       [ process.rawSmO2, process.Resid, process.mu_eff, HbF, Pk, mu_s, mu_a ] = calc_SmO2(ODDiff, MU, BODY_PART);
        
        % Spatially-resolved projection calculations
 %       pHhb = Pk(:,1);
 %       pHbO2 = Pk(:,2);
 %       pH2O = Pk(:,3);
 %       [process.pH2Oproj, process.pH2Ocos] = calc_hydration(ODDiff, MU, BODY_PART);
        [process.colip.pH2O, process.colip.Pk, process.colip.Resid2, process.colip.mu_eff, process.colip.mu_s, process.colip.mu_a ] = calc_hydration2(ODDiff, MU, BODY_PART);
        
        % Total Hemoglobin calculations
%        sweep.tHb_15 = sweep.cHbO2_15mm + sweep.cHhb_15mm;   % from device-calculated concentrations
%        sweep.tHb_27 = sweep.cHbO2_27mm + sweep.cHhb_27mm;

%        process.tHb = calc_tHb(HbF);    % calibrated total hemoglobin concentration (g/dL)
        process.colip.HbF = process.colip.Pk(:,1) + process.colip.Pk(:,2);
        process.colip.tHb = calc_tHb(process.colip.HbF);    % calibrated total hemoglobin concentration (g/dL)
 %       HbConc = 5e4*HbF./pH2O; % hemoglobin concentration (old method)
        
        % SmO2 calculations
 %       sweep.SmO2_15 = 100*sweep.cHbO2_15mm ./ sweep.tHb_15;   % using device-calculated concentrations
 %       sweep.SmO2_27 = 100*sweep.cHbO2_27mm ./ sweep.tHb_27;
        
%        process.SmO2 = processSmO2(process.rawSmO2, MAP_METHOD, GAIN, FILTER_LENGTH*sweep.samp_rate, DIGITS);   % post-process
%        process.SmO2 = process.SmO2(1:sweep.samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
%        full_length = length(process.SmO2);
%        decimated_ind = [1:sweep.samp_rate:full_length];
%        decSmO2 = process.SmO2(decimated_ind);    % simple (but not exact) decimation
%        x = linspace(sweep.time(1),sweep.time(end), length(decSmO2));   % grid points where decSmO2 is defined
%        xq = linspace(sweep.time(1), sweep.time(end), full_length);     % grid points where SmO2 should be defined
%        temp = interp1(x, decSmO2, xq, 'nearest'); % Nearest neighbor interpolation mimics behavior of FW
%        process.SmO2 = temp';
        if isfield(sweep, 'SmO2')
            temp = sweep.SmO2;  % also process SmO2 value calculated by firmware
            temp(temp > 100) = NaN;  % replace 0x3FF and 0x3FE values with NaN
            sweep.SmO2 = temp;
            [process.HbO2, process.Hhb] = calc_hemes(sweep.SmO2, process.tHb);
        else
            [process.HbO2, process.Hhb] = calc_hemes(process.SmO2, process.tHb);
        end
%        process.dec_time = linspace(sweep.time(1), sweep.time(end), length(process.SmO2));    % decimated time
%         process.HbF = avgfiltNaN(HbF, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % LPF total hemoglobin
%         process.pH2O = avgfiltNaN(pH2O, TISSUE_FILTER_LENGTH*sweep.samp_rate);
        process.pH2O_proj = avgfiltNaN(process.pH2Oproj, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % hydration w/o hemoglobin
        process.pH2O_cos = avgfiltNaN(process.pH2Ocos, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % hydration w/o hemoglobin
        process.colip.pH2O = avgfiltNaN(process.colip.pH2O, TISSUE_FILTER_LENGTH*sweep.samp_rate); 
%        process.HbConc = avgfiltNaN(HbConc, TISSUE_FILTER_LENGTH*sweep.samp_rate);
%        [process.tissueTF, process.tissue] = istissue(process.HbF,process.HbConc);     % optical tissue detection
        
        % Calculate min, max, averages and baselines
        process.stat.SmO2 = baselineStats(process.SmO2, BASELINE_RANGE*sweep.samp_rate);
        process.stat.HR = baselineStats(sweep.HR, BASELINE_RANGE*sweep.samp_rate);
        process.stat.pH2O = baselineStats(process.pH2O, BASELINE_RANGE*sweep.samp_rate);
        process.stat.HbConc = baselineStats(process.HbConc, BASELINE_RANGE*sweep.samp_rate);
        process.stat.HbF = baselineStats(process.HbF, BASELINE_RANGE*sweep.samp_rate);
        process.stat.tHb = baselineStats(process.tHb, BASELINE_RANGE*sweep.samp_rate);
        
        process.stat.colip.pH2O = baselineStats(process.colip.pH2O, BASELINE_RANGE*sweep.samp_rate);
        process.stat.pH2O_proj = baselineStats(process.pH2O_proj, BASELINE_RANGE*sweep.samp_rate);
        process.stat.pH2O_cos = baselineStats(process.pH2O_cos, BASELINE_RANGE*sweep.samp_rate);

        sweepLength = length(sweep.time);
        end_range = [sweepLength-round(25*sweep.samp_rate):sweepLength-round(10*sweep.samp_rate)];
        process.stat.pH2O.frac_var = frac_var(process.stat.pH2O.baseline, median(process.pH2O(end_range)))
        process.stat.pH2O_proj.frac_var = frac_var(process.stat.pH2O_proj.baseline, median(process.pH2O_proj(end_range)))
        process.stat.pH2O_cos.frac_var = frac_var(process.stat.pH2O_cos.baseline, median(process.pH2O_cos(end_range)))
        process.stat.colip.pH2O.frac_var = frac_var(process.stat.colip.pH2O.baseline, median(process.colip.pH2O(end_range)));
        
        %% Display results
        
        if ii == 1  % only ask once
            PDF_reply = questdlg('Save output to PDF file?');
        end
        
        if strcmp(PDF_reply,'Yes')
            if strcmp(fileExt,'.url')
                if ii == 1  % only ask once
                    pathPDF = uigetdir(FILE_PATH, 'Select directory where to save PDF file');
                end
                file = ['\' assessment_ID];
                movefile(SWEEP_TEMP, [pathPDF file SWEEP_SUFFIX], 'f'); % move sweep file to selected path
            else
                pathPDF = pathname;
            end
            FILE_PATH = pathPDF;   % make this the new default directory
            pdf_file = publish('Hydration_plot.m', 'outputDir', pathPDF, 'format', 'pdf','showCode', false);
            new_pdf_file = [pathPDF file '_hydration.pdf'];
            movefile(pdf_file, new_pdf_file,'f'); % move pdf file to final destination, renaming it in the process
            fprintf('Saved PDF to file %s\n', new_pdf_file)
        else
            Hydration_plot  % plot results
        end
        
    end
    CONT_RUN = questdlg('Re-run?','Run_check','No');
    
end



