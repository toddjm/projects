% Script used to analyze LT assessment run from a CSV or binary files
% P. Silveira, Feb. 2015
% N. Rajan, Sep. 2015
% BSX Athletics Proprietary
%

%% Initialize
clear
close all
%[wavel leds] = getLeds; % get LED centroid and nominal wavelengths

global USERPATH     % define global variables used by other scripts/functions

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
PP_THR = 100;    % post-processing threshold (counts)
AMB_THR = 10000; % ambient light threshold (counts)
MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
GAIN = 1.6;   % scaling function gain factor
MAP_METHOD = 'softsig';  % mapping method
DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
FILTER_LENGTH = 3;  % length of filter used to calculate SmO2 (seconds)
TISSUE_FILTER_LENGTH = 2;    % length of filter (seconds)
%UPDATE_RATE = 1;    % update rate (Hz)
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
        
        device = getDevice(sweep.device_id);    % get device data
        [AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent device calibration data
        
        %% Data processing and Analysis
        
        [process.OD15, process.OD27] = processCounts(sweep, AllCnt, lookup_current, PP_THR, AMB_THR);
        ODDiff = process.OD27-process.OD15; % differential OD
        [ process.rawSmO2, process.Resid, process.mu_eff, HbF, Pk, mu_s, mu_a ] = calc_SmO2(ODDiff, MU, BODY_PART);
        
        % Re-calculate Hb concentrations
        %        process.cHb15 = process.OD15 * invC15';
        %        process.cHb27 = process.OD27 * invC27';
        
        % Spatially-resolved projection calculations
        pHhb = Pk(:,1);
        pHbO2 = Pk(:,2);
        pH2O = Pk(:,3);
        [pH2Oproj, pH2Ocos] = calc_hydration(ODDiff);
        % if exist('MELANIN', 'var')
        %     pmelanin = projections(:,4);
        % end
        
        % Total Hemoglobin calculations
        sweep.tHb_15 = sweep.cHbO2_15mm + sweep.cHhb_15mm;   % from device-calculated concentrations
        sweep.tHb_27 = sweep.cHbO2_27mm + sweep.cHhb_27mm;
        %         process.tHb_15 = sum(process.cHb15,2);   % from re-calculated concentrations
        %         process.tHb_27 = sum(process.cHb27,2);
        process.tHb = calc_tHb(HbF);    % calibrated total hemoglobin concentration (g/dL)
        process.HbF = avgfiltNaN(HbF, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % LPF total hemoglobin
        process.pH2O = avgfiltNaN(pH2O, TISSUE_FILTER_LENGTH*sweep.samp_rate);
        process.HbConc = 5e4*process.HbF./process.pH2O; % hemoglobin concentration (old method)
        
        % SmO2 calculations
        %        process.SmO2_15 = 100*process.cHb15(:,2) ./ process.tHb_15;   % using re-calculated concentrations
        %        process.SmO2_27 = 100*process.cHb27(:,2) ./ process.tHb_27;
        sweep.SmO2_15 = 100*sweep.cHbO2_15mm ./ sweep.tHb_15;   % using device-calculated concentrations
        sweep.SmO2_27 = 100*sweep.cHbO2_27mm ./ sweep.tHb_27;
        %pSmO2 = pHbO2 ./ HbF;   % pseudo-inverse with H2O
        
        process.SmO2 = processSmO2(process.rawSmO2, MAP_METHOD, GAIN, FILTER_LENGTH*sweep.samp_rate, DIGITS);   % post-process
%        process.SmO2 = process.SmO2(1:sweep.samp_rate / UPDATE_RATE:end);    % simple (but not exact) decimation
        full_length = length(process.SmO2);
        decimated_ind = [1:sweep.samp_rate:full_length];
        decSmO2 = process.SmO2(decimated_ind);    % simple (but not exact) decimation
        x = linspace(sweep.time(1),sweep.time(end), length(decSmO2));   % grid points where decSmO2 is defined
        xq = linspace(sweep.time(1), sweep.time(end), full_length);     % grid points where SmO2 should be defined
        temp = interp1(x, decSmO2, xq, 'nearest'); % Nearest neighbor interpolation mimics behavior of FW
        process.SmO2 = temp';
        if isfield(sweep, 'SmO2')
            temp = sweep.SmO2;  % also process SmO2 value calculated by firmware
            temp(temp > 100) = NaN;  % replace 0x3FF and 0x3FE values with NaN
            sweep.SmO2 = temp;
            [process.HbO2, process.Hhb] = calc_hemes(sweep.SmO2, process.tHb);
        else
            [process.HbO2, process.Hhb] = calc_hemes(process.SmO2, process.tHb);
        end
%        process.dec_time = linspace(sweep.time(1), sweep.time(end), length(process.SmO2));    % decimated time

        process.pH2O_proj = avgfiltNaN(pH2Oproj, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % hydration w/o hemoglobin
        process.pH2O_cos = avgfiltNaN(pH2Ocos, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % hydration w/o hemoglobin
       [process.tissueTF, process.tissue] = istissue(process.HbF,process.HbConc);     % optical tissue detection 
        % Calculate min, max, averages and baselines
        stat.SmO2 = baselineStats(process.SmO2, BASELINE_RANGE*sweep.samp_rate); % use this until device-calculated SmO2 gets corrected
        stat.HR = baselineStats(sweep.HR, BASELINE_RANGE*sweep.samp_rate);
        stat.pH2O = baselineStats(process.pH2O, BASELINE_RANGE*sweep.samp_rate);
        stat.HbConc = baselineStats(process.HbConc, BASELINE_RANGE*sweep.samp_rate);
        stat.HbF = baselineStats(process.HbF, BASELINE_RANGE*sweep.samp_rate);
        stat.tHb = baselineStats(process.tHb, BASELINE_RANGE*sweep.samp_rate);
        
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
            pdf_file = publish('Run_check_plot.m', 'outputDir', pathPDF, 'format', 'pdf','showCode', false);
            new_pdf_file = [pathPDF file '.pdf'];
            movefile(pdf_file, new_pdf_file,'f'); % move pdf file to final destination, renaming it in the process
            fprintf('Saved PDF to file %s\n', new_pdf_file)
        else
            Run_check_plot  % plot results
        end
        
    end
    CONT_RUN = questdlg('Re-run?','Run_check','No');
    
end



