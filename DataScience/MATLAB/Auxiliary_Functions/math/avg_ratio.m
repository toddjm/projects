function [ ratio ] = avg_ratio( in, range )
% function [ ratio ] = avg_ratio( in, range )
%   Calculates the ratio of input array in over its average over the range
%   of indices defined by range. Useful when determining relative changes.
%
% Example
% ratio = avg_ratio(in, [10:20])
%
% Inputs
% in - input array
% range - range of indices over which average is to be calculated
%
% Outputs
% ratio - in divided by its mean value over the defined range
%
% P. Silveira, July 2015
% BSX Proprietary

ratio = in ./ repmat(mean(in(range,:)), length(in), 1);

end

