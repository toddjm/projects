function [ tf, tind ] = sensor_on( sweep, tind_sensor_off )
% function [ tf, tind ] = sensor_on( sweep, tind_sensor_off )
%
% Function used to develop the "sensor_on" algorithm to be deployed on the
% BSXInsgight device. Used when the device wakes up and is in the "pre-DA"
% state, determining whether or not it is attached to tissue.
% 
% Inputs
% sweep - a sweep structure containing Alert status bits (sweep.Alert). If
% the Alert field doesn't exist the function issues a warning and creates
% one consisting mostly of zeros, except for the Ambient light alert and no tissue
% detected bits.
% tind_sensor_off - time index value when sensor is off (returned by
% sensor_off.m function). Ignores events taking place before this event.
% Default = 0;
%
% Output
% tf - a boolen vector that is normally false but turns to true as soon as
% tissue is detected, indicating that the device has switched into the "DA"
% state.
% tind - positive integer with time index when "sensor on" was detected.
% Empty otherwise. Using sweep.time(tind) to find time when sensor was
% determined to be on and device should have switched into DA state.
%
% See also
% sensor_off, getSweep, istissue
%
% P. Silveira, Nov. 2015

%% Initializations
NO_TISSUE_BIT = 9;     % status alert bit used for no tissue detection
MIN_WAIT = 5*sweep.samp_rate;      % minimum wait between sensor off and start of sensor on detection (samples). Needed to prevent sensor from turning on immediately after turning of..
%AMBIENT_ALERT_BIT = 6; % status alert bit used to indicate high ambient light
TISSUE_SAMPLES = 15;    % # of samples used to determine whether or not tissue is detected
SUM_TISSUE_THR = TISSUE_SAMPLES-1;    % minimum # of bits (out of TISSUE_SAMPLE bits) needed to indicate that sensor is on
%SUM_AMBIENT_THR = round(TISSUE_SAMPLES / 2); % maximum # of bits allowed to indicate that ambient light is not high and sensor is on

%% Input parameter parsing

if ~exist('tind_sensor_off', 'var')
    tind_sensor_off = 0;     % set default value
    MIN_WAIT = 0;
end
SAMPLES = length(sweep.time);
if SAMPLES <= TISSUE_SAMPLES
    erorr(['Sweep structure is too short. Only ' num2str(SAMPLES) ' samples long.'])
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

sumtissue = zeros(SAMPLES,1);
%sumambient = zeros(SAMPLES,1);
tf = boolean(zeros(SAMPLES,1));
for ii = (tind_sensor_off+MIN_WAIT+TISSUE_SAMPLES):SAMPLES
    sumtissue(ii) = sum(~sweep.Alert(ii-TISSUE_SAMPLES+1:ii,NO_TISSUE_BIT));
%    sumambient(ii) = sum(sweep.Alert(ii-TISSUE_SAMPLES+1:ii,AMBIENT_ALERT_BIT));
end
temp = find(sumtissue > SUM_TISSUE_THR);
if ~isempty(temp)   % found at least one instance of sensor on tissue. Now let's make sure ambient ligth is also low.
%     for jj = 1:length(temp) % search through all instances, starting from the earliest
%         tind = temp(jj);
%         temp2 = find(sumambient(tind:SAMPLES) < SUM_AMBIENT_THR);
%         if ~isempty(temp2)  % found it
%             tf(tind:SAMPLES) = true;
%             return
%         end
    tind = temp(1);
    tf(tind:SAMPLES) = true;
end

end

