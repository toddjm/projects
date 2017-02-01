% Outputs normalized Gaussian spectrum of LED with certain peak wavelength
% and FWHM 

function [spectrum] = Gauss_LED(wv,pkwv,fwhm)

%wv is wavelength array in nm;
%pkwv is peak wavelength in nm;
%fwhm is full-width at half maximum of LED in nm;

sigma = 0.42463*fwhm;
spectrum = exp(-((wv-pkwv).^2)./(2*sigma^2));

end

