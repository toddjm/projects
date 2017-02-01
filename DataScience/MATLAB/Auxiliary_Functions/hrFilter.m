function [out, Hd] = hrFilter(in, samp, type)
% [out, hrFilt] = hrFilter(in, samp)
% Function used to filter PPG signal to extract heart rate information
%
% Inputs
% in - input vector
% samp - sampling rate. Default = 20
% type - filter type. 'FIR' (default) or 'IIR'. Currently, if any of the
% input values is NaN, all subsequent output values will be NaN when using
% an IIR filter. Remove NaNs before calling this function to avoid this
% behavior, or use the FIR filter instead.
%
% Outputs
% out - filtered output
% hrFilt - FIR filter generated

%% Initialization
if ~exist('samp', 'var')
    samp = 20;   % default sampling rate
end

if ~exist('type', 'var')
    type = 'FIR';
end

%in = in - mean(in(isfinite(in)),1); % normalize input signal
%in = in ./ (max(in,[],1) - min(in,[],1));

%% Build the filter

% FIR least-squares Bandpass filter designed using the FIRLS function.
% All frequency values are in Hz.
Fstop1 = 0.6;  % First Stopband Frequency
Fpass1 = 0.65;  % First Passband Frequency
if samp < 8    % highest frequencies are dependent on sampling rate
    Fpass2 = 2.2;  % Second Passband Frequency
    Fstop2 = 2.4;  % Second Stopband Frequency
else    % Highest possible HR should limit max freq if sampling frequency is high enough
    Fpass2 = 3.5;
    Fstop2 = 3.7;
end
switch type
    case 'FIR'
        Wstop1 = 1;    % First Stopband Weight
        Wpass  = 2;    % Passband Weight
        Wstop2 = 1;    % Second Stopband Weight
        N      = 5*samp;   % Order (5s filter)
        % Calculate the coefficients using the FIRLS function.
        b  = firls(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 samp/2]/(samp/2), [0 0 1 1 0 0], [Wstop1 Wpass Wstop2]);
        Hd = dfilt.dffir(b);
    case 'IIR' % FAILS is any input is NaN. Remove NaNs before calling this function.
        Astop1 = 30;          % First Stopband Attenuation (dB)
        Apass  = 1;           % Passband Ripple (dB)
        Astop2 = 20;          % Second Stopband Attenuation (dB)
        match  = 'stopband';  % Band to match exactly
        % Construct an FDESIGN object and call its CHEBY2 method.
        h  = fdesign.bandpass(Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, Astop2, samp);
        Hd = design(h, 'cheby2', 'MatchExactly', match);
        N = length(Hd.sosMatrix);   % find filter order
end

%% Filtering operation
if length(in) >= 2*N    % handle exception: input vector is too short
    out = filter(Hd, in);
    out(1:2*N) = in(1:2*N);   % remove invalid data points
else
    warning(['Input vector too short! Only ' num2str(length(in)) ' elements. No filtering performed.']) 
    out = in;
end
