function [ sensor_on ] = sensor_onoff( sweep )
% function [ tf, tind ] = sensor_onoff( sweep )
%
% Function used to develop the "sensor_on" and "sensor off" algorithms to be deployed on the
% BSXInsgight device. Used when the device wakes up and is in the "pre-DA"
% state, determining whether or not it is attached to tissue (sensor on) or when it is in the "DA"
% state and needs to detect whether device has been removed from tissue (sensor off).
% 
% Inputs
% sweep - a sweep structure containing Alert status bits (sweep.Alert). If
%
% Output
% sensor_on - a boolen vector that is true when device is in Daily Activity mode (sensor is on) and
% false when device is in sleep mode (sensor is off).
%
% See also
% sensor_on, sensor_off, getSweep, istissue
%
% P. Silveira, Nov. 2015
% BSX Athletics Proprietary

%% Constants
NO_TISSUE_BIT = 9;     % status alert bit used for no tissue detection
AMBIENT_ALERT_BIT = 6; % status alert bit used to indicate high ambient light
MIN_WAIT_TO_ON = 5*sweep.samp_rate;      % minimum wait between sensor off and start of sensor on detection (samples). Needed to prevent sensor from turning on immediately after turning of..
MIN_WAIT_TO_OFF = 15*sweep.samp_rate;      % minimum wait between sensor on and start of sensor off detection (samples). Needed to prevent sensor from turning off immediately after turning on.
SAMPLES_ON = 15;    % # of samples used to determine whether or not tissue is detected
SAMPLES_OFF = 45;    % # of samples used to determine whether or not sensor removal is detected

%% Input parameter parsing

SAMPLES = length(sweep.time);
if SAMPLES <= SAMPLES_ON || SAMPLES <= SAMPLES_OFF
    erorr(['Sweep structure is too short. Only ' num2str(SAMPLES) ' samples long.'])
end
if ~isfield(sweep, 'Alert')
    warning('No Alert status bits present in sweep structure! Making one up...')
    sweep.Alert = boolean(zeros(SAMPLES,16));   % WARNING! not all bits are implemented here, only the minimum necessary for sensor on/off detection!
    sweep.Alert(:,AMBIENT_ALERT_BIT) = (sweep.ambient >= 10000);
end
if isfield(sweep, 'cHHb_SmO2') % check whether this is a recent sweep file, with hemoglobin concentrations calculated with the device using the projection method
    HbF = sweep.cHHb_SmO2 + sweep.cHbO2_SmO2;
    HbConc = 5e4*HbF./sweep.cH2O_SmO2;
else    % process counts if concentrations are not present.
    [ ~, HbF, HbConc] = sweep2SmO2(sweep);
end


%% Initializations

sweep.Alert(:,NO_TISSUE_BIT) = ~istissue(HbF, HbConc);   % implement tissue detection status bit 8. LATER: check FW version to determine whether to use firmware-calculated bits or to calculate them here.
sensor_on = boolean(zeros(SAMPLES,1));
ii = MIN_WAIT_TO_ON;     % sample counter. Start with MIN_WAIT_TO_ON (skips current setting)

%% Processing

while ii < SAMPLES
    ii = ii+1;
    if sensor_on(ii-1)  % sensor was on. Let's check if it's now off.
        sensor_on(ii) = detect_sensor_off(sweep.Alert(ii-SAMPLES_OFF:ii,AMBIENT_ALERT_BIT), sweep.Alert(ii-SAMPLES_OFF:ii,NO_TISSUE_BIT));
        if ~sensor_on(ii)   % detect transition to off
            ii = ii + MIN_WAIT_TO_ON;   % wait this many steps
        end
    else    % sensor was off (initial state)
        sensor_on(ii) = detect_sensor_on(sweep.Alert(ii-SAMPLES_ON:ii,NO_TISSUE_BIT));
        if sensor_on(ii)   % detect transition to on
            ii = ii + MIN_WAIT_TO_OFF;   % wait this many steps
            sensor_on(ii-MIN_WAIT_TO_OFF:ii) = true;
        end
    end
end

% Crop sensor_on vector, in case it went beyond SAMPLES because of MIN_WAIT
temp = sensor_on;
clear sensor_on;
sensor_on = temp(1:SAMPLES);

function sensor_on = detect_sensor_off(alertAmbient, alertNoTissue)
NoTissue_THR_OFF = 45;    % minimum # of bits (out of TISSUE_SAMPLE bits) needed to indicate that sensor is on
AMBIENT_THR_OFF = 25; %round(TISSUE_SAMPLES / 2); % minimum # of bits needed to indicate that ambient light is high and sensor is off
        
        if sum(alertAmbient(:)) >= AMBIENT_THR_OFF
            sensor_on = false;
            return
        elseif sum(alertNoTissue(:)) >= NoTissue_THR_OFF
            sensor_on = false;
            return
        else
            sensor_on = true;
        end

function sensor_on = detect_sensor_on(alertNoTissue)
NoTissue_THR_ON = 1;    % maximum # of bits (out of SAMPLE_ON bits) acceptable to indicate that sensor is on
        
        if sum(alertNoTissue(:)) <= NoTissue_THR_ON
            sensor_on = true;
        else
            sensor_on = false;
        end

