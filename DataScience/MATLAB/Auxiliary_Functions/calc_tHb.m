function [ tHb ] = calc_tHb( HbF, filter_length )
% function [ tHb ] = calc_tHb( HbF, filter_length )
% Returns the total hemoglobing index (tHb) from the hemoglobin fraction
% (HbF), calculated by calc_SmO2 (g/dL). results are rounded to 0.01g/dL,
% as required by the ANT+ Muscle Oxygenation standard.
%
% Inputs
% HbF - vector containing fraction of hemoglobin in tissue. Calculated by
% calc_SmO2 function.
% filer_length - length of averaging filter (samples). Default = 15. Use
% zero to force no filtering.
%
% Outputs
% tHb - vector contaiing total hemoglobin concentration (g/dL).
%
% See also
% calc_SmO2, sweep2process
%
% P. Silveira, Nov. 2015
% BSX Proprietary

%% Constants
HbFMAX = 3.6461509e-04; % 3.6461509e-04 is the maximum value from 755 assessments from the server, (assessment id 55f0caaaadac18be348b457f).
HbFMIN = 0.28173e-04; % 0.28173e-4 is the minimum value from 755 successful assessments from the server (assessment id 552f1cb8adac18f20e8b5195). (assessment 55cbc1cbadac1824688b458c was 0.1426e-4 but doesn't look real, and assessment 55a43175adac1877068b46d5 had a value of 0.20576e-4 but is defective)
HbFMEAN = 1.3492341e-04; % mean HbF value from 755 assessments from server. median = 1.3348546e-04 
DIGITS = 2; % number of decimals to be included in output (0.01g/dL resolution)

tHbMIN = 11;    % typical minimum tHb value (g/dL)
tHbMAX = 18;    % typical maximum tHb value (g/dL)

UPPER_LIMIT = 33;   % tHb upper limit (g/dL)
LOWER_LIMIT = 0;    % tHb lower limie (g/dL)

%% Parsing

if ~exist('filter_length', 'var')
    filter_length = 15;
end

%% Processing

slope =  (tHbMAX - tHbMIN) / (HbFMAX - HbFMIN);
inters = (tHbMIN*HbFMAX - tHbMAX*HbFMIN) / (HbFMAX - HbFMIN);

tHb = HbF * slope + inters;

%% Post-processing

if filter_length > 1
    tHb = avgfiltNaN(tHb, filter_length);
end
tHb = round(tHb * 10^DIGITS)/10^DIGITS;

% Enforce max and minimum values
tHb(tHb > UPPER_LIMIT) = UPPER_LIMIT;
tHb(tHb < LOWER_LIMIT) = LOWER_LIMIT;


