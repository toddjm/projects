function [ centroid_wavelengths, nominal_wavelengths ] = getLeds
% [ centroid_wavelengths, nominal_wavelengths  ] = getLeds
%   Return LEDs centroid wavelengths. Number of LEDs is given by
%   numel(centroid_wavelenghts).
%
% Example
% wavelengths = getLeds;
%
% Input
% None
%
% Output
% centroid_wavelenghts - vector with centroid wavelengths of BSX Insight
% LEDs (nm). Centroid takes into account photodetector Responsivity curve.
% nominal_wavelengths - vector with nominal wavelengths of BSX Insight LEDs
% (nm).
% nominal_wavelengths - vector of strings with nominal wavelength values (nm).
%
% P. Silveira, May 2015
% BSX Proprietary

centroid_wavelengths = [664  799  846  932];    % led centroid wavelengths
%nominal_wavelengths = [665 810 850 950];    % led nominal wavelengths
nominal_wavelengths = {'665'; '810'; '850'; '950'};    % led nominal wavelengths

end

