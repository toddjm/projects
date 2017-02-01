function [ sweep ] = sweepSync( sweep, refTime )
% function [ sweep ] = sweepSync( sweep, refTime )
%   Re-syncs sweep structure to new reference time. Creates a new field in the sweep structure (RefTime) recording the new reference time.
%   Adjusts time, time series and imu_time series to be zero at refTime.
%   Reference time MUST BE IN UTC TIME.
%
%   Known limitation: doesn't check (or correct for) changes in date.
%
% Inputs
% sweep - sweep structure (see getSweep.m)
% refTime - reference time (when time series should be zero). String in
% 'HH:MM:SS' format. MUST BE IN UTC TIME.
%
% Outputs
% sweep - sweep structure with updated time series.
%
% See also
% getSweep, getWahoo
%
% BSX Athletics Proprietary

% Constants
TIME_STR = 'HH:MM:SS';  % string with time format

if isfield(sweep, 'RefTime')
    warning(['Reference time already exists and was originally set to ' sweep.RefTime '. Re-setting it to ' refTime])
    sweepRef = sweep.RefTime;   % do this so simultaneous calls to this function do not continuously move the time series.
else
    sweepRef = sweep.UTCtime;
end

% Convert time to seconds
[~,~,~,H, MN, S] = datevec(sweepRef, TIME_STR);
sweepTimeSecs = H*3600+MN*60+S;
[~,~,~,H, MN, S] = datevec(refTime, TIME_STR);
refTimeSecs = H*3600+MN*60+S;
% Error check

if refTimeSecs < sweepTimeSecs
    warning(['Reference time starts before sweep time! Reference time = ' refTime '. sweep.UTCtime = ' sweep.UTCtime])
end
% Adjust time series
deltaT = refTimeSecs - sweepTimeSecs;
sweep.time = sweep.time - deltaT;
sweep.RefTime = refTime;
sweep.imu_time = sweep.imu_time - deltaT;
if sweep.time(end) < 0
    warning(['Sweep file finishes before beginning of reference time! Reference time = ' refTime '. sweep.UTCtime = ' sweep.UTCtime '. Sweep file length = ' num2str(sweep.time(end) - sweep.time(1)) 's.'])
end

end

