function axistight(x, mult)
% function axistight(x, mult)
%   Expands y axis of active plot so data fills graphic area. Uses prctile
%   to ignore outliers.
%
% Inputs
% x - data plotted [as in plot(x)].
% mult - multiplier to use when ignoring data. 10*mult of data is ignored.
% Default = 0.035.
%
% Outputs
% none
%
% See also
% axis tight

PRC = 10;   % percentile of data to be ignored in max and min calculation

if ~exist('mult', 'var')
    mult = .035;
end

axis tight
ax = axis;
top = prctile(x,100-PRC);
bottom = prctile(x,PRC);
newax = [ax(1) ax(2) bottom*(1-mult) top*(1+mult)];
if any(isnan(newax))
    axis tight
else
    axis(newax)
end

end

