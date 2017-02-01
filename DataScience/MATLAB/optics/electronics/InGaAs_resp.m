function [ R ] = InGaAs_resp( wavel )
% function [ R ] = InGaAs_resp( wavel )
% Provides responsivity curve for InGaAs photodetector (modeled after Hamamatsu G8941-02). 
%
% Inputs
% wavel - desired wavelengths (nm)
%
% Outputs
% R - Responsivity (A/W)
%
% P. Silveira and T. Minehardt, Feb. 2016
% BSX Proprietary

data = [
800.0, 0.098
833.3, 0.112
867.0, 0.125
900.0, 0.168
933.3, 0.336
967.0, 0.49
1000.0, 0.595
1033.3, 0.644
1067.0, 0.679
1100.0, 0.714
1133.3, 0.742
1167.0, 0.77
1200.0, 0.805
1233.3, 0.826
1267.0, 0.854
1300.0, 0.875
1333.3, 0.89
1367.0, 0.903
1400.0, 0.917
1433.3, 0.924
1467.0, 0.931
1500.0, 0.938
1533.3, 0.942
1567.0, 0.938
1600.0, 0.924
1633.3, 0.898
1667.0, 0.805
1700.0, 0.098];

wavel_nom = data(:,1);
R_nom = data(:,2);

R = interp1(wavel_nom, R_nom, wavel, 'pchip', 0);
