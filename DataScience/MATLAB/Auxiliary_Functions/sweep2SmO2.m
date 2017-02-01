function [ SmO2, HbF, HbConc, pH2O ] = sweep2SmO2( sweep, device )
% OBSOLETE: Use sweep2process instead!
%
% function [ SmO2, HbF, HbConc, pH2O ] = sweep2SmO2( sweep, device )
%  Calculates SmO2 from a sweep file. Uses Default parameters and simulates
%  value repetetion by 1/sweep.samp_rate (as performed by the device).
%
% Example
% sweep = getSweep('55dd03bf07c519cf748b4569');  % request a sweep structure from an assessment from the server 
% SmO2 = sweep2SmO2(sweep);     % Calculates SmO2 using Default parameters
%
% Inputs
% sweep - sweep structure (see getSweep.m)
% device - (optional) device structure. See getDevice. If not provided,
% sweep2SmO2 uses device = getDevice(sweep.device_id). Useful when calling
% this function multiple time using the same device. ATTENTION: if
% provided and the device is different, sweep2SmO2 issues a warning.
%
% Outputs
% SmO2 - vector with SmO2 values calculated during sweep. Time vector is
% provided by sweep.time
% HbF - Vector with fraction of hemoglobin in tissue.
% HbConc - vector with Hb concentration values. HbF and HbConc are issued
% by function used to detect tissue: istissue(HbF, HbConc)
% pH2O - vector with fraction of water in tissue
% 
% See also
% getSweep, getDevice, getAllCnt, calc_SmO2, istissue and processSmO2
%
% P. Silveira, Oct. 2015
% BSX Proprietary

if ~exist('device', 'var')
    device = getDevice(sweep.device_id);
    if ~strcmp(device.device_id, sweep.device_id)
        warning(['Sweep used device ' sweep.device_id ' and function was requested to use device ' sweep.device_id ' instead.'])
    end
end
[AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, 1 ); % get most recent device calibration data
[OD15, OD27] = processCounts(sweep, AllCnt, lookup_current);
[rawSmO2, Resid, mu_eff, HbF, Pk] = calc_SmO2(OD27-OD15);
pH2O = Pk(:,3);
HbConc = 5e4*HbF./pH2O;
ppSmO2 = processSmO2(rawSmO2);   % post-process
% Decimate while keeping sampling rate
full_length = length(ppSmO2);
decimated_ind = [1:sweep.samp_rate:full_length];
decSmO2 = ppSmO2(decimated_ind);    % simple (but not exact) decimation
x = linspace(sweep.time(1),sweep.time(end), length(decSmO2));   % grid points where decSmO2 is defined
xq = linspace(sweep.time(1), sweep.time(end), full_length);     % grid points where SmO2 should be defined
SmO2 = interp1(x, decSmO2, xq, 'nearest');
SmO2 = SmO2';

end

