%% BSX Data processing and Analysis

% Get the sensor data
sweep = getCSV(TEMP_PYTHON);
device = getDevice(sweep.device_id);    % get device data
[AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent device calibration data

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


[process.OD15, process.OD27] = processCounts(sweep, AllCnt, lookup_current, PP_THR, AMB_THR);
ODDiff = process.OD27-process.OD15; % differential OD
[ process.rawSmO2, process.Resid, process.mu_eff, HbF, Pk, mu_s, mu_a ] = calc_SmO2(ODDiff, MU, BODY_PART);
process.tHb = calc_tHb(HbF);    % calibrated total hemoglobin concentration (g/dL)