function [ ind ] = findPauseEnd(pause_bit)
% function [ ind ] = findPauseEnd(pause_bit)
% Function used to find index indicating end of the last pause.
% 
% Inputs
% pause_bit - array with pause bit, in which a high value indicates a
% pause, a low value indicates no pause.
%
% Outputs
% ind - array index indicating end of last pause on pause_bit
%
% P. Silveira, Dec. 2015
% BSX Proprietary

indList = find(diff(pause_bit) < 0);
ind = indList(end)+1;

end

