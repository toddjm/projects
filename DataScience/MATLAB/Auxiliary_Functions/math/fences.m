function [ lif, uif, iqd ] = fences( in )
% function [ lif, uif, iqd ] = fences( in )
% Calculates fence values of array in. Values are considered outliers if
% they are < lif (lower inner fence) or > uif (upper inner fence).
% See https://docs.tibco.com/pub/spotfire/5.5.0-march-2013/UsersGuide/stat/stat_adjacent_values_and_outliers.htm
%
% Inputs
% in - array with values. Analysis is performed in the highest dimension of
% in.
%
% Outputs
% lif - lower inner fence = q1 - 1.5*(q3-q1), where q1 and q3 are the
% 25 and 75 percentiles of input array.
% uif - upper inner fence = q3 + 1.5*(q3-q1), where q1 and q3 are the
% 25 and 75 percentiles of input array.
% iqd - inter-quartile difference = q3-q1
%
% P. Silveira, June 2015
% BSX Proprietary

nd = ndims(in);

q1 = prctile(in,25,nd); % first quartile
q3 = prctile(in,75,nd); % 3rd quartile
iqd = q3-q1;
range = 1.5*iqd;    % interquartile range
lif = q1-range;
uif = q3+range;

end

