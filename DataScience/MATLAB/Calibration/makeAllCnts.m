%# This script takes the 6 files associated with the INO blocks and makes
%the AllCnts (Counts_0) matrix
clear all; 
close all;

%%
%constants
wavelengths = [680 770 810 850 970];
pb0330Cal = struct('Ua',[0.12 0.129 0.103],'wavelengths',[750,680,850],'Usp',[6.34 6.62 6.17]);
pb0376Cal = struct('Ua',[0.08 0.102 0.0789],'wavelengths',[805 680 850],'Usp',[9.52 10.1 9.36]);
%change this to point to your files
FILES = {'1077_usbDL_cal_sweep_pb0330_3mm_t1_09192014.csv', '1077_usbDL_cal_sweep_pb0330_3mm_t2_09192014.csv','1077_usbDL_cal_sweep_pb0330_3mm_t3_09192014.csv',...
    '1077_usbDL_cal_sweep_pb0376_3mm_t1_09192014.csv','1077_usbDL_cal_sweep_pb0376_3mm_t2_09192014.csv','1077_usbDL_cal_sweep_pb0376_3mm_t2_09192014.csv'};
HeaderLines = 2;
%% set up and read in the pb0330 files
T = zeros(25,15,9); tidx = 1;

for fidx = 1:3,
    T1 = xlsread(FILES{fidx});
    Repeats = floor((size(T1,1)-HeaderLines)/25);
    
    for ridx = 1:Repeats,
        T(:,:,tidx) =  T1(HeaderLines + (ridx-1)*25 + [1:25],[2:6 17:21 32:36]);
        tidx = tidx+1;
    end
end
    
if tidx < 10;
    T = T(:,:,1:tidx-1);
end
    
%% take the trimmean of the 9 (or so) repeats, 25% seems to keep the resulting curves smooth. 

  PB0330 = trimmean(T,25,3);  
  %need something to nan-out saturations
  %need something to interpolate and extrapolate to fix nans
  plot(PB0330);
  
  %use diffusion theory to find out the expected OD for the block
  Ua = interp1(pb0330Cal.wavelengths,pb0330Cal.Ua,wavelengths,'linear','extrap');
  Usp = interp1(pb0330Cal.wavelengths,pb0330Cal.Usp,wavelengths,'linear','extrap');
  %n from http://en.wikipedia.org/wiki/List_of_refractive_indices
  eOD0330  = [-log10(getRr(Ua, Usp, 0.7, 1.35)) -log10(getRr(Ua, Usp, 1.5, 1.35)) -log10(getRr(Ua, Usp, 3, 1.35))];
  
  
  
%% set up and read in the pb0376 files
T = zeros(25,15,6); tidx = 1;

for fidx = 4:6,
    T1 = xlsread(FILES{fidx});
    Repeats = floor((size(T1,1)-HeaderLines)/25);
    
    for ridx = 1:Repeats,
        T(:,:,tidx) =  T1(HeaderLines + (ridx-1)*25 + [1:25],[2:6 17:21 32:36]); %Shcema 12 or below
        tidx = tidx+1;
    end
end

if tidx < 10;
        T = T(:,:,1:tidx-1);
    end
    
%%
  PB0376 = trimmean(T,25,3);  
  %need something to nan-out saturations
  %need something to interpolate and extrapolate to fix nans
  plot(PB0376);


%%
  %use diffusion theory to find out the expected OD for the block
  Ua = interp1(pb0376Cal.wavelengths,pb0376Cal.Ua,wavelengths,'linear','extrap');
  Usp = interp1(pb0376Cal.wavelengths,pb0376Cal.Usp,wavelengths,'linear','extrap');
  %n from http://en.wikipedia.org/wiki/List_of_refractive_indices
  eOD0376  = [-log10(getRr(Ua, Usp, 0.7, 1.35)) -log10(getRr(Ua, Usp, 1.5, 1.35)) -log10(getRr(Ua, Usp, 3, 1.35))];
  
  
  
%% we know what the PB0330 & PB0376 ODs should be, so we will try and figure out the I_0 for each Iset/LED/Distance
% recall: log10(Counts_0/Counts_measured) = OD so log10(Counts_0) = log10(Counts_measured) + OD

  
  LogOfAllCnt = 0.5*bsxfun(@plus, log10(PB0330), eOD0330 ) + 0.5*bsxfun(@plus,log10(PB0376), eOD0376);
  AllCnt = 10.^LogOfAllCnt;
  
  
 
%% at this point we should detect saturations, non-monotonic places, etc
%% and interpolate around them, this is not currently implemented
%% save the results

I = [7.89183E-05
    0.000166382
    0.000253846
    0.00034131
    0.000428773
    0.000516237
    0.000603701
    0.000691165
    0.000778629
    0.000866092
    0.000953556
    0.00104102
    0.001128484
    0.001215948
    0.001303411
    0.001390875
    0.001478339
    0.001565803
    0.001653266
    0.00174073
    0.001828194
    0.001915658
    0.002003122
    0.002090585
    0.002178049
    0.002265513
    0.002352977
    0.00244044
    0.002527904
    0.002615368
    0.002702832
    0.002790296
    0.002877759
    0.002965223
    0.003052687
    0.003140151
    0.003227615
    0.003315078
    0.003402542
    0.003490006
    0.00357747
    0.003664933
    0.003752397
    0.003839861
    0.003927325
    0.004014789
    0.004102252
    0.004189716
    0.00427718
    0.004364644
    0.004452107
    0.004539571
    0.004627035
    0.004714499
    0.004801963
    0.004889426
    0.00497689
    0.005064354
    0.005151818
    0.005239282
    0.005326745
    0.005414209
    0.005501673
    0.005589137
    0.0056766
    0.005851528
    0.006026456
    0.006201383
    0.006376311
    0.006551238
    0.006726166
    0.006901093
    0.007076021
    0.007250949
    0.007425876
    0.007600804
    0.007775731
    0.007950659
    0.008125586
    0.008300514
    0.008475442
    0.008650369
    0.008825297
    0.009000224
    0.009175152
    0.009350079
    0.009525007
    0.009699934
    0.009874862
    0.01004979
    0.010224717
    0.010399645
    0.010574572
    0.0107495
    0.010924427
    0.011099355
    0.011274283
    0.01144921
    0.011624138
    0.011799065
    0.011973993
    0.01214892
    0.012323848
    0.012498776
    0.012673703
    0.012848631
    0.013023558
    0.013198486
    0.013373413
    0.013548341
    0.013723268
    0.013898196
    0.014073124
    0.014248051
    0.014422979
    0.014597906
    0.014772834
    0.014947761
    0.015122689
    0.015297617
    0.015472544
    0.015647472
    0.015822399
    0.015997327
    0.016172254
    0.016347182
    0.01652211
    0.016697037
    0.000236755
    0.000499146
    0.000761538
    0.001023929
    0.00128632
    0.001548712
    0.001811103
    0.002073494
    0.002335886
    0.002598277
    0.002860668
    0.00312306
    0.003385451
    0.003647843
    0.003910234
    0.004172625
    0.004435017
    0.004697408
    0.004959799
    0.005222191
    0.005484582
    0.005746973
    0.006009365
    0.006271756
    0.006534147
    0.006796539
    0.00705893
    0.007321321
    0.007583713
    0.007846104
    0.008108495
    0.008370887
    0.008633278
    0.008895669
    0.009158061
    0.009420452
    0.009682844
    0.009945235
    0.010207626
    0.010470018
    0.010732409
    0.0109948
    0.011257192
    0.011519583
    0.011781974
    0.012044366
    0.012306757
    0.012569148
    0.01283154
    0.013093931
    0.013356322
    0.013618714
    0.013881105
    0.014143496
    0.014405888
    0.014668279
    0.014930671
    0.015193062
    0.015455453
    0.015717845
    0.015980236
    0.016242627
    0.016505019
    0.01676741
    0.017029801
    0.017554584
    0.018079367
    0.018604149
    0.019128932
    0.019653715
    0.020178498
    0.02070328
    0.021228063
    0.021752846
    0.022277628
    0.022802411
    0.023327194
    0.023851976
    0.024376759
    0.024901542
    0.025426325
    0.025951107
    0.02647589
    0.027000673
    0.027525455
    0.028050238
    0.028575021
    0.029099803
    0.029624586
    0.030149369
    0.030674151
    0.031198934
    0.031723717
    0.0322485
    0.032773282
    0.033298065
    0.033822848
    0.03434763
    0.034872413
    0.035397196
    0.035921978
    0.036446761
    0.036971544
    0.037496327
    0.038021109
    0.038545892
    0.039070675
    0.039595457
    0.04012024
    0.040645023
    0.041169805
    0.041694588
    0.042219371
    0.042744154
    0.043268936
    0.043793719
    0.044318502
    0.044843284
    0.045368067
    0.04589285
    0.046417632
    0.046942415
    0.047467198
    0.047991981
    0.048516763
    0.049041546
    0.049566329
    0.050091111]';

Isub = [7.891833E-05
0.0001663821
0.0002538459
0.0003413097
0.0004287735
0.000603701
0.0007786286
0.00104102
0.001303411
0.00174073
0.002178049
0.002790296
0.003490006
0.004364644
0.005501673
0.006901093
0.008650369
0.01047002
0.01309393
0.01650502
0.02070328
0.02595111
0.0322485
0.04012024
0.05009111];

 AllCnt = interp1(Isub,AllCnt,I,'linear','extrap');
 
   save('1077_Counts_0.mat','AllCnt');
   csvwrite('AllCnt_1077.csv',AllCnt);






