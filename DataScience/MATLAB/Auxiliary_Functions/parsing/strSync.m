function [ outStr ] = strSync( inStr, refTime )
% function [ outStr ] = strSync( inStr, refTime )
%   Re-syncs input structure to new reference time. Creates a new field in the structure (RefTime) recording the new reference time.
%   Adjusts time, time series and imu_time series (if present) to be zero at refTime.
%   Reference time MUST BE IN THE SAME TIME ZONE as the time used in the structure, usually UTC.
%
%   Typically in a study you will have multiple structures, each one with
%   its own time series and one of them is determined to be the
%   "master" reference. Use the master start time as the reference
%   (refTime). inStr is the input data structure and outStr is the output
%   data structure, synchronized with the master starting time. inStr and
%   outStr can be the same structure, in which case the old timing
%   information gets overwritten with the new one. 
% 
%   A new field called "RefTime" is created in outStr. This field contains
%   the same time as refTime and assures consistency if strSync is called
%   multiple times on the same data sequence.
%
% Example:
%  sweep = getSweep('example_sweep.mat')
%  wahoo = getWahoo('Wahoo.csv')
%  sweep = strSync(sweep, wahoo.StarTime)  % Syncs sweep file using the Wahoo file as the reference.
%  process = sweep2process(sweep)           % Process sweep data after syncrhonization
%  plot(sweep.time, process.HR)
%  hold on; plot(wahoo.time, wahoo.hr_heartrate, 'r')    % compare heart rates
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
% sweepSync, getSweep, getWahoo, getMoxy, getZephyr
%
% BSX Athletics Proprietary

% Constants
TIME_STR = 'HH:MM:SS';  % string with time format

outStr = inStr;   % copy structure

% Error checking
if isfield(inStr, 'UTCtime')   % sweep structure
    timeField = 'UTCtime';
elseif isfield(inStr, 'StartTime')
    timeField = 'StartTime';
else
    error('Start time undefined in input structure!')
end

if isfield(inStr, 'RefTime')
    warning(['Reference time already exists and was originally set to ' inStr.RefTime '. Re-setting it to ' refTime])
    inRef = inStr.RefTime;   % do this so simultaneous calls to this function do not continuously move the time series.
else
    inRef = inStr.(timeField);
end

% Convert time to seconds
[~, ~, ~, H, MN, S] = datevec(inRef, TIME_STR);
inTimeSecs = H*3600+MN*60+S;
[~,~, ~, H, MN, S] = datevec(refTime, TIME_STR);
refTimeSecs = H*3600+MN*60+S;
% Error check

if refTimeSecs < inTimeSecs
    warning(['Reference time starts before structure time! Reference time = ' refTime '. in.StartTime = ' inStr.(timeField)])
end
% Adjust time series
deltaT = refTimeSecs - inTimeSecs;
outStr.time = inStr.time - deltaT;
outStr.RefTime = refTime;
if isfield(inStr, 'imu_time')
outStr.imu_time = inStr.imu_time - deltaT;
if outStr.time(end) < 0
    warning(['Time series finishes before beginning of reference time! Reference time = ' refTime '. Start time = ' outStr.(timeField) '. Time series length = ' num2str(outStr.time(end) - outStr.time(1)) 's.'])
end

end

