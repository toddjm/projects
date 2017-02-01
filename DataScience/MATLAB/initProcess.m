[cent_wavel leds] = getLeds; % get LED centroid and nominal wavelengths

% Path parameters
FONTSIZE = 11;  % size of fonts used in plots
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing'];
TEMP_CSV = [USERPATH '\Run_check_temp.csv'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures

% Processing parameters
BODY_PART = 'calf';  % body part being monitored. Options are 'calf', 'head' and 'forearm'
PP_THR = 66;    % post-processing threshold (counts)
AMB_THR = 0; % ambient light threshold (counts)
MU = '\mu_a';    % select which absorption coefficient to use (\mu_a or \mu_eff)
GAIN = 1.6;   % scaling function gain factor
MAP_METHOD = 'softsig';  % mapping method
DIGITS = 1; % number of digits in SmO2 beyond decimal point. Use 1 for ANT+ standard (0.1% precision).
FILTER_LENGTH = 3;  % length of filter used to calculate SmO2 (seconds)
TISSUE_FILTER_LENGTH = 2;    % length of filter (seconds)
UPDATE_RATE = 1;    % update rate (Hz)
BASELINE_RANGE = [20:40];   % baseline range (seconds)
