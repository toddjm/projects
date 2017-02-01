%% Syncronize the timeseries

% Need to confirm the Start and Stop times are consistent with the timing
% Diagram. Also confirm the counts resolution is higher that all other
% files.
%
% BSX |__________________________________|
% WH         |____________________|
% ZH         |_______________________________|
% CT    |_______________________________|

[COUNTStsSYNC HRtsSYNC] = synchronize(COUNTSts,HRts,'union','KeepOriginalTimes',true); 
[ODtsSYNC temp] = synchronize(ODts,COUNTStsSYNC,'union','KeepOriginalTimes',true); 
[tHBtsSYNC temp] = synchronize(tHBts,COUNTStsSYNC,'union','KeepOriginalTimes',true); 
[sMO2tsSYNC temp] = synchronize(sMO2ts,COUNTStsSYNC,'union','KeepOriginalTimes',true); 
[GYROtsSYNC temp] = synchronize(GYROts,COUNTStsSYNC,'union','KeepOriginalTimes',true); 
[ACCtsSYNC temp] = synchronize(ACCts,COUNTStsSYNC,'union','KeepOriginalTimes',true); 
[PWRtsSYNC temp] = synchronize(PWRts,COUNTStsSYNC,'union','KeepOriginalTimes',true); 
[COREtsSYNC temp] = synchronize(COREts,COUNTStsSYNC,'union','KeepOriginalTimes',true); 