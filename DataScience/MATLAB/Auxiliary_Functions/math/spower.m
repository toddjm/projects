function [ s ] = spower( x )
% spower - calculates power of any array
% Ignores NaNs.

x2 = x(~isnan(x));
N = numel(x2(:));

s = x2(:).'*x2(:) / N;

end

