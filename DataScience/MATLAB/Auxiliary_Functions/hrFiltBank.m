function [filtHR, fOut] = hrFiltBank(in, samp)
% [out, hrFilt] = hrFiltBank(in, samp)
% Uses a bank of FIR filters to estimate heart rate in beats per minute
% (bpm). Also provides a filtered output with a 1s update rate. Better
% results are obtained if input signal is filtered with hrFilter before
% calling this function.
% 
% Example
% activity = getActivity('5682bdb0adac187e188b4568');
% sweep = getSweep(activity);
% process = sweep2process(sweep);
% ODDiff = process.OD27 - process.OD15;
% hrdata = hrFilter(ODDiff(:,1));
% [fOut, filtHR] = hrFiltBank(hrdata);
%
% Inputs
% in - input vector
% samp - sampling rate (Hz). Default = 20
%
% Outputs
% filtHR - filtered heart rate (bpm) - moving-average filter.
% fOut - hear rate estimate (bpm)
%
% See also
% hrFilter
%
% P. Silveira, Jan. 2016
% BSX Athletics Proprietary

if ~exist('samp', 'var')
    samp = 20;   % default sampling rate = 5Hz
end

% FIR least-squares Bandpass filter designed using the FIRLS function.

% All frequency values are in Hz.

% Constants
HR_MAX = 180;   % max heart rate (BPM)
HR_MIN = 40;    % min heart rate (BPM)
UPDATE_RATE    = 5; % update rate (seconds)
fOrder      = 5*samp;   % filter order (number of taps in delay line)
Wstop1 = 1;    % First Stopband Weight
Wpass  = 2;    % Passband Weight
Wstop2 = 1;    % Second Stopband Weight
N = length(in);
sz = size(in);

%% Create filter bank
Flow = HR_MIN/60;                       % Lowest cutoff freq, 26 bpm
Fhigh = min([HR_MAX/60 samp/2*.92]);   % limit high cutoff frequency to the smaller of 240bpm or 92% of Nyquist
Nfilters = 16;                       % filter banks. Increase for accuracy but slower processing speed.

Finc = (Fhigh-Flow) / Nfilters;
for ii = 1:Nfilters
    Fstop1 = Flow + (ii-1)*Finc - 0.1;
    Fpass1 = Flow + (ii-1)*Finc;
    Fpass2 = Fpass1 + Finc;
    Fstop2 = Fpass2 + 0.1;
    freq(ii) = (Fpass1 + Fpass2)/2;
    
    b  = firls(fOrder, [0 Fstop1 Fpass1 Fpass2 Fstop2 samp/2]/(samp/2), [0 0 1 1 0 0], [Wstop1 Wpass Wstop2]);
    Hd(ii) = dfilt.dffir(b);
    
    out(ii,:,:) = filter(Hd(ii), in);
%    out(ii,1:2*fOrder,:) = NaN;   % ignore first samples

end

%% Identify highest frequency output
% out = abs(avgfiltNaN(out, UPDATE_RATE*samp));
% [maxVal, maxInd] = max(out,[],1);
% % Find next highest frequency
% temp = out;
% temp(maxInd,:,:) = NaN;
% [maxVal2, maxInd2] = max(temp,[],1);
% % Interpolate
% fOut = (freq(maxInd) .* maxVal + freq(maxInd2) .* maxVal2) ./ (maxVal+maxVal2);
% fOut = fOut*60; % convert from Hz to bpm

for jj = 1:N
    if jj <= UPDATE_RATE*samp
        slice = [1:jj];
    else
        slice = [jj-UPDATE_RATE*samp:jj];   % deal with initial samples
    end
%   pOut = max(out(slice),[],2);   % winner-take-all
    temp = out(:,slice,:) - repmat(mean(out(:,slice,:),2),1,length(slice));
    power = diag(temp * temp');
    pOut = power; %max(power,[],2);   % winner-take-all
    [maxVal, maxInd] = sort(pOut, 'descend');
    if maxInd(2) == maxInd(1)+1 || maxInd(2) == maxInd(1)-1 % interpolate if neighboring peaks found
        fOut(jj) = (freq(maxInd(1)) * maxVal(1) + freq(maxInd(2)) * maxVal(2)) / (maxVal(1)+maxVal(2));
    else
        fOut(jj) = freq(maxInd(1));
    end
end
fOut = fOut' * 60;   % convert from Hz to bpm
filtHR = round(avgfiltNaN(fOut, UPDATE_RATE*samp));    % filtered heart rate
%filtHR = round(medfiltNaN(fOut, UPDATE_RATE*samp));


