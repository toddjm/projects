function [OD15, OD27, AMB_FLG, errLog] = processCounts(sweep, AllCnt, lookup_current, MIN_COUNT_THR, AMB_THR, MAX_COUNT_THR);
% function [OD15, OD27, AMB_FLG] = processCounts(sweep, AllCnt, lookup_current, MIN_COUNT_THR, AMB_THR, MAX_COUNT_THR);
%   Function used to convert device counts into optical densities.
% Takes into account calibration data (in AllCnt) and currents used for
% calibration. Also performs minimum pre-processing of the data.
%
% Example
% assessment = getAssessment('5515958badac18db278b4d27');   % get information for assessment 5515958badac18db278b4d27
% sweep = getSweep(assessment);
% [OD15, OD27] = processCounts(sweep);
%
% Inputs
% sweep - structure with device information. Output by getCSV or getSweep.
% AllCnt - device calibration data. Output by getDevice or getDeviceFile.
% If left blank, function will make a call to getAllCnt(getDevice(sweep.Device_id))
% Default = getAllCnt(getDevice(sweep.Device_id)). That is, AllCnt data
% from most recent calibration.
% lookup_current - vector with lookup table used to convert from current codes to rows in AllCnt matrix.
% If left blank function makes a call to device = getDevice(sweep.Device_id) and
% uses value returned on device.lookup_current
% MIN_COUNT_THR - count threshold. ODs are set to NaN if the counts of any of the LEDs are
% less than MIN_COUNT_THR. Default = 10.
% AMB_THR - ambient light threshold. ODs are set to NaN if the ambient
% light counts > AMB_THR. Default = 20,000.
%
% Outputs
% OD15 - optical densities at 15mm
% OD27 - optical densities at 27mm
% AMB_FLG - vector, same size as sweep, TRUE when ambient light exceeds
% threshold.
% errLog - structure array containing error codes. Returns an empty string if no errors are found.
%       Fields are:
%       sample - optical sample in sweep structure where error was found
%       LED - LED number where error was found
%       ccode - invalid current cound found
%
% See also
% calc_SmO2, getSweep, getCSV, getDevice, getDeviceFile, getCurrents
%
% P. Silveira, Apr. 2015
% BSX Athletics Proprietary

% Initialize
if ~exist('MIN_COUNT_THR', 'var')
    MIN_COUNT_THR = 100;
end
if ~exist('MAX_COUNT_THR', 'var')
    MAX_COUNT_THR = 32766;  % 2^15-2
end
if ~exist('AMB_THR', 'var')
    AMB_THR = 20000;
end
% if ~exist('currents', 'var')
%     currents = getCurrents;
% end
if ~exist('AllCnt', 'var') || isempty(AllCnt) || ~exist('lookup_current', 'var') || isempty(lookup_current)
    [AllCnt, invC15, invC27, lookup_current] = getAllCnt( getDevice(sweep.device_id));
end

if iscell(lookup_current)
    lookup_current = cell2mat(lookup_current);
end

% Map lookup_current values to rows in AllCnt table
current_map = NaN*[1:256];  % set empty cells to NaN
current_map(lookup_current+1) = [1:length(lookup_current)];    % lookup_current length must match first dimension of AllCnt

errCount = 0;
errLog = '';

if isfield(sweep, 'count')  % prototype structure. This simpler and quicker processing method is likely to replace the more cumbersome legacy version in the future.
    sz = size(sweep.ccode);
    codes = current_map(sweep.ccode(:)+1);    % rasterize ccode matrix and map it to rows in AllCnt table
    tot_codes = numel(codes);                   % number of rasterized ccodes
    absorb = NaN*[1:tot_codes];               % make sure that skipped values = NaN
    valid_ind = find(isfinite(codes));         % pick valid values. Unfortunately, invalid ccodes are not such a rare event.
    for ii = 1:length(valid_ind);           % Loop through all rasterized samples
        % For the next step to work correctly the LED channels represented
        % by the columns of ccodes (and counts) must be in the same order
        % as those present in the AllCnt matrix
        absorb(valid_ind(ii)) = AllCnt(codes(valid_ind(ii)),mod(ii+1,sz(2)-1)+1) ./ sweep.count(valid_ind(ii));    % convert every count into an absorption
    end
    absorb = reshape(absorb, sz);           % go back to matrix form
    absorb(sweep.count < MIN_COUNT_THR) = NaN;  % discard values with counts below threshold
    AMB_FLG = find(sweep.ambient > AMB_THR);
    absorb(AMB_FLG,:) = NaN;                  % discard values with ambient light counts above threshold
    OD15 = log10(absorb);                   % convert from absorption to optical density
    errCount = tot_codes - numel(valid_ind); %sum(isnan(ind(:)));          % count number of 
    if errCount && nargout > 3
        errLog.sample = find(isnan(codes));
        errLog.ccode = sweep.ccode(isnan(codes));
    end
else
    % Use calibration data to convert from counts to absorbances
    sz = size(sweep.count15);
    num_leds = sz(2);   % find number of LEDs
    % for ii = 1:numel(sweep.time),
    %     for wl = 1:num_leds,
    %         [temp, ind15] = min(abs(sweep.current15(ii,wl) - currents));   % find index location of current values
    %         [temp, ind27] = min(abs(sweep.current27(ii,wl) - currents));
    %         absorb15(ii,wl) = AllCnt(ind15,wl)./ sweep.count15(ii,wl); % absorbance
    %         absorb27(ii,wl) = AllCnt(ind27,wl+num_leds)./ sweep.count27(ii,wl);
    %     end
    % end
    for ii = 1:numel(sweep.time),
        for wl = 1:num_leds,
            ind15 = find(sweep.ccode15(ii,wl) == lookup_current);   % find index location of current values
            ind27 = find(sweep.ccode27(ii,wl) == lookup_current);
            if isempty(ind15)   % watch out for invalid ccodes
                if ~errCount
                    warning(['At least one invalid ccode found on assessment ' sweep.assessment ', device ' sweep.device_id ])
                end
                %            warning(['Invalid ccode = ' num2str(sweep.ccode15(ii,wl)) ' found at 15mm geometry, sample ' num2str(ii)])
                absorb15(ii,wl) = NaN;
                errCount = errCount+1;
                errLog(errCount).sample = ii;
                errLog(errCount).LED = wl;
                errLog(errCount).ccode = sweep.ccode15(ii,wl);
            else
                absorb15(ii,wl) = AllCnt(ind15,wl) ./ sweep.count15(ii,wl);
            end
            if isempty(ind27)
                if ~errCount
                    warning(['At least one invalid ccode found on assessment ' sweep.assessment ', device ' sweep.device_id ])
                end
                %            warning(['Invalid ccode = ' num2str(sweep.ccode27(ii,wl)) ' found at 27mm geometry, sample ' num2str(ii)])
                absorb27(ii,wl) = NaN;
                errCount = errCount+1;
                errLog(errCount).sample = ii;
                errLog(errCount).LED = wl+num_leds;
                errLog(errCount).ccode = sweep.ccode15(ii,wl);
            else
                absorb27(ii,wl) = AllCnt(ind27,wl+num_leds) ./ sweep.count27(ii,wl);
            end
        end
    end
    
    % Pre-process data
    absorb15(find(sweep.count15 < MIN_COUNT_THR)) = NaN;  % discard values with counts below threshold
    absorb27(find(sweep.count27 < MIN_COUNT_THR)) = NaN;  % discard values with counts below threshold
    absorb15(find(sweep.count15 > MAX_COUNT_THR)) = NaN;  % discard values with counts above threshold
    absorb27(find(sweep.count27 > MAX_COUNT_THR)) = NaN;  % discard values with counts above threshold
    absorb15(absorb15<=0) = NaN;    % discard negative absorption values (usually caused by negative AllCnt values)
    absorb27(absorb27<=0) = NaN;
    AMB_FLG = find(sweep.ambient > AMB_THR);
    absorb15(AMB_FLG,:) = NaN;  % discard values with ambient light counts above threshold
    absorb27(AMB_FLG,:) = NaN;  % discard values with ambient light counts above threshold
    
    % Convert to OD
    OD15 = log10(absorb15);
    OD27 = log10(absorb27);
end

% Output list of errors
if errCount
    warning([ num2str(errCount) ' errors found on assessment ' sweep.assessment ', device ' sweep.device_id '. Call [~,~,~,errLog] = processCounts(sweep) for a structure array with complete list of errors!'])
end

end

