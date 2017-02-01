% Script used to simulate light detection using digital spread-spectrum modulation
%

clear
close all

N = 8;  % # of LEDs
if mod(N,4)
    error(['N must be a multiple of 4. N = ' num2str(N)])
end
t_end = .2; % end of time sequence (s)
%r = 2500; % chirp rate (Hz/s)
f_min = 0;
SNR = -20;  % signal to noise ratio (dB)
f_max = f_min + t_end * r;
fprintf('Number of LEDs: %d. Chirp rate = %gHz/s.\n', N, r)
fprintf('Start freq. = %.2fHz. End freq. = %.1fHz.\n', f_min, f_max)
TB = (f_max-f_min) * t_end;
fprintf('Temporal-bandwidth product = %.1f.\n', TB)
samp_rate = f_max*2*N;    % make sure to prevent aliasing.
fprintf('Min. sampling frequency = %gHz.\n', samp_rate)
fprintf('BPF center freq. = %.2fHz. BPF bandwidth = %.1fHz.\n', f_min+(samp_rate+f_min)/2, samp_rate - f_min)
fprintf('SNR = %.1fdB\n', SNR)
samples = samp_rate*t_end;

t = linspace(0, t_end, samples); % time series

chirp = 2*(sin(pi*t.*(2*f_min + r.*t)) > 0)-1;   % digital linear chirp
%chirp = 2*(sin(pi*t.*(2*f_min + r.*t)))-1;   % digital linear chirp

h = repmat(hadamard(N),1,samples/N);

chirps = repmat(chirp,N,1).*h;
noise = rand(size(t));
noise = noise ./ rms(noise) .* rms(chirp) / (10.^(SNR/20));    % normalize wrt desired SNR

figure
imagesc(t, [1:N], chirps)
colormap gray
xlabel('time (s)')
ylabel('LED #')

fft_size =  2^(ceil(log(samples)/log(2))+1);    % pick next power of 2
fchirps = fftshift(fft(fftshift(chirps), fft_size, 2));

figure
imagesc(linspace(0,1, fft_size/2), [1:N], log10(abs(fchirps(:,fft_size/2+1:end))+10))
xlabel('2f / fs')
ylabel('LED #')
colormap gray

figure
plot(t, chirp+noise)
xlabel('time (s)')
grid
title('Detected signal')

x = xcorr(chirp, chirp+noise, 'coeff'); % also try 'coeff', 'unbiased'
[peak, peakInd] = max(x);
skirt = rms([x(1:peakInd) , x(peakInd+1:end)]);
procSNR = 20*log10(peak ./ skirt);
fprintf('Post-processing SNR = %.1fdB. Processing gain = %.1fdB\n', procSNR, procSNR - SNR)

figure
plot(x)
xlabel('samples')
title('Processed correlation')
axis tight
grid