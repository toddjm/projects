function [ transition, plateau ] = transition( x, time_events, time_vector, time_window, perc_excl )
% function [ transition, plateau ] = transition( time_vector, time_events, x, time_window, perc_excl )
%   Calculates mean transition levels between time events in input vector x. Also
%   calculates plateaus between transitions.
%
% Inputs
%
% x - input vector with temporal transitions
% time_events - vector with time of temporal transitions.
% time_vector - vector describing time of input array, in the same units as time_events. Default: time_vector = 1:length(x);
% time_window - scalar window used to ignore data around transitions. Plateaus are
% calculated between time_vector(ii)+time_window and
% time_vector(ii+1)-time_window. Default = 10
% perc_excl - percentile of data to exclude when calculating trimmean of
% plaeaus. Default = 10% (ignores top and bottom 10% of data when
% calculating average).
%
% Outputs
% transition - vector containing difference between plateaus. Has the same
% length as time_events - 2
% plateaus - average value of plateus defined by time_events. Has the same
% number of elements as time_events - 1.
%
% P. Silveira, Jan. 2016
% BSX Proprietary

if ~exist('time_vector', 'var')
    time_vector = 1:length(x);
end

if ~exist('time_window', 'var')
    time_window = 10;
end

if ~exist('perc_excl', 'var')
    perc_excl = 10;
end

for ii = 1:length(time_events)-2
    ind1 = findRange(time_vector, time_events(ii)+time_window, time_events(ii+1)-time_window);
    ind2 = findRange(time_vector, time_events(ii+1)+time_window, time_events(ii+2)-time_window);
    plateau(ii) = trimmean(x(ind1), perc_excl);
    plateau(ii+1) = trimmean(x(ind2), perc_excl);    
    transition(ii) = plateau(ii+1) - plateau(ii);
end

end

