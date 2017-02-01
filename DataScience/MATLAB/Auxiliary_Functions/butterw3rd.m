function y = butterw3rd(x, samp_rate)
% function y = butterw3rd(x, samp_rate) Filters input x at sampling rate samp_rate and returns output y.
% If not defined, default samp_rate = 5 (Hz).
% NaN values in the input are retained in the output, keeping the same
% array length.
%
% P. Silveira, June 2015
% BSX Proprietary

n = 3;  % filter order
T = 5; % filtering time constant (s)

if ~exist('samp_rate', 'var')
    samp_rate = 5; % default sampling rate = 5Hz
end

Wn = (1/T) / samp_rate/2; 

[z,p,k] = butter(n,Wn);
%[b,a] = butter(n,Wn);
sos = zp2sos(z,p,k);
%[A,B,C,D] = butter(n,Wn);
x = single(x);  % convert to single-precision (to mimic microprocessor output)
%y = sosfilt(sos, x);

temp = isfinite(x);
index = find(temp);  % index of valid entries (not NaN)
y(index) = sosfilt(sos, x(temp)); % Second-order (biquadratic) IIR digital filtering
y(find(~isfinite(x))) = NaN;

% s(n) = A*s(n-1)+B*x(n-1);
% y(n-1) = C*s(n-1)+D*x(n-1);




