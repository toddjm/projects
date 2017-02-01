function [ tf, tind ] = sensor_off( sweep, tind_sensor_on )
% function [ tf, tind ] = sensor_off( sweep )
%
% Function used to develop the "sensor_off" algorithm to be deployed on the
% BSXInsgight device. Used when the device is in the Daily Activity (DA)
% state and detects two taps, and needs to determine whether or not to stop
% data logging and quit DA state. If the Alert field doesn't exist the function issues a warning and creates
% one consisting mostly of zeros, except for the Ambient light alert and no tissue
% detected bits.
% 
% This function is normally called after calling sensor_on.
%
% Example:
% load Bags_sweep.mat  % load example sweep file
% [tf_on, tind_on] = sensor_on(sweep);
% [tf_off, tind_off] = sensor_off(sweep, tind_sn);
% 
% Inputs
% sweep - a sweep structure containing Alert status bits (sweep.Alert)
% tind_sensor_on - time index value when sensor is on (returned by
% sensor_on.m function). Ignores events taking place before this event.
% Default = 0;
%
% Output
% tf - a boolen vector that is normally false but turns to true as soon as
% "sensor off" is detected.
% tind - positive integer with time index when "sensor off" was detected.
% Empty otherwise. Using sweep.time(tind) to find time when sensor was
% determined to be off and device should have switched out of DA state.
%
% See also
% sensor_on, getSweep, istissue
%
% P. Silveira, Nov. 2015

%% Initializations
NO_TISSUE_BIT = 9;     % status alert bit used for no tissue detection
MIN_WAIT = 15*sweep.samp_rate;      % minimum wait between sensor on and start of sensor off detection (samples). Needed to prevent sensor from turning off immediately after turning on.
AMBIENT_ALERT_BIT = 6; % status alert bit used to indicate high ambient light
TISSUE_SAMPLES = 45;    % # of samples used to determine whether or not sensor removal is detected
SUM_TISSUE_THR = TISSUE_SAMPLES;    % minimum # of bits (out of TISSUE_SAMPLE bits) needed to indicate that sensor is on
SUM_AMBIENT_THR = 25; %round(TISSUE_SAMPLES / 2); % minimum # of bits needed to indicate that ambient light is high and sensor is off

%% Input parameter parsing

if ~exist('tind_sensor_on', 'var')
    tind_sensor_on = 0;     % set default value
    MIN_WAIT = 0;
end
SAMPLES = length(sweep.time);
if SAMPLES <= TISSUE_SAMPLES
    erorr(['Sweep structure is too short. Only ' num2str(SAMPLES) ' samples long.'])
end
if tind_sensor_on > SAMPLES
    error(['Sensor on index > number of samples. tind_sensor_on = ' num2str(tind_sensor_on) '. # of samples = ' num2char(SAMPLES)])
end
if ~isfield(sweep, 'Alert')
    warning('No Alert status bits present in sweep structure! Making one up...')
    sweep.Alert = boolean(zeros(SAMPLES,16));
end
if isfield(sweep, 'cHHb_SmO2') % check whether this is a recent sweep file, with hemoglobin concentrations calculated with the device using the projection method
    HbF = sweep.cHHb_SmO2 + sweep.cHbO2_SmO2;
    HbConc = 5e4*HbF./sweep.cH2O_SmO2;
else    % this should be rare, but process counts if concentrations are not present.
    [ ~, HbF, HbConc] = sweep2SmO2(sweep);
end

%% Processing

sweep.Alert(:,NO_TISSUE_BIT) = ~istissue(HbF, HbConc);   % implement tissue detection status bit 8. LATER: check FW version to determine whether to use firmware-calculated bits or to calculate them here.

sumtissue = zeros(SAMPLES,1);   % vector with sum of previous number of samples in which tissue_off bit was false (zero, meaning tissue detected)
sumambient = zeros(SAMPLES,1);  % vector with sum of previous number of samples in which ambient light alarm bit was true (one, meaning ambient light detected)
tf = boolean(zeros(SAMPLES,1));
tind_amb = [];
tind_tissue = [];
for ii = (tind_sensor_on+MIN_WAIT+TISSUE_SAMPLES):SAMPLES    % start after tind_sensor_on+TISSUE_SAMPLES and go to the end of the vector
    sumtissue(ii) = sum(sweep.Alert(ii-TISSUE_SAMPLES+1:ii,NO_TISSUE_BIT)); % sum of tissue alert bits
    sumambient(ii) = sum(sweep.Alert(ii-TISSUE_SAMPLES+1:ii,AMBIENT_ALERT_BIT)); % sum of ambient alert bits
end
temp = find(sumambient >= SUM_AMBIENT_THR);   % if ambient light has been high long enough, stop DA
if ~isempty(temp)   % found at least one solution
    tind_amb = temp(1);
end
temp = find(sumtissue >= SUM_TISSUE_THR);    % finding sensor off in the dark is possible but harder...
if ~isempty(temp)
    tind_tissue = temp(1);
end
% Determine which tind to use. a) None if both are empty, b) the other if
% one is empty, c) the one that happened the soonest.
if isempty(tind_amb) & isempty(tind_tissue)     % sensor off event not found. Return default values.
    tind = [];
    return
elseif isempty(tind_amb)
    tind = tind_tissue;
elseif isempty(tind_tissue)
    tind = tind_amb;
elseif tind_amb <= tind_tissue
    tind = tind_amb;
else
    tind = tind_tissue;
end
tf(tind:SAMPLES) = true;


end

