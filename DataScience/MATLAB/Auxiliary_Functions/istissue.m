function [ tf, value ] = istissue( HbF, HbConc, method )
% function [ tf, value ] = istissue( HbF, HbConc )
% Determines whether input parameters correspond to human tissue (True) or
% not (False). Also returns value of error function.
%
% Inputs
% HbF - hemoglobin fraction
% HbConc - hemoblogin concentration
% method - Tissue detection method. Options are
% 'Rectangular' -  Uses rectagular region.
% 'Elliptical' -  Default. uses elliptical region.
% 'RotElliptical' - Uses rotated elliptical region, translated by the
% median (takes into account cross-correlation between input parameters).
%
% Outputs
% tf - True if parameters correspond to that of tissue.
% value - value of tissue detection error function. The closer to zero the
% higher the certainty that signals correspond to those of tissue.
%
% P. Silveira, Aug. 2015
% BSX Proprietary

% Constants
% Thresholds, based on whiskers of boxplots, from analysis of 750 completed
% LT assessments
HbFMIN = 0.19E-04;  % 0.28173e-4 is the minimum value from 755 successful assessments from the server from assessment 552f1cb8adac18f20e8b5195. (assessment 55cbc1cbadac1824688b458c was 0.1426e-4 but doesn't look real, and assessment 55a43175adac1877068b46d5 had a value of 0.20576e-4 but is defective)
HbFMAX = 4.9E-04; % 4.9e-4 seen in Adam's left calf, activity 564caac2adac181c678b456b.3.84e-4 seen in Dustin's left calf data, activity ID 563bdbe307c51930798b456e
HbConcMIN = 4.05; % 4.4718 minimum value from 755 successful assessments from the server, ID 557f77aeadac18d00e8b4599. (Assessment 55cbc1cbadac1824688b458c had 4.3613 but it doesn't look real).
HbConcMAX = 145; % Up to 145 seen in Adam's quad muscle during commute ride (activity ID 564b72bd07c51960668b4571). 93.4322 max from HbConcEnd from 755 assessments from the server (assessment 55478006adac18f10e8b52d9 from Jeremy Brown)

% Median values
HbFMED = 2.1024118e-04;
HbConcMED = 38.7998352;
% % From in-house tissue experiment, calves only
% HbFMean = 0.000115785000000;
% HbConcMean = 17.220299999999995;
% From in-house and database, calves and forearms
HbFMean =  0.000129761946583;
HbConcMean = 21.117423404647390;

% Rotation vector calculated from SVD of covariance matrix of input parameters.
rot_vector = [   0.53750260790  -86142.78024324348
    -0.13311130524  -0.00000083057];
% Rotation vector calculated from SVD of cov matrix using in-house experiments, database, calves and forearms
rot_vector = [   0.16008395397  -35840.91589713395
  -0.09913943593  -0.00000044281];

if ~exist('method', 'var')  % set default tissue detection method
    method = 'Rectangular';
%    method = 'Elliptical';
end

% Select method and perform calculations
switch method
    case 'Rectangular'
        % Calculate error from target (ideal points), assumed to be at the middle
        % of the range.
        % Best to use median or mean values, since maxima and minima are poor
        % estimators of the mean of a range
        HbFTarget = (HbFMAX+HbFMIN)/2;  % 0.0001387
        HbConcTarget = (HbConcMAX+HbConcMIN)/2;  % 22.94
        HbFError = HbF - HbFTarget;
        HbConcError = HbConc - HbConcTarget;
        normHbFError = (HbFError) ./ (HbFMAX-HbFMIN);
        normHbConcError = (HbConcError) ./ (HbConcMAX-HbConcMIN);
        tf = (HbF > HbFMIN) & (HbF < HbFMAX) & (HbConc > HbConcMIN) & (HbConc < HbConcMAX);
        value = sqrt(normHbFError.^2+normHbConcError.^2);
    case 'Elliptical'
        % Calculate error from target (ideal points), assumed to be at the middle
        % of the range.
        % Best to use median or mean values, since maxima and minima are poor
        % estimators of the mean of a range
        HbFTarget = (HbFMAX+HbFMIN)/2;  % 0.0001387
        HbConcTarget = (HbConcMAX+HbConcMIN)/2;  % 22.94
        HbFError = HbF - HbFTarget;
        HbConcError = HbConc - HbConcTarget;
        normHbFError = (HbFError) ./ (HbFMAX-HbFMIN);
        normHbConcError = (HbConcError) ./ (HbConcMAX-HbConcMIN);
        value = sqrt(normHbFError.^2+normHbConcError.^2);
        tf = value < 0.5;
    case 'RotElliptical'
        HbFTarget = HbFMean;
        HbConcTarget = HbConcMean;
        HbFError = HbF - HbFTarget;
        HbConcError = HbConc - HbConcTarget;
        V = rot_vector * [HbFError HbConcError]';
        value = sum(abs(V).^2, 1);
        tf = value < 0.5;
    otherwise
        error(['Invalid tissue detection method = ' method])
end % switch

end % function

