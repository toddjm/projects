function [ processOut ] = OD2trans( processIn )
% function [ processOut ] = OD2trans( processIn )
% Calculates optical transmission, absortions and combined optical vector from optical
% densities. The combined optical vector is a linear combination of
% transmissions that provides us with the best estimator of Heart Rate (in a least-square sense) when
% the set of weights is limited to the values {-1,0,1}.
% 
% Inputs
% processIn - structure with optical densities (fields OD15 and OD27)
%
% Outputs
% processOut - structure with absorptions, transmissions and combination
% vector. Fields are
%       trans15 - optical transmission of 15mm geometry
%       trans27 - optical transmission of 27mm geometry
%       absorb15 - optical absorption of 15mm geometry
%       absorb27 - optical transmission of 27mm geometry
%       hrComb - linear combination that optimized for heart rate estimation.
%
% See also
% processCounts, sweep2process, hrBayesianFilter

processOut.absorb15 = 10.^processIn.OD15;
processOut.absorb27 = 10.^processIn.OD27;
processOut.trans15 = 1./processOut.absorb15;
processOut.trans27 = 1./processOut.absorb27;
processOut.hrComb = [processOut.trans15 processOut.trans27] * [ 1     1    -1    -1     1    -1    -1    -1]';

end

