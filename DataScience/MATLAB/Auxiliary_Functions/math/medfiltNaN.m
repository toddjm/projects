function [ out ] = medfiltNaN( in, filter_length )
% function [ out ] = medfiltNaN( in, filter_length )
% Function used to perform median filter in the presence of NaNs
%
% Inputs
% in - input array
% filer_length - median filter length (samples)
%
% Outputs
% out - median-filtered output array. Out is always converted to double.
% Original NaNs in input are placed back at the same index positions.
%
% See also
% medfilt1
%
% P. Silveira, May 2015
% BSX Athletics Proprietary


%     out = double(in);    % convert to double
%     temp = isfinite(in);
%     index = find(temp);  % index of valid entries (not NaN)
%     out(index) = medfilt1(double(in(index)),filter_length); % median filter, ignoring NaNs
%     out(find(~isfinite(in))) = NaN; % remove this step if you want to "fill in the blanks"

    ind = isfinite(in);
    out(ind) = medfilt1(double(in(ind)), double(filter_length));
    out(isnan(in)) = NaN; % remove this step if you want to "fill in the blanks"


