function y = butterw2stage(x, samp_rate)
% function y = butterw2stage(x, samp_rate) Filters input x at sampling rate samp_rate and returns output y.
% Uses a first stage FIR filter (running average, length = samp_rate) and a
% second stage 3rd order Butterworth filter.
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

%Wn = 2/T;
Wn = (1/T) / samp_rate/2; 
[z,p,k] = butter(n,Wn);
sos = zp2sos(z,p,k);
x = single(x);  % convert to single-precision (to mimic microprocessor output)
temp = isfinite(x);
index = find(temp);  % index of valid entries (not NaN)
y(index) = filter(ones(1,samp_rate)/samp_rate,1,x(temp));   % first stage average filter
y(index) = sosfilt(sos, y(index)); % Second-order (biquadratic) IIR digital filtering
y(find(~isfinite(x))) = NaN;





