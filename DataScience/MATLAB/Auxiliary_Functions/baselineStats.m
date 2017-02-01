function [ out ] = baselineStats( x, RANGE )
% function [ out ] = baselineStats( x, RANGE )
%  Calculates baseline and other stats about input vector x. Returns a
%  structure with calculated results.
%
% Inputs
% x - input vector
% RANGE - indices with range of x values over which baseline median value
% is to be calculated. Default = entire x vector.
%
% Outputs
% out.baseline - median value of x within RANGE. Ignores non-finite values.
% out.average - average value of x from beginning of range to end of x.
% out.std - standard deviation of x from beginning of range to end of x.
% out.median - median value of x from beginning of range to end of x.
% Ignores non-finite values.
% out.min_prctile - 1-percentile of x from beginning of range to end of x. Ignores non-finite values.
% out.max_prctile - 99-percentile of x from beginning of range to end of x. Ignores non-finite values.
% out.delta_prctile = out.max_prctile-out.min_prctile
% out.max - absolute maximum over entire input range. Numeric values only (ignores NaN and Inf values).
% out.min - absolute minimum over entire input range. Numeric values only (ignores NaN and Inf values).
% out.delta = out.max-out.min
% out.lif - lower inner fence over entire input range.
% out.uif - upper inner fence over entire input range.
% out.iqd - inter-quartile difference over entire input range.
%
% P. Silveira, Sep. 2015
% BSX Proprietary


% Constants
MIN_PRCTILE = 1;    % minimum percentile
MAX_PRCTILE = 99;   % maximum percentile

x = x(:);   % transform into a row vector

if ~exist('RANGE', 'var')
    RANGE = [1:length(x)];  % set default value
else if isempty(RANGE) || RANGE(end) > length(x)
        out = [];   % return empty variable if RANGE is larger than input vector
        return
    end
end

valid_ind = find(isfinite(x));  % list of valid (numeric) indices
VALID_RANGE = valid_ind(valid_ind >= RANGE(1) & valid_ind <= RANGE(end));   % list of valid indices within RANGE

out.baseline = median(x(VALID_RANGE)); % calculate baseline from median, ignoring non-numeric values
y = x(RANGE(1):RANGE(end));    % y represents the part of x from the beginning of RANGE to end of x.
y = y(isfinite(y)); % remove non-numeric values
out.average = mean(y);  % calculate mean without non-numeric entries
out.std = std(double(y));   % calculate standard deviation without non-numeric entries.
out.median = median(y);
if isempty(y)
    out.min = NaN;
    out.max = NaN;
    out.delta = NaN;
    out.min_prctile = NaN;
    out.max_prctile = NaN;
    out.delta_prctile = NaN;
    out.lif = NaN;
    out.uif = NaN;
    out.iqd = NaN;
else
    out.min = min(y);  % absolute maximum of numeric entries, starting from the beginning of RANGE
    out.max = max(y);
    out.delta = out.max-out.min;
    out.min_prctile = prctile(y,MIN_PRCTILE);    % prctile automatically takes care of non-numeric entries
    out.max_prctile = prctile(y,MAX_PRCTILE);
    out.delta_prctile = out.max_prctile-out.min_prctile;
    [out.lif, out.uif, out.iqd] = fences(y');  % calculate lower inner fence and upper inner fence
end



end

