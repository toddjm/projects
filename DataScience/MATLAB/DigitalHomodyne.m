% Script created to simulate digital homodyne modulation/demodulation.

clear
close all

% Constants
wavel = getLeds;    % LED wavelengths
N = 8;  % # of LEDs
fOrder = 4; % detection filter order
samp_rate = 192000; %f_max*4;    % make sure to prevent aliasing.
t_end = 0.021328125; %0.021333333333333; % end of time sequence (s) Select 0.021328125s for 4096 samples @ 192000Hz sampling rate
f_min = 19200;  % minimum frequency (Hz)
f_sep = 9600;   % center frequency separation (Hz)
f_max = f_min+(N-1)*f_sep; % max. frequency (Hz)
BPmin = f_min/10; % bandpass minimum frequency (Hz)
BPmax = samp_rate/2-500; % bandpass maximum frequency (Hz)
G = 1e7;    % TIA gain
Vref = 1.5; % ADC reference voltage
%TB = (f_max-f_min) * t_end;
%fprintf('Temporal-bandwidth product = %.1f.\n', TB)
%W = [f_min f_max] / samp_rate;  % bandpass filter frequencies
t_offset = 3/BPmin; % 2e-3;    % filter settling time (s)
SNR = 20;  % signal to noise ratio (dB). Used to define AGWN power.
samples = round(samp_rate*t_end);
ambHf = 120;    % ambient interference high-freq. (Hz)
HfAmbInt = -3; % ambient interference high-freq. level wrt signal power (dB)
ambLf = 2;     % ambient int. low-freq. (Hz)
LfAmbInt = -26;  % ambient light level, compared to signal power (dB);
Lfm = 0.5;      % Low-feq. modulation depth
Hfm = 0.1;      % high-freq. modulation depth
ADCbits = 10;   
DAbits = 1;
jitter = 0; %.01;   % amount of time jitter (proportional to sampling time). Zero for no jitter.
rng(1); % initilize pseudo-random number generator with a known seed
pptSave = strcmp(questdlg('Save to PowerPoint?'), 'Yes');
nomStd =   [   % nominal detected auto-correlation of each LED (found during calibration)
    0.2136
    0.2515
    0.3019
    0.3344
    0.2039
    0.2664
    0.2900
    0.3210];

% Signal

%freqs = samp_rate*[-0.5 : 1/(2*samples-1) : 0.5]; %linspace(-samp_rate/2,samp_rate/2,fft_size);    % frequencies (Hz)
fft_size =  2^(ceil(log(samples)/log(2)));    % pick next power of 2
freqs = linspace(0, samp_rate/2, fft_size/2+1);
[~, fminInd] = min(abs(freqs-f_min));   % find closest permissible values for f_min and f_max
f_min = freqs(fminInd);
[~, fmaxInd] = min(abs(freqs-f_max));
f_max = freqs(fmaxInd);
f_sep = (f_max - f_min ) / (N-1);
fprintf('Smallest tone frequency = %.1fHz. Largest tone frequency = %.1fHz. Separation freq. = %.1fHz.\n', f_min, f_max, f_sep)
t = linspace(0, t_end, samples); % time series
f = [f_min:f_sep:f_max]'; % linspace(f_min, f_max, N)';
for ii = 2:N-1  % pick permissible frequency bins
    [~, fInd] = min(abs(freqs-f(ii)));
    f(ii) = freqs(fInd);
end

sqw = sin(2*pi*f*t)+1;   % tones
sqw = rand(N, samples);  % uniform pseudo-random sequence
%temp = hadamard(N);
%sqw = [repmat(temp, 1, floor(samples/N)) temp(:,1:N-1)].* sqw;  % converts sqw into N ortoghonal codes (N must be a multiple of 4)
sqw = round(sqw ./ max(sqw(:)) * (2^DAbits-1)); % digitize
RMSs = rms(sqw(:));  % signal rms amplitude
sqw_transmitted = sqw;
%sqw_transmitted(5,:) = 0; % sanity check. Remove one LED

fsqw = fftshift(fft(fftshift(sqw_transmitted), fft_size, 2));

% Noise
noise = rand(size(sqw_transmitted));
noise = noise ./ rms(noise(:)) .* RMSs / (10.^(SNR/20));    % normalize wrt desired SNR

% Ambient
ambientLf = cos(2*pi*ambLf*t)*Lfm+1;
ambientLf = ambientLf ./ rms(ambientLf) .* RMSs / (10.^(LfAmbInt/10));
ambientHf = cos(2*pi*ambHf*t)*Hfm+1;
ambientHf = ambientHf ./ rms(ambientHf) .* RMSs / (10.^(HfAmbInt/10));
ambient = ambientHf+ambientLf;

% Detection
R = 1e-15;             % tissue transmission
transmitted = R.*(sqw_transmitted+noise+repmat(ambient, N, 1));
Resp = [PD_resp(wavel(1:ceil(N/2))') ; PD_resp(wavel(1:ceil(N/2))')];  % PD responsivity (A/W)
detected = sum(transmitted .* repmat(Resp, 1, samples),1);
if jitter
    fprintf('Jitter = .1%f percent of sampling time.\n', jitter*100)
    jitter_fraction = (rand(1,samples)-.5)*jitter;  % jitter (fraction of full revolution)
    jitter_phase = exp(-2*pi*i*jitter_fraction);
    temp = fft(detected) .* jitter_phase;
    detected = abs(ifft(temp));
end
% [z, p, k] = butter(fOrder, W, 'bandpass', 's'); % design filter
% sos = zp2sos(z,p,k);
% [b, a] = zp2tf(z,p,k);
h  = fdesign.bandpass('N,F3dB1,F3dB2', fOrder, BPmin, BPmax, samp_rate);
Hd = design(h, 'butter');   % generate filter

filtered = G*filter(Hd, detected);  % Volts
% consider including offset subtraction prior to digitization
% Scale and offset signal before digitizing
offset = 0; % mean(filtered(findRange(t, t_offset)));    % AC coupling
scaled = filtered - offset;
scale_max = max(abs(scaled(findRange(t, t_offset))));
scaled = Vref * scaled./ scale_max;
scaled(scaled>Vref) = Vref;
scaled(scaled<-Vref) = -Vref;
digitized = round(scaled/Vref * (2^(ADCbits-1)));
sqwz = sqw-repmat(mean(sqw,2),1,samples); % make each signal zero mean
% for ii = 1:N
%     xc2(ii,:) = xcorr(sqwz(ii,:), digitized, 'coeff');
% end
xc = xcorr2(sqwz, digitized);
for ii = 1:N
    xc(ii,:) = xcorr(sqwz(ii,:), digitized, 'coeff');
end

sPower = 20*log10(std(xc,0,2));   % detected signal power (dB) (may contain noise component)
% [peak, peakInd] = max(xc,[],2);
% skirt = rms([xc(1:peakInd) , xc(peakInd+1:end)]);
%procGain = sPower - SNR;

fdig = fftshift(fft(fftshift(digitized), fft_size));    % FFT of digitized signal
fdig = fdig./ max(abs(fdig));   % normalize
fdigdB = 20*log10(abs(fdig(fft_size/2+1:end)));   % converted to dB

% Calculate signal and noise power from fft
ind(1) = 1;
for ii = 1:N
    ind(ii+1) = find(freqs == f(ii));
%    sPower(ii) = fdigdB(ind(ii+1));
    flPower(ii) = mean(fdigdB(ind(ii)+1:ind(ii+1)-1));
end

% Calculate signal and noise power from cross-correlation
sPower = 20*log10(abs(xc(:,samples)));
flPower = 20*log10(rms(abs([xc(:,1:samples-1) xc(:,samples+1:end)]),2));

% Processing gain
procSNR = sPower(:) - flPower(:);
procGain = procSNR - min([SNR LfAmbInt HfAmbInt]);


% % Goertzel filter
% s = zeros(size(digitized));
% y = zeros(size(digitized));
% for ii = 3:samples,
%     for jj = 1:N
%         s(jj,ii) = digitized(ii) + 2*cos(2*pi.*f(jj)).*s(ii-1) - s(ii-2);
%         y(jj,ii) = s(ii) - exp(-2*pi*i.*f(jj)) .* s(ii-1);
% %        y(jj,ii) =  sum_{k=0}^{N} x(ii)*exp(-2*pi*i*ii/N}) 
%     end
% end

% Text Output

fprintf('Number of LEDs: %d.\n', N)
fprintf('Offset time = %.2fms.\n', t_offset*1e3)
fprintf('Start freq. = %.2fHz. End freq. = %.1fHz.\n', f_min, f_max)
fprintf('Sampling rate = %gHz.\n', samp_rate)
fprintf('BPF center freq. = %.1fHz. BPF bandwidth = %.1fHz.\n', (BPmin+BPmax)/2, (BPmax-BPmin))
fprintf('SNR = %.1fdB\n', SNR)
fprintf('Post-process signal power = %.1fdB. Post-process SNR = %.1fdB. Processing gain = %.1fdB\n', [sPower' ; procSNR' ; procGain'])

% Plots

figure
set(gcf, 'Position', [962 -188 958 1052])
figure %subplot(4,2,1)
imagesc(t, [1:N], sqw)
colormap gray
xlabel('time (s)')
ylabel('LED #')
xlim([0 2*t_offset]) % zoom in to prevent aliasing
title('LED driving signals')
if pptSave
    saveppt2('temp.ppt')
end

figure %subplot(4,2,2)
imagesc(linspace(0,1, fft_size/2), [1:N], log10(abs(fsqw(:,fft_size/2+1:end))+10))
xlabel('2f / fs')
ylabel('LED #')
colormap gray
title(['Spectrum of transmitted signal - ' num2str(DAbits) ' bits'])
if pptSave
    saveppt2('temp.ppt')
end

figure %subplot(4,2,3)
plot(t, detected*1e9)
xlabel('time (s)')
grid
ylabel('Detected signal (nA)')
axis tight
%xlim([0 2*t_offset])
if pptSave
    saveppt2('temp.ppt')
end

%fvtool(sos,'Analysis','freq')

figure %subplot(4,2,4)
plot(t, filtered)
xlabel('time (s)')
grid
ylabel('Filtered signal (V)')
xlim([0 2*t_offset])
if pptSave
    saveppt2('temp.ppt')
end

figure %subplot(4,2,5)
plot(t, scaled)
xlabel('time (s)')
grid
title('Scaled signal (V)')
xlim([0 2*t_offset])
if pptSave
    saveppt2('temp.ppt')
end

figure %subplot(4,2,6)
plot(t, digitized)
xlabel('time (s)')
ylabel('ADC counts')
grid
title(['Digitized signal - ' num2str(ADCbits) ' bits'])
xlim([0 2*t_offset])
if pptSave
    saveppt2('temp.ppt')
end

figure %subplot(4,2,7)
plot(freqs(1:end-1), fdigdB)
xlabel('freq. (Hz)')
ylabel('Power of digitized signal spectrum (dB)')
grid
axis tight
for ii = 1:N
    line([freqs(ind(ii)+1) freqs(ind(ii+1)-1)], [flPower(ii) flPower(ii)], 'LineStyle', '-.', 'Color', 'cyan')
end
if pptSave
    saveppt2('temp.ppt')
end

figure %subplot(4,2,8)
mesh(1e3/samp_rate*[-samples+1:samples-1], [1:N], abs(xc))
xlabel('time delay (ms)')
ylabel('LED #')
zlabel('Correlation signal')
title('Processed correlation')
colormap gray
axis tight
if pptSave
    saveppt2('temp.ppt')
end

