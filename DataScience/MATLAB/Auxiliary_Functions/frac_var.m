function [ out ] = frac_var( base, new )
% function [ out ] = frac_var( base, new )
% Calculates the fraction variation of a new values wrt to the base value,
% in percentage points. base and new may be vectors or matrices, as long as
% they are of the same dimensions.
%
% Inputs
% base - baseline value.
% new - new value
%
% Output
% out - fractional variation of new value wrt to base (%)
%
% P. Silveira, Jan. 2016
% BSX Proprietary

out = (new - base) ./ base *100;


end

