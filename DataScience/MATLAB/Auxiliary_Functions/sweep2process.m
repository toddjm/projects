function process = sweep2process( sweep, device, chkout )
% function process = sweep2process( sweep, device, chkout )
%  Calculates process structure from a sweep file structure. Uses Default
%  parameters.
%
% Example
% sweep = getSweep('55dd03bf07c519cf748b4569');  % request a sweep structure from an assessment from the server
% SmO2 = sweep2SmO2(sweep);     % Calculates SmO2 using Default parameters
%
% Inputs
% sweep - sweep structure (see getSweep.m)
% device - (optional) device structure. See getDevice. If not provided,
% sweep2process uses device = getDevice(sweep.device_id). Useful when calling
% this function multiple time using the same device. ATTENTION: if
% provided and the device is different, sweep2process issues a warning.
% chkout - checkout number. Default = 1 (most recent).
%
% Outputs
% process - structure of processed sweep with the following fields
%        OD15 - optical density of 15mm distance
%        OD27 - optical density of 27mm distance
%       Resid - residual of fit using multivariate analysis
%      mu_eff - effective absorption coefficient of each LED
%          Pk - solution of multivariate fit
%        mu_s - reduced scattering coefficients.
%        mu_a - absorption coefficients for each LED
%        pH2O - water concentration (3rd column of Pk)
%         HbF - total hemoglobin coefficient (sum of 1st and 2nd columns of Pk)
%      HbConc - Hb concentration (old method)
%         tHb - total hemoglobin (g/dL)
%    pH2Oproj - vector projection towards water spectrum after fit using Hb spectra
%     pH2Ocos - angle cosine towards water spectrum after fit using Hb spectra
%        SmO2 - tissue oxygenation (%)
%    tissueTF - boolean indicating whether tissue is detected
%      tissue - length of tissue detection error vector
%          HR - heart rate calculated from optical signals (bpm)
%         Acc - acceleration magnitude squared (g^2), decimated to same sampling rate as optical data.
%        Gyro - angular velocity magnitude squared (deg^2/s^2), decimated to same sampling rate as optical data.
%        date - date when sweep processing was executed
%
% See also
% getSweep, getDevice, getAllCnt, calc_SmO2, istissue and processSmO2
%
% P. Silveira, Jan. 2016
% BSX Proprietary

%% Initialization

TISSUE_FILTER_LENGTH = 3;    % length of filter (seconds)
HYDRATION_FILTER_LENGTH = 59;   % length of hydration filter (seconds)

if ~exist('chkout', 'var')
    chkout = 1;
end

if ~exist('device', 'var')
    device = getDevice(sweep.device_id);
    if ~strcmp(device.device_id, sweep.device_id)
        warning(['Sweep used device ' sweep.device_id ' and function was requested to use device ' sweep.device_id ' instead.'])
    end
end

%% Processing

[AllCnt,invC15,invC27, lookup_current] = getAllCnt( device, chkout ); % get designated device calibration data
[process.OD15, process.OD27] = processCounts(sweep, AllCnt, lookup_current);
ODDiff = process.OD27-process.OD15;
[rawSmO2, process.Resid, process.mu_eff, HbF, process.Pk, process.mu_s, process.mu_a] = calc_SmO2(ODDiff);
ppSmO2 = processSmO2(rawSmO2, [], [], TISSUE_FILTER_LENGTH*sweep.samp_rate);   % post-process SmO2
process.pH2O = avgfiltNaN(process.Pk(:,3), HYDRATION_FILTER_LENGTH*sweep.samp_rate);
process.HbF = avgfiltNaN(HbF, TISSUE_FILTER_LENGTH*sweep.samp_rate);   % LPF total hemoglobin
process.HbConc = 5e4*process.HbF./process.pH2O; % hemoglobin concentration (old method)
process.tHb = calc_tHb(process.HbF, TISSUE_FILTER_LENGTH*sweep.samp_rate);    % includes LPF
[pH2OprojRaw, pH2OcosRaw] = calc_hydration(ODDiff);
process.pH2Oproj = avgfiltNaN(pH2OprojRaw, HYDRATION_FILTER_LENGTH*sweep.samp_rate);
process.pH2Ocos = avgfiltNaN(pH2OcosRaw, HYDRATION_FILTER_LENGTH*sweep.samp_rate);

% Decimate SmO2 while keeping sampling rate
full_length = length(ppSmO2);
decimated_ind = [1:sweep.samp_rate:full_length];
decSmO2 = ppSmO2(decimated_ind);    % simple (but not exact) decimation
x = linspace(sweep.time(1),sweep.time(end), length(decSmO2));   % grid points where decSmO2 is defined
xq = linspace(sweep.time(1), sweep.time(end), full_length);     % grid points where SmO2 should be defined
SmO2 = interp1(x, decSmO2, xq, 'nearest');
process.SmO2 = SmO2';
[process.tissueTF, process.tissue] = istissue(process.HbF,process.HbConc);

% IMU data: calculate magnitude and resample to same rate as optical data
if isfield(sweep, 'Acc_y') && ~isempty(sweep.Acc_y)
    process.Acc = magResamp(sweep.Acc_y, sweep.Acc_z, sweep.samp_rate, sweep.imu_samp_rate, length(sweep.time));
end
if isfield(sweep, 'Gyro_x') && ~isempty(sweep.Gyro_x)
    process.Gyro = magResamp(sweep.Gyro_x, sweep.Gyro_y, sweep.samp_rate, sweep.imu_samp_rate, length(sweep.time));
end

% Heart rate
temp = OD2trans(process);
ppg = hrFilter(temp.hrComb, sweep.samp_rate);   % Filter pleth signal
%process.HR = hrFiltBank(ppg,sweep.samp_rate);
process.HR = hrBayesianFilter(ppg, process.Acc, sweep.samp_rate);   % estimate HR from PPG

% Record processing date
process.date = date;

end

% Function used to calculate amplitude, resample and remove NaNs
function z = magResamp(x, y, orig_samp, new_samp, new_len)
if orig_samp ~= new_samp
    orig_samp = double(orig_samp);  % convert to double
    new_samp = double(new_samp);
    x2 = resample(double(x), orig_samp, new_samp);
    y2 = resample(double(y), orig_samp, new_samp);
else    % same sampling rates. No resampling required.
    y2 = y;
    x2 = x;
end
temp = y2.^2 + x2.^2;   % calculate magnitude squared
temp2 = single(temp(isfinite(temp)));   % remove NaNs and convert back to single
sizeDiff = length(temp2) - new_len; % vector size difference
if sizeDiff > mod(orig_samp, new_samp)  % ok to have a small size difference
    warning(['Resampled vector too long. Original length = ' num2str(length(temp2)) '. Cropping to ' num2str(new_len) ' samples.'])
end
if sizeDiff >= 0
    z = temp2(1:new_len);   % crop by a few samples
elseif sizeDiff < 0  % more optical data than IMU data (rare)
    z = temp2;
    z(end:end-sizeDiff) = NaN;   % pad with a few NaNs. Remember that sizeDiff is negative!
end

end



