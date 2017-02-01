function [ out ] = processSmO2( in, mapFun, gain, filter_length, digits)
% function [ out ] = processSmO2( in, mapFun, gain, filter_length, digits)
%
% Function used to post-process SmO2 values. Values are mapped to a range
% from 0 to 100 using a non-linear mapping function.
%
% Example
% assessment = getAssessment('5515958badac18db278b4d27');   % get information for assessment 5515958badac18db278b4d27
% sweep = getSweep(assessment);
% [OD15, OD27] = processCounts(sweep);
% rawSmO2 = calc_SmO2(OD27-OD15);
% processedSmO2 = processSmO2(rawSmO2);
%
% Inputs
% in - vector with SmO2 values over time
% mapFun - nonlinear function to be used for compressive mapping. Options
% are 'softsig' (the default) and 'sigmoid'.
% gain - non-linear function gain. Default = 1.6.
% filter_length - length of median filter (samples). Default = 15 samples
% filtering.
% digits - number of digits beyond decimal point. Default = 1.
%
% Outputs
% out - output SmO2 vector bound within 0 and 100.
%
% See also
% processCounts, Run_check
%
% P. Silveira and B. Olson, Apr. 2015
% BSX Athletics Proprietary

%% Initializations

% Linear regression factors
A = -.097;   % bias (intercept) - before multiplication by 100
B = 1.2;   % scaling (slope)
%A = 0;
%B = 1;

if ~exist('digits', 'var') || isempty(digits)
    digits = 1;
end
if digits < 0
    error(['digits must be a non-negative integer. digits = ' num2str(digits)])
end
if ~exist('gain', 'var') || isempty(gain)
    gain = 1.6;
end
if ~exist('mapFun', 'var') || isempty(mapFun)
    mapFun = 'softsig';
end
if ~exist('filter_length', 'var') || isempty(filter_length)
    filter_length = 15;
end

%% Processing 

in = A+in*B;    % Linear regression
% p1 = -79.38;
% p2 = 124.4;
% p3 = -47.91;
% in = p1*in.^2 + p2*in + p3;    % Non-linear regression

switch mapFun % select non-linear mapping
    %    case 'tanh'
    %        temp = tanhMapFun(in);  % the same as sigmoid with k = 2
    case 'sigmoid'
        temp = sigmoidMapFun(in,gain);
    case 'softsig'
        temp = softSig(in,gain);
    otherwise
        error(['Invalid function = ' mapFun])
end

if exist('filter_length', 'var') && filter_length > 0 % apply filter, if defined
%        in = medfiltNaN(in, filter_length);
    % Averaging filter, ignoring NaNs
        temp = avgfiltNaN(temp, filter_length);
end

temp(temp>1) = 1; % assure bounds
temp(temp<0) = 0;

temp = temp*100;    % convert to percentage points
out = round(temp*10^digits)/10^digits;  % apply correct number of significant digits

%     function out = tanhMapFun(in)  % performs non-linear mapping from 0 to 1
%         out = tanh(in-0.5)/2+0.5;
%     end

%% Output mapping functions

    function out = sigmoidMapFun(in, k)
        out = 1./(1+exp(-4*k*(in-0.5)));
    end

    function y = softSig(x,gain)    % keeps unit gain around 0.5 point
        %NOTE if the gain isn't greater than 2, this will behave just like the sigmoid
        y = sigmoidMapFun(x,gain);
        %    y = tanhSigmoid(x,gain);
        y(x<0.5) = max(x(x<0.5),y(x<0.5));
        y(x>0.5) = min(x(x>0.5),y(x>0.5));
    end


end

