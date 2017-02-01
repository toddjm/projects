function [ T ] = sabic( wavelength )
% function [ T ] = sabic( wavel )
% Returns transmission spectrum (normalized to unity) of Sabic plastic
% window. Uses pchip interpolation and extrapolates to 100% transmission
% for wavelenghts > 1100nm or <400nm. The extrapolation is especially bad
% for shorter wavelengths.
% Uses experimental data from SABIC_IRdes_Analyzed.xlsx
%
% Inputs
% wavelength - desired wavelengths (nm)
%
% Outputs
% T - transmission (unitless)
%
% P. Silveira, March 2015
% BSX Proprietary

% temp = csvread('C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\PD_characterization\S7478_Responsivity.csv',3);
% wavel_nom = temp(:,1);
% R_nom = temp(:,2);

% Values read from plot shown on http://www.hamamatsu.com/us/en/product/category/3100/4001/4103/S7478/index.html
wavel_nom = [220
230
240
250
260
270
280
290
300
310
320
330
340
350
360
370
380
390
400
410
420
430
440
450
460
470
480
490
500
510
520
530
540
550
560
570
580
590
600
610
620
630
640
650
660
665
670
680
690
700
710
720
730
740
750
760
770
780
790
800
810
820
830
840
850
860
870
880
890
900
910
920
930
940
950
960
970
980
990
1000
1010
1020
1030
1040
1050
1060
1070
1080
1090
1100
];

T_nom = [0.221496259
0.503851006
0.376402132
0.332353985
0.361208396
0.368197486
0.37793895
0.367537341
0.321909337
0.316110143
0.333148835
0.423621243
0.34081681
0.30120642
0.251769723
0.245014698
0.410208753
0.107587292
0.088825363
0.07636375
0.100127275
0.119908484
0.10240681
0.080947584
0.070530825
0.060049433
0.051692147
0.045309679
0.042581904
0.03661199
0.035142336
0.033064265
0.031852348
0.031030755
0.035491889
0.037149417
0.036265375
0.035627576
0.041377166
0.065256475
0.122802929
0.227941569
0.373323398
0.535115949
0.68368111
0.739692729
0.794580637
0.868597792
0.903734092
0.927088066
0.940074883
0.947928421
0.951569305
0.953196904
0.956242646
0.959723703
0.959174289
0.9622706
0.964434032
0.973637855
0.976816793
0.97934368
0.980871632
0.982383118
0.984139135
0.982185315
0.978718064
0.991415227
0.991920303
0.98263629
0.969011099
0.9714641
0.978266602
0.989512673
0.998984113
1
1
1
0.971987825
0.98119614
0.992543662
1
1
1
1
1
1
1
1
1
];

min_wavel = min(wavel_nom);
max_wavel = max(wavel_nom);
if any(wavelength > max_wavel) || any(wavelength < min_wavel)
    warning(['One or more wavelengths outside nominal range [' num2str(min_wavel) ',' num2str(max_wavel) ']. Extrapolating to 100% transmission.'])
end
T = interp1(wavel_nom, T_nom, wavelength, 'pchip', 1);
end

