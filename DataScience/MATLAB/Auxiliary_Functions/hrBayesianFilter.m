function [advF,simpF,expHR,hrDist,BPMs,AmpMotion,AmpOptical] = hrBayesianFilter(in,mot,samp)
% [quadF,simpF,expHR,hrDist,BPMs,AmpMotion,AmpOptical] = hrBayesianFilter(InSpectra,MotionSignal,SamplingRate)
% Uses a number of variable length discrete Fourier transforms to 
% 1) Model motion artifacts in the motion input
% and then
% 2) Extract optical information to 
% (bpm). Also provides a filtered output with a 1s update rate. Better
% results are obtained if input signal is filtered with hrFilter before
% calling this function.
% 
% Example
% activity = getActivity('xxxxx');
% sweep = getSweep(activity);
% process = sweep2process(sweep);
% Optical = 10.^-([process.OD15 process.OD27]);
% Optical = Optical* [ 1     1    -1    -1     1    -1    -1    -1]';
%be careful that the Optical and Motion are the same length and sampled at
%the same rate
% Motion  = sweep.Acc_y.^2 + sweep.Acc_z.^2; 
% heartRate = hrBayesianFilter(Optical,Motion,20)
% plot( sweep.time(1:20:end), heartRate(1:20:end))
% be aware that if you are comparing to the Zephyr, you need to know the
% offset between the Zephyr and the Insight (might be more than simply UTC
% normalization)
%
% Inputs
% InSpectra - input optical vector t x 1
% MotionSignal - input motion vector t x 1 
% samp - sampling rate (Hz). Default = 20, this function does not currently
% work well when the rate isn't 20Hz
%
% Outputs
% quadF [1 x t] - heart rate (in bpm) after peaks are estimated by quadratic fits
% simpF [1 x t] - heart rate chosen as the maximum output of the filter (and thus not interpolated)
% expHR [1 x t] - heart rate chosen as the expected value of the heart rate (weighted average)
% Outputs used only for debugging purposes
% hrDist [u x t] - the distribution of 
% BPMs   [1 x u] - the Heart Rates that are being detected
% AmpMotion,AmpOptical - the raw Motion and Optical DFT outputs 
%
%
% BSX Athletics Proprietary

if ~exist('samp', 'var')
    samp = 20;   % default sampling rate = 5Hz
end

%this function removes nans in the input streams, it's not recommended for
%future use, but it allows the filter to run even when there are
%significant nans
t = [1:numel(in)];
try
    in(isnan(in)) = interp1(t(~isnan(in)),in(~isnan(in)),t(isnan(in)),'linear','extrap');
catch   % I don't know how to fix problems with the line above, so I'm simply avoiding its execution when it causes problems.
end
%the inputs are filteres using hrFilter, be sure to use the latest version
%that DOES NOT nan out the first 20 samples
in = hrFilter(in, samp);

t = [1:numel(mot)];
mot(isnan(mot)) = interp1(t(~isnan(mot)),mot(~isnan(mot)),t(isnan(mot)),'linear','extrap');
mot = hrFilter(mot, samp);

if size(in,1) > size(in,2),
    in = in';
end

if size(mot,1) > size(mot,2),
    mot = mot';
end


%this is a hand designed DFT filter for 20Hz, this will be updated for
%arbitrary sampling rates in the future
%8 cycles are used in the design phase, but reduced to ensure faster update
%times
eightCycleLengths =     [  48:62                  64:2:90                 92:4:128                 136:8:176];
%Normalizer allows us to reduce the number of cycles (and thus the update
%speed, without changing the frequency that each filter detects)
Normalizer  =           [  ones(size(48:62))  ones(size(64:2:90))    2*ones(size(92:4:128))  2*ones(size(136:8:176))];
%this is the actual filter length
Lengths = eightCycleLengths./Normalizer; 

%9600 = 8 cycles * 20 Hz (samples/second) * 60 (seconds/minute) 
%so 9600 cycles * sample / minute  /  Length (samples/cycle)
BPMs = 9600./eightCycleLengths;
%figure out the number of filters
numB = numel(BPMs);


%set up the filters, not the most effective way to do this long term, 
%the goal is to update the heart rate once a second, however, what we end
%up doing is calculating 20 (due to 20Hz) independent estimates of the
%heart rate, this is fine if you eventually interpolate, downsample, or
%otherwise reduce the date, but may look strange if you plot all of the
%results
[AmpOptical,AmpMotion] = deal(zeros(numel(Lengths),length(in)));

%loop through the filters
for ff = 1:numel(Lengths),
    %create a sin and cos function of appropriate length,
    %first, create the phase of those functions
    phase = -2*pi*(8/eightCycleLengths(ff)).*[1:length(in)];
    %now, compute the inner product of the sin/cos functions and the
    %optical input, filter is used to get the sum over the appropriate
    %section 
    SF = filter(ones(1,Lengths(ff)),1,in.*sin(phase)); 
    CF = filter(ones(1,Lengths(ff)),1,in.*cos(phase));
    %Normally, DFTz, FFTs, etc are done in the complex domain and the
    %amplitude is extracted, here we do everything with real numbers to
    %simplify things and manually compute the resulting magnitude
    
    %in the future, if squareroots are expensive or inaccurate, magnitude
    %squared could be used
    tmp = sqrt(SF.^2 + CF.^2)./sqrt(Lengths(ff));
    
    %since we are going to be computing these things at 20Hz, but only
    %displaying them at 1Hz, let's take an average over the last 20 samples
    AmpOptical(ff,:) = filter(ones(1,20)./20,1,tmp);
    %this cleans up the fact that the first 20 samples have some transients
    AmpOptical(ff,1:20) = tmp(1,1:20);
    
    %this section is exactly as above, but for the motion signal
    SF = filter(ones(1,Lengths(ff)),1,mot.*sin( phase)); 
    CF = filter(ones(1,Lengths(ff)),1,mot.*cos(phase));
    tmp = sqrt(SF.^2 + CF.^2)./sqrt(Lengths(ff));
    AmpMotion(ff,:) = filter(ones(1,20)./20,1,tmp);
    AmpMotion(ff,1:20) = tmp(1,1:20);
    
end

%now we are going to take the optical estimates of motion and heart rate +
%motion (in the optical signal) and combine them with our best estimates
%about how uncertainty propogates through time


%at every time step we are estimating the probability of the heart rate
%being one of the BPMs calculated above. This is treated, for the most
%part, as a discrete probability (instead of a continuous version sampled
%at certain heart rates)

%move the distribution of possible heart rates through time
hrDist = ones(numB,numel(in))./numB; %uniform prior, might be better to use a more infomative priorm for example, a resting hr prior if the motion is low

%create a diffusion matrix that describes how heart rates change
% From a study of possible heart rates diplayed by the Zephyr chest strap
% we find that the distrubtion of heart rate changes (over one second) are
% proportional to 0.5./(1 +(xx/0.7).^2)+0.5*exp(-0.5*(xx./0.7).^2)
funfun = @(x) 0.3975./(1 +(x/0.7).^2)+0.6*exp(-0.5*(x./0.7).^2);%+0.0025; %we've removed the uniform portion, the sum of the coefficients is no longer 1, but that is normalized below

%compute the difference between each BPM and every other BPM, this is a
%matrix where each element i,j is funfun(BPM(i) - BPM(j))
HRdiff = funfun(bsxfun(@minus, repmat(BPMs,numB,1),BPMs'));
%normalize
HRdiff = bsxfun(@rdivide,HRdiff,sum(HRdiff)); %this ensures that 100% of the evidence of a heart rate gets distributed to other heart rates
%this matrix could be made simpiler in an embedded implementation since you
%don't need to be very far from the diagonal for the enteries to be close
%to zero


%find the maximum Amplitude by time
%we intialize the heart rate distribution with a uniform distribution and
%start computing one second later
for tt = 21:numel(in) %this loop start is bazed on 20Hz
    %use the motion model to update the current possible heart rates
    hrDist(:,tt) = HRdiff*hrDist(:,tt-20); %t-20 is based on a sampling rate of 20Hz
    
    %implement the observation model, 
    %first find peaks in the motion model
    mLevel = median(AmpMotion(:,tt));
    motionPeaks = AmpMotion(:,tt) > 2.7381*mLevel; %based on a white noise study, random peaks are rarely more than 2.7*the median
    if any(motionPeaks)
    %this loop simply adds motion adjacent peaks to the list of motion
    %peaks, we might need to be more careful if/when the motion and the
    %heart rate are likely to cross one another, with our early work on
    %cycling this isn't the case
        thesePeaks = find(motionPeaks); 
        possiblePeaks = [thesePeaks - 1;thesePeaks; thesePeaks+1]; 
        possiblePeaks(possiblePeaks==0) = []; 
        possiblePeaks(possiblePeaks==numB+1) = [];
        motionPeaks(possiblePeaks) = AmpMotion(possiblePeaks,tt) > mLevel;
    else
        %this suggest that there should be some peaks, even if they aren't
        %significant, I don't know how often this is actually used
        motionPeaks = AmpMotion(:,tt) > prctile(AmpMotion(:,tt),[90]);
    end
    %compute the median optical energy when the motion peaks are ignored
    oLevels = prctile(AmpOptical(~motionPeaks,tt),[50 10]);
    opticalEvidence = AmpOptical(:,tt);
    %fill in the motion areas with small levels of evidence
    opticalEvidence(motionPeaks) = oLevels(2);
    %look for legitimate peaks
    opticalPeaks = opticalEvidence > 2.7381*oLevels(1);
    if( any(opticalPeaks)) %if we have peaks
    %clean up the noisy parts of the signal
        opticalEvidence(opticalEvidence < oLevels(1)) = oLevels(2);
    %normalize
        opticalEvidence = opticalEvidence./sum(opticalEvidence);
    %combine the motion model and the optical evidence
        hrDist(:,tt) = hrDist(:,tt).*opticalEvidence;
    %there is no "else" here, but if no peaks are found we simply use the
    %motion model
    end
    %normalize to a probability
    hrDist(:,tt) = hrDist(:,tt)./sum(hrDist(:,tt));
    
    
end
   
%at this point we have a probability density function over BPMs are each
%time point, we need to turn that pdf into a single heart rate

%the easiest thing to do is to select the BPM that has the max probability
[jnk,maxidx] = max(hrDist);
simpF = BPMs(maxidx);

%also easy, is to compute the expected value of heart rate by taking a
%weighted average over BPMs
expHR = BPMs*hrDist;

%the most advanced method implemented finds the peak and fits the samples
%on either side to a quadratic curve, the coefficients of which allow for a
%quick estimate of the "true" maximum
advF = simpF;
idx_to_fix = (maxidx ~= 1) & (maxidx ~= numel(Lengths));

%this is really slow, but it will work for now
for tt = find(idx_to_fix),
    Ptmp = polyfit(BPMs([-1:1]+ maxidx(tt))',hrDist([-1:1]+ maxidx(tt),tt),2);
    advF(tt) = -Ptmp(2)/(2*Ptmp(1));
end



