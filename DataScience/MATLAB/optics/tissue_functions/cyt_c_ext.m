function [avg_e, oxidized, reduced] = cyt_c_ext(wavelength)
% function [avg_e, oxidized, reduced] = cyt_c_ext(wavelength)
% Returns the molar attenuation coefficients (aka molar extinction coefficient and molar
% absorptivity) of oxidezed and reduced cytochrome oxidase c (L / (cm . mmole) = (1 / (cm . mMolar)) at specifcied
% wavelengths.
% Uses cubic interpolation for wavelengths in the range from
% 226nm to 1100nm. Uses linear interpolation (and extrapolation) when ANY
% of the input wavelengths is outside this range.
% Use spectral data from http://www.bmb.leeds.ac.uk/teaching/icu3/lecture/20/ (from 226nm to 600nm) and other to confirm very
% low exctinction ration from 600 to 1100nm (assumed to be near zero).
%
%
% Inputs
% wavelength - wavelength (nm)
%
% Outputs
% avg_e - averaged excintion ratio. Average of the two terms listed next (L / (cm . mmole))
% oxidized - molar attenuation coefficient for oxidized cytochrome oxidase c (L / (cm . mmole))
% reduced - molar attenuation coefficient for reduced cytochrome oxidase c (L / (cm . mmole))
%
% See also
% prahlhb, cyt_c_mu_a
%
% P. Silveira and T. Minehardt, Jan. 2016
% BSX Proprietary

% wavelength (nm), molar absorptivity of oxidized cytochrome oxidase c (Liter / (cm . mmole))
oxid_data = [
    226,    136 
    237.5, 60.0
250.0, 23.0
262.5, 22.5
275.0, 24.0
287.5, 21.5
300.0, 14.0
312.5, 16.0
325.0, 18.0
337.5, 21.5
350.0, 25.0
362.5, 28.0
375.0, 29.0
379.9, 30.0
381.25, 35.0
387.5, 42.5
393.75, 55.0
400.0, 75.0
410.6, 106.0
412.5, 104.0
418.75, 80.0
425.0, 45.0
431.25, 30.0
437.5, 23.0
450.0, 14.0
459.0, 10.0
462.5, 8.0
475.0, 7.5
487.5, 7.0
500.0, 7.5
512.5, 9.0
525.0, 10.0
537.5, 11.0
550.0, 10.0
562.5, 7.5
575.0, 6.0
587.5, 2.5
600, 0
1100, 0
];

% wavelength (nm), molar absorptivity of reduced cytochrome oxidase c (Liter / (cm . mmole))
red_data = [
    226, 127
    237.5, 60.0
243.75, 40.0
250.0, 35.0
262.5, 30.0
271.7, 32.5
281.25, 30.0
287.5, 27.0
295.7, 21.0
303.3, 25.0
315.8, 32.5
325.0, 28.0
337.5, 22.0
350.0, 17.5
362.5, 15.0
365.8, 14.0
375.0, 16.0
381.75, 20.0
393.25, 35.0
400.0, 50.0
406.25, 80.0
413.75, 129.3
418.75, 110.0
425.0, 66.0
431.25, 30.0
437.5, 16.0
443.5, 10.0
450.0, 5.0
462.5, 2.0
471.89, 0.5
487.5, 2.5
500.0, 5.0
510.2, 10.0
520.1, 14.0
528.6, 11.0
537.5, 7.5
541.1, 8.0
543.9, 15.0
547.9, 25.0
556.25, 3.5
562.5, 1.0
575.0, 0.75
600, 0
1100, 0
];

if any(wavelength > red_data(end,1)) || any(wavelength < red_data(1,1))
    warning('Wavelength out of bounds. Extrapolating.')
    method = 'linear';  % linear method extrapolates better
else
    method = 'pchip';   % interpolates better
end

reduced = interp1(red_data(:,1), red_data(:,2), wavelength, method, 'extrap');
oxidized = interp1(oxid_data(:,1), oxid_data(:,2), wavelength, method, 'extrap');

avg_e = (reduced + oxidized) / 2;


