function [ out_currents ] = ccode2Amp( ccode, HW_VERSION )
% function [ out_currents ] = ccode2Amp( ccode, HW_VERSION )
%
% Function used to convert from current codes to currents in Amperes
%
% Inputs:
% ccode - vector with current codes
% in AllCnt calibration matrix
% HW_VERSION - hardware version of device being used. Usually found using
% device = getDevice(sweep.device_id);
% HW_VERSION = device.hw_version;
% 
% Outputs:
% out_currents - list of output currents (Amp)
%
% See also
% getAllCnt, getDevice
%
% P. Silveira, Aug. 2015
% BSX Proprietary

currents256 = getCurrents(HW_VERSION);

out_currents = currents256(ccode+1);

