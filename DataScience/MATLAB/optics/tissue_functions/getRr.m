function T = getRr(mua, musp, r, n)

% function T = getRr_r(mua, musp, r, n)
%  EITHER mua and musp are vectors, and r is scaler
%  OR r is vector and mua,musp are scalars
%  n is always a scaler.
%  Uses the diffusion math from  Farrell et al. 

ri = 0.668 + 0.0636*n + 0.710/n - 1.440/n^2;
A = (1 + ri)/(1 - ri);

zo = 1./(mua + musp);
D = zo/3;
delta = sqrt(D./mua);
r1 = sqrt(zo.^2 + r.^2);
r2 = sqrt((zo + 4*A*D).^2 + r.^2);
mueff = 1./delta;

c = zo.*(mueff + 1./r1).*exp(-r1./delta)./(r1.^2);
d = (zo + 4*A*D).*(mueff + 1./r2).*exp(-r2./delta)./(r2.^2);
T = ( c + d )/(4*pi);