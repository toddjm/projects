function [spectrum, totPower, wavel_nom] = FQT55627AKA( wavel )
% [spectrum, totPower, wavel_nom] = fietje( wavel )
% Provides power density spectrum [mW/nm] of Fietje FQT55627AKA LED, 3mm
% package.
%
% Inputs
% wavel - desired wavelengths (nm)
%
% Outputs
% spectrum - matrix containing power spectral density (uW/nm) of LED.
% Values are interpolated for the wavelengths provided in the input. Values outside
% the originally measured range are extrapolated to zero.
%
% totPower - irradiance integrated over wavel wavelengths (mW).
%
% wavel_nom - nominal wavelengths over which LED spectrum is experimentally
% measured (nm).
%
% See also
% PD_resp, solarIrr, sabic, getLed, fietje
%
% P. Silveira, Feb. 2016
% BSX Proprietary

% Measured values originally available at
% \Google Drive\Tech_RD\Sensor\Development\Release to Market
% Product\LED_characterization\Fietje 1020nm 3mm package
% Example:
% filen = dir('*.txt');
% [spectrum, wavel] = readOO({filen.name});
% Confirmed that all LEDs have readings at exactly the same wavelengths
% (from 632.364nm to 1123.16nm).

mArea = 1.19459060652752e-4; % = pi*(3900e-4/2)^2 * 1e-3;  Area of cosine corrector (cm^2) divided by 1000 to convert from uW to mW. Cosine corrector diameter = 3900um = 0.39cm

wavel_nom = [632.364000
    632.830000
    633.295000
    633.761000
    634.227000
    634.692000
    635.158000
    635.624000
    636.090000
    636.556000
    637.021000
    637.487000
    637.953000
    638.419000
    638.885000
    639.351000
    639.817000
    640.283000
    640.749000
    641.215000
    641.681000
    642.147000
    642.613000
    643.080000
    643.546000
    644.012000
    644.478000
    644.945000
    645.411000
    645.877000
    646.344000
    646.810000
    647.277000
    647.743000
    648.209000
    648.676000
    649.143000
    649.609000
    650.076000
    650.542000
    651.009000
    651.476000
    651.942000
    652.409000
    652.876000
    653.343000
    653.810000
    654.276000
    654.743000
    655.210000
    655.677000
    656.144000
    656.611000
    657.078000
    657.545000
    658.012000
    658.479000
    658.946000
    659.414000
    659.881000
    660.348000
    660.815000
    661.283000
    661.750000
    662.217000
    662.684000
    663.152000
    663.619000
    664.087000
    664.554000
    665.022000
    665.489000
    665.957000
    666.424000
    666.892000
    667.360000
    667.827000
    668.295000
    668.763000
    669.230000
    669.698000
    670.166000
    670.634000
    671.102000
    671.569000
    672.037000
    672.505000
    672.973000
    673.441000
    673.909000
    674.377000
    674.845000
    675.314000
    675.782000
    676.250000
    676.718000
    677.186000
    677.654000
    678.123000
    678.591000
    679.059000
    679.528000
    679.996000
    680.464000
    680.933000
    681.401000
    681.870000
    682.338000
    682.807000
    683.275000
    683.744000
    684.213000
    684.681000
    685.150000
    685.619000
    686.088000
    686.556000
    687.025000
    687.494000
    687.963000
    688.432000
    688.901000
    689.369000
    689.838000
    690.307000
    690.776000
    691.245000
    691.715000
    692.184000
    692.653000
    693.122000
    693.591000
    694.060000
    694.530000
    694.999000
    695.468000
    695.937000
    696.407000
    696.876000
    697.346000
    697.815000
    698.285000
    698.754000
    699.224000
    699.693000
    700.163000
    700.632000
    701.102000
    701.572000
    702.041000
    702.511000
    702.981000
    703.450000
    703.920000
    704.390000
    704.860000
    705.330000
    705.800000
    706.270000
    706.740000
    707.210000
    707.680000
    708.150000
    708.620000
    709.090000
    709.560000
    710.030000
    710.500000
    710.970000
    711.441000
    711.911000
    712.381000
    712.852000
    713.322000
    713.792000
    714.263000
    714.733000
    715.204000
    715.674000
    716.145000
    716.615000
    717.086000
    717.556000
    718.027000
    718.498000
    718.968000
    719.439000
    719.910000
    720.381000
    720.851000
    721.322000
    721.793000
    722.264000
    722.735000
    723.206000
    723.677000
    724.148000
    724.619000
    725.090000
    725.561000
    726.032000
    726.503000
    726.974000
    727.445000
    727.917000
    728.388000
    728.859000
    729.330000
    729.802000
    730.273000
    730.744000
    731.216000
    731.687000
    732.159000
    732.630000
    733.102000
    733.573000
    734.045000
    734.516000
    734.988000
    735.460000
    735.931000
    736.403000
    736.875000
    737.347000
    737.818000
    738.290000
    738.762000
    739.234000
    739.706000
    740.178000
    740.650000
    741.122000
    741.594000
    742.066000
    742.538000
    743.010000
    743.482000
    743.954000
    744.426000
    744.899000
    745.371000
    745.843000
    746.315000
    746.788000
    747.260000
    747.733000
    748.205000
    748.677000
    749.150000
    749.622000
    750.095000
    750.567000
    751.040000
    751.513000
    751.985000
    752.458000
    752.930000
    753.403000
    753.876000
    754.349000
    754.822000
    755.294000
    755.767000
    756.240000
    756.713000
    757.186000
    757.659000
    758.132000
    758.605000
    759.078000
    759.551000
    760.024000
    760.497000
    760.970000
    761.444000
    761.917000
    762.390000
    762.863000
    763.337000
    763.810000
    764.283000
    764.757000
    765.230000
    765.703000
    766.177000
    766.650000
    767.124000
    767.597000
    768.071000
    768.545000
    769.018000
    769.492000
    769.966000
    770.439000
    770.913000
    771.387000
    771.861000
    772.334000
    772.808000
    773.282000
    773.756000
    774.230000
    774.704000
    775.178000
    775.652000
    776.126000
    776.600000
    777.074000
    777.548000
    778.022000
    778.497000
    778.971000
    779.445000
    779.919000
    780.394000
    780.868000
    781.342000
    781.817000
    782.291000
    782.765000
    783.240000
    783.714000
    784.189000
    784.663000
    785.138000
    785.613000
    786.087000
    786.562000
    787.037000
    787.511000
    787.986000
    788.461000
    788.936000
    789.410000
    789.885000
    790.360000
    790.835000
    791.310000
    791.785000
    792.260000
    792.735000
    793.210000
    793.685000
    794.160000
    794.635000
    795.110000
    795.586000
    796.061000
    796.536000
    797.011000
    797.487000
    797.962000
    798.437000
    798.913000
    799.388000
    799.863000
    800.339000
    800.814000
    801.290000
    801.765000
    802.241000
    802.717000
    803.192000
    803.668000
    804.144000
    804.619000
    805.095000
    805.571000
    806.047000
    806.522000
    806.998000
    807.474000
    807.950000
    808.426000
    808.902000
    809.378000
    809.854000
    810.330000
    810.806000
    811.282000
    811.758000
    812.234000
    812.711000
    813.187000
    813.663000
    814.139000
    814.616000
    815.092000
    815.568000
    816.045000
    816.521000
    816.997000
    817.474000
    817.950000
    818.427000
    818.903000
    819.380000
    819.857000
    820.333000
    820.810000
    821.287000
    821.763000
    822.240000
    822.717000
    823.194000
    823.670000
    824.147000
    824.624000
    825.101000
    825.578000
    826.055000
    826.532000
    827.009000
    827.486000
    827.963000
    828.440000
    828.917000
    829.394000
    829.872000
    830.349000
    830.826000
    831.303000
    831.781000
    832.258000
    832.735000
    833.213000
    833.690000
    834.167000
    834.645000
    835.122000
    835.600000
    836.077000
    836.555000
    837.033000
    837.510000
    837.988000
    838.466000
    838.943000
    839.421000
    839.899000
    840.377000
    840.854000
    841.332000
    841.810000
    842.288000
    842.766000
    843.244000
    843.722000
    844.200000
    844.678000
    845.156000
    845.634000
    846.112000
    846.590000
    847.068000
    847.547000
    848.025000
    848.503000
    848.981000
    849.460000
    849.938000
    850.417000
    850.895000
    851.373000
    851.852000
    852.330000
    852.809000
    853.287000
    853.766000
    854.244000
    854.723000
    855.202000
    855.680000
    856.159000
    856.638000
    857.117000
    857.595000
    858.074000
    858.553000
    859.032000
    859.511000
    859.990000
    860.469000
    860.948000
    861.427000
    861.906000
    862.385000
    862.864000
    863.343000
    863.822000
    864.301000
    864.781000
    865.260000
    865.739000
    866.218000
    866.698000
    867.177000
    867.656000
    868.136000
    868.615000
    869.095000
    869.574000
    870.054000
    870.533000
    871.013000
    871.492000
    871.972000
    872.452000
    872.931000
    873.411000
    873.891000
    874.371000
    874.850000
    875.330000
    875.810000
    876.290000
    876.770000
    877.250000
    877.730000
    878.210000
    878.690000
    879.170000
    879.650000
    880.130000
    880.610000
    881.090000
    881.570000
    882.051000
    882.531000
    883.011000
    883.491000
    883.972000
    884.452000
    884.932000
    885.413000
    885.893000
    886.374000
    886.854000
    887.335000
    887.815000
    888.296000
    888.776000
    889.257000
    889.738000
    890.218000
    890.699000
    891.180000
    891.660000
    892.141000
    892.622000
    893.103000
    893.584000
    894.065000
    894.546000
    895.027000
    895.508000
    895.989000
    896.470000
    896.951000
    897.432000
    897.913000
    898.394000
    898.875000
    899.356000
    899.838000
    900.319000
    900.800000
    901.281000
    901.763000
    902.244000
    902.726000
    903.207000
    903.688000
    904.170000
    904.651000
    905.133000
    905.615000
    906.096000
    906.578000
    907.059000
    907.541000
    908.023000
    908.505000
    908.986000
    909.468000
    909.950000
    910.432000
    910.914000
    911.396000
    911.877000
    912.359000
    912.841000
    913.323000
    913.805000
    914.287000
    914.770000
    915.252000
    915.734000
    916.216000
    916.698000
    917.180000
    917.663000
    918.145000
    918.627000
    919.110000
    919.592000
    920.074000
    920.557000
    921.039000
    921.522000
    922.004000
    922.487000
    922.969000
    923.452000
    923.935000
    924.417000
    924.900000
    925.383000
    925.865000
    926.348000
    926.831000
    927.314000
    927.797000
    928.279000
    928.762000
    929.245000
    929.728000
    930.211000
    930.694000
    931.177000
    931.660000
    932.143000
    932.627000
    933.110000
    933.593000
    934.076000
    934.559000
    935.043000
    935.526000
    936.009000
    936.492000
    936.976000
    937.459000
    937.943000
    938.426000
    938.910000
    939.393000
    939.877000
    940.360000
    940.844000
    941.327000
    941.811000
    942.295000
    942.778000
    943.262000
    943.746000
    944.230000
    944.714000
    945.197000
    945.681000
    946.165000
    946.649000
    947.133000
    947.617000
    948.101000
    948.585000
    949.069000
    949.553000
    950.037000
    950.521000
    951.006000
    951.490000
    951.974000
    952.458000
    952.943000
    953.427000
    953.911000
    954.396000
    954.880000
    955.364000
    955.849000
    956.333000
    956.818000
    957.302000
    957.787000
    958.272000
    958.756000
    959.241000
    959.726000
    960.210000
    960.695000
    961.180000
    961.665000
    962.149000
    962.634000
    963.119000
    963.604000
    964.089000
    964.574000
    965.059000
    965.544000
    966.029000
    966.514000
    966.999000
    967.484000
    967.969000
    968.454000
    968.940000
    969.425000
    969.910000
    970.395000
    970.881000
    971.366000
    971.851000
    972.337000
    972.822000
    973.308000
    973.793000
    974.279000
    974.764000
    975.250000
    975.735000
    976.221000
    976.707000
    977.192000
    977.678000
    978.164000
    978.650000
    979.135000
    979.621000
    980.107000
    980.593000
    981.079000
    981.565000
    982.051000
    982.537000
    983.023000
    983.509000
    983.995000
    984.481000
    984.967000
    985.453000
    985.939000
    986.425000
    986.912000
    987.398000
    987.884000
    988.370000
    988.857000
    989.343000
    989.830000
    990.316000
    990.802000
    991.289000
    991.775000
    992.262000
    992.749000
    993.235000
    993.722000
    994.208000
    994.695000
    995.182000
    995.668000
    996.155000
    996.642000
    997.129000
    997.616000
    998.103000
    998.589000
    999.076000
    999.563000
    1000.050000
    1000.537000
    1001.024000
    1001.511000
    1001.998000
    1002.486000
    1002.973000
    1003.460000
    1003.947000
    1004.434000
    1004.922000
    1005.409000
    1005.896000
    1006.384000
    1006.871000
    1007.358000
    1007.846000
    1008.333000
    1008.821000
    1009.308000
    1009.796000
    1010.283000
    1010.771000
    1011.258000
    1011.746000
    1012.234000
    1012.721000
    1013.209000
    1013.697000
    1014.185000
    1014.673000
    1015.160000
    1015.648000
    1016.136000
    1016.624000
    1017.112000
    1017.600000
    1018.088000
    1018.576000
    1019.064000
    1019.552000
    1020.040000
    1020.528000
    1021.017000
    1021.505000
    1021.993000
    1022.481000
    1022.970000
    1023.458000
    1023.946000
    1024.435000
    1024.923000
    1025.411000
    1025.900000
    1026.388000
    1026.877000
    1027.365000
    1027.854000
    1028.343000
    1028.831000
    1029.320000
    1029.808000
    1030.297000
    1030.786000
    1031.275000
    1031.763000
    1032.252000
    1032.741000
    1033.230000
    1033.719000
    1034.208000
    1034.697000
    1035.186000
    1035.675000
    1036.164000
    1036.653000
    1037.142000
    1037.631000
    1038.120000
    1038.609000
    1039.099000
    1039.588000
    1040.077000
    1040.566000
    1041.056000
    1041.545000
    1042.034000
    1042.524000
    1043.013000
    1043.503000
    1043.992000
    1044.482000
    1044.971000
    1045.461000
    1045.950000
    1046.440000
    1046.929000
    1047.419000
    1047.909000
    1048.399000
    1048.888000
    1049.378000
    1049.868000
    1050.358000
    1050.848000
    1051.338000
    1051.827000
    1052.317000
    1052.807000
    1053.297000
    1053.787000
    1054.277000
    1054.768000
    1055.258000
    1055.748000
    1056.238000
    1056.728000
    1057.218000
    1057.709000
    1058.199000
    1058.689000
    1059.180000
    1059.670000
    1060.160000
    1060.651000
    1061.141000
    1061.632000
    1062.122000
    1062.613000
    1063.103000
    1063.594000
    1064.084000
    1064.575000
    1065.066000
    1065.557000
    1066.047000
    1066.538000
    1067.029000
    1067.520000
    1068.010000
    1068.501000
    1068.992000
    1069.483000
    1069.974000
    1070.465000
    1070.956000
    1071.447000
    1071.938000
    1072.429000
    1072.920000
    1073.411000
    1073.903000
    1074.394000
    1074.885000
    1075.376000
    1075.868000
    1076.359000
    1076.850000
    1077.342000
    1077.833000
    1078.324000
    1078.816000
    1079.307000
    1079.799000
    1080.290000
    1080.782000
    1081.274000
    1081.765000
    1082.257000
    1082.748000
    1083.240000
    1083.732000
    1084.224000
    1084.715000
    1085.207000
    1085.699000
    1086.191000
    1086.683000
    1087.175000
    1087.667000
    1088.159000
    1088.651000
    1089.143000
    1089.635000
    1090.127000
    1090.619000
    1091.111000
    1091.603000
    1092.095000
    1092.588000
    1093.080000
    1093.572000
    1094.064000
    1094.557000
    1095.049000
    1095.542000
    1096.034000
    1096.526000
    1097.019000
    1097.511000
    1098.004000
    1098.497000
    1098.989000
    1099.482000
    1099.974000
    1100.467000
    1100.960000
    1101.452000
    1101.945000
    1102.438000
    1102.931000
    1103.424000
    1103.916000
    1104.409000
    1104.902000
    1105.395000
    1105.888000
    1106.381000
    1106.874000
    1107.367000
    1107.860000
    1108.354000
    1108.847000
    1109.340000
    1109.833000
    1110.326000
    1110.819000
    1111.313000
    1111.806000
    1112.299000
    1112.793000
    1113.286000
    1113.780000
    1114.273000
    1114.767000
    1115.260000
    1115.754000
    1116.247000
    1116.741000
    1117.234000
    1117.728000
    1118.222000
    1118.715000
    1119.209000
    1119.703000
    1120.197000
    1120.690000
    1121.184000
    1121.678000
    1122.172000
    1122.666000
    1123.160000
    ];

nom1024 = [0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.006667
0.016667
0.000000
0.000000
0.000000
0.013333
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.013333
0.000000
0.000000
0.033333
0.080000
0.016667
0.016667
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.003333
0.020000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.026667
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.020000
0.000000
0.000000
0.040000
0.046667
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.006667
0.060000
0.066667
0.050000
0.003333
0.060000
0.093333
0.046667
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.016667
0.003333
0.000000
0.000000
0.000000
0.000000
0.000000
0.000000
0.003333
0.010000
0.000000
0.063333
0.063333
0.013333
0.000000
0.000000
0.016667
0.000000
0.033333
0.043333
0.090000
0.120000
0.193333
0.096667
0.140000
0.076667
0.156667
0.173333
0.196667
0.206667
0.233333
0.216667
0.200000
0.083333
0.046667
0.010000
0.000000
0.000000
0.016667
0.056667
0.070000
0.060000
0.070000
0.030000
0.083333
0.053333
0.073333
0.080000
0.116667
0.166667
0.246667
0.220000
0.243333
0.146667
0.180000
0.210000
0.160000
0.196667
0.193333
0.220000
0.300000
0.286667
0.313333
0.316667
0.243333
0.286667
0.303333
0.306667
0.226667
0.150000
0.206667
0.240000
0.153333
0.110000
0.136667
0.233333
0.346667
0.253333
0.286667
0.340000
0.363333
0.356667
0.416667
0.353333
0.396667
0.353333
0.346667
0.410000
0.396667
0.376667
0.360000
0.333333
0.330000
0.323333
0.260000
0.250000
0.176667
0.263333
0.270000
0.313333
0.346667
0.340000
0.306667
0.316667
0.216667
0.226667
0.226667
0.166667
0.053333
0.030000
0.000000
0.000000
0.010000
0.000000
0.000000
0.030000
0.016667
0.000000
0.016667
0.020000
0.096667
0.156667
0.096667
0.163333
0.170000
0.153333
0.116667
0.070000
0.023333
0.153333
0.190000
0.176667
0.166667
0.210000
0.223333
0.286667
0.186667
0.140000
0.243333
0.286667
0.196667
0.226667
0.246667
0.280000
0.316667
0.260000
0.203333
0.273333
0.230000
0.096667
0.046667
0.020000
0.090000
0.200000
0.206667
0.190000
0.220000
0.293333
0.296667
0.250000
0.150000
0.160000
0.163333
0.153333
0.123333
0.093333
0.100000
0.153333
0.110000
0.180000
0.243333
0.273333
0.320000
0.260000
0.176667
0.196667
0.166667
0.146667
0.113333
0.093333
0.136667
0.116667
0.093333
0.110000
0.123333
0.113333
0.040000
0.050000
0.076667
0.140000
0.143333
0.096667
0.123333
0.203333
0.206667
0.220000
0.293333
0.353333
0.403333
0.456667
0.466667
0.496667
0.453333
0.366667
0.273333
0.300000
0.293333
0.253333
0.240000
0.330000
0.370000
0.443333
0.390000
0.380000
0.466667
0.520000
0.450000
0.376667
0.296667
0.396667
0.366667
0.306667
0.260000
0.366667
0.300000
0.406667
0.306667
0.413333
0.386667
0.333333
0.340000
0.373333
0.336667
0.396667
0.266667
0.233333
0.260000
0.213333
0.280000
0.283333
0.233333
0.280000
0.333333
0.440000
0.550000
0.550000
0.543333
0.563333
0.546667
0.543333
0.480000
0.420000
0.423333
0.426667
0.400000
0.393333
0.553333
0.586667
0.530000
0.496667
0.583333
0.643333
0.666667
0.513333
0.480000
0.506667
0.580000
0.490000
0.496667
0.516667
0.566667
0.616667
0.566667
0.606667
0.580000
0.620000
0.670000
0.706667
0.696667
0.776667
0.693333
0.876667
0.810000
0.733333
0.763333
0.800000
0.830000
0.883333
0.850000
0.840000
0.946667
0.913333
0.873333
0.853333
0.906667
0.893333
0.876667
0.893333
0.956667
1.010000
1.063333
0.983333
0.956667
1.066667
1.056667
0.990000
1.000000
1.013333
1.036667
1.050000
1.080000
1.053333
1.036667
1.056667
1.020000
1.133333
1.100000
1.110000
1.146667
1.263333
1.276667
1.340000
1.353333
1.486667
1.416667
1.453333
1.436667
1.383333
1.383333
1.310000
1.263333
1.420000
1.383333
1.483333
1.623333
1.663333
1.686667
1.786667
1.736667
1.993333
1.996667
2.030000
1.990000
2.170000
2.210000
2.333333
2.120000
2.090000
2.180000
2.330000
2.363333
2.466667
2.636667
2.863333
3.043333
3.083333
3.273333
3.416667
3.533333
3.660000
3.766667
3.960000
4.263333
4.406667
4.693333
4.860000
4.990000
5.350000
5.620000
5.786667
6.010000
6.170000
6.466667
6.800000
6.943333
7.356667
7.566667
7.910000
8.186667
8.556667
8.966667
9.470000
9.913333
10.473333
10.823333
11.283333
11.730000
12.110000
12.573333
12.933333
13.493333
14.073333
14.493333
14.886667
15.573333
16.220000
16.540000
17.010000
17.503333
18.160000
19.026667
19.626667
19.943333
20.743333
21.480000
22.216667
22.713333
23.346667
23.796667
24.516667
25.240000
25.940000
26.543333
27.543333
28.233333
28.973333
29.890000
30.580000
31.240000
32.163333
33.026667
33.870000
34.956667
35.803333
36.636667
37.700000
38.886667
39.660000
40.656667
41.533333
42.590000
43.600000
44.953333
46.150000
47.290000
48.240000
49.553333
50.806667
52.306667
53.263333
54.963333
56.330000
57.763333
58.666667
60.830000
61.676667
63.480000
65.106667
66.896667
67.633333
69.450000
70.726667
72.506667
74.220000
76.453333
78.273333
79.920000
81.833333
83.966667
85.540000
87.490000
89.663333
91.876667
93.466667
95.890000
98.433333
100.496667
102.966667
105.520000
107.596667
109.650000
112.860000
114.750000
117.643333
120.133333
123.036667
124.703333
128.193333
129.863333
132.970000
136.090000
139.093333
141.503333
144.636667
146.873333
150.230000
152.550000
155.826667
158.530000
161.940000
164.496667
167.820000
170.413333
173.543333
176.260000
179.376667
182.350000
185.106667
188.056667
190.310000
193.440000
195.433333
198.953333
201.816667
203.956667
206.706667
209.400000
212.543333
215.203333
217.870000
220.056667
222.623333
224.990000
227.750000
229.216667
232.026667
234.960000
236.900000
239.780000
242.046667
242.983333
245.203333
247.913333
248.850000
250.766667
253.113333
254.720000
255.940000
259.080000
260.306667
260.393333
262.066667
265.303333
265.923333
268.416667
269.336667
270.406667
271.870000
274.523333
275.913333
278.330000
280.433333
282.836667
285.370000
285.523333
288.826667
290.680000
294.073333
295.346667
299.230000
299.686667
303.936667
306.166667
308.963333
310.960000
315.463333
318.173333
321.213333
325.603333
329.053333
333.486667
336.996667
340.630000
343.976667
348.940000
353.333333
358.006667
362.000000
365.783333
371.113333
375.236667
380.740000
387.090000
392.366667
396.386667
401.563333
405.073333
411.033333
416.753333
422.746667
429.413333
435.193333
440.690000
447.946667
452.360000
458.756667
465.003333
472.276667
478.333333
485.870000
492.573333
499.406667
503.743333
511.623333
520.060000
527.973333
539.296667
545.943333
554.010000
562.466667
571.076667
579.156667
589.100000
595.440000
605.660000
614.103333
623.850000
636.720000
642.966667
653.706667
662.860000
672.383333
681.450000
695.450000
707.720000
716.056667
727.380000
738.736667
745.170000
756.250000
775.040000
781.436667
792.883333
800.996667
814.373333
825.153333
840.493333
854.560000
869.053333
880.133333
893.276667
906.263333
914.366667
930.763333
942.766667
963.510000
973.903333
986.676667
998.380000
1017.370000
1026.126667
1041.173333
1055.116667
1062.836667
1073.156667
1093.860000
1105.710000
1113.113333
1123.166667
1136.590000
1148.786667
1161.623333
1171.643333
1182.483333
1189.046667
1195.533333
1212.096667
1216.440000
1221.516667
1227.066667
1230.876667
1235.283333
1243.400000
1247.790000
1255.470000
1255.163333
1249.836667
1254.683333
1253.576667
1252.410000
1254.673333
1257.380000
1251.630000
1245.753333
1237.950000
1235.423333
1227.110000
1221.503333
1216.470000
1208.406667
1196.540000
1188.936667
1183.656667
1175.390000
1160.890000
1152.630000
1138.010000
1124.616667
1111.063333
1099.056667
1084.126667
1078.153333
1065.150000
1050.610000
1038.720000
1026.093333
1011.126667
1001.363333
985.086667
970.000000
953.523333
935.540000
920.833333
907.023333
887.243333
872.406667
854.473333
838.280000
822.636667
807.646667
791.716667
773.493333
756.010000
739.910000
719.593333
700.980000
683.240000
663.663333
646.463333
627.920000
605.466667
586.133333
567.960000
550.386667
535.790000
517.460000
500.216667
484.640000
470.503333
454.656667
438.066667
419.236667
402.880000
387.430000
369.130000
354.313333
340.473333
325.646667
313.750000
298.320000
283.503333
274.420000
259.840000
248.216667
237.520000
225.450000
217.170000
204.706667
191.923333
184.280000
174.126667
165.790000
155.400000
146.263333
140.153333
136.046667
128.713333
122.460000
116.690000
111.650000
106.556667
99.953333
93.090000
89.513333
84.036667
81.213333
78.170000
68.313333
66.316667
61.570000
56.556667
48.770000
45.716667
41.200000
46.640000
46.173333
48.163333
48.043333
50.180000
44.403333
46.026667
43.706667
44.496667
37.410000
32.940000
31.503333
33.363333
32.010000
27.193333
20.090000
22.136667
22.666667
21.290000
23.756667
20.423333
21.173333
22.703333
20.683333
23.156667
24.246667
17.833333
20.673333
17.910000
18.970000
21.773333
18.196667
17.046667
20.803333
    ];

if exist('wavel', 'var')    % if wavel is not defined, return it and nothing else
    spectrum = interp1(wavel_nom, nom1024, wavel, 'pchip', 0)*mArea;
    totPower = trapz(wavel, spectrum);
else
    spectrum = [];
    totPower = [];
end

end

