function [ range_ind ] = findRange( in, start, finish )
% function [ range_ind ] = findRange( in, start, finish )
%  Returns a vector with indices of input vector in that lie between values
%  start and finish. start may also be a vector, in which case start is
%  given by its first element and finish is given by its last element.
%
% Example
% time = linspace(0,100,500);   % create a time vector with 500 elements ranging from 0s to 100s in 1/5s increments.
% range_ind = findRange(time, 2, 10);   % find indices of time that lie
% between 2s and 10s
%
% Inputs
% in - input array. Usually (but not necessarily) a vector with values that are
% monotonically increasing.
% start - start value. May be a scalar or an array, in which case finish =
% start(end) and start = start(1);
% finish - finish value. Usualy an integer but can also be set to 'end' to
% indicate the end of the in array. If start is scalar, finish = 'end' by
% default.
%
% Outputs
% range_ind - vector containing indices of in that fall between start and
% finish, inclusive.
%
% P. Silveira, Sep. 2015
% BSX Proprietary

if nargin < 2
    error('Need to provide at least an input vector and a range vector.')
end

if nargin < 3
    if numel(start) > 1
        finish = start(end);
    else
        finish = numel(in);
    end
    start = start(1);
end

if strcmp(finish, 'end')
    finish = numel(in);
end

range_ind = find(in >= start & in <= finish);

end


