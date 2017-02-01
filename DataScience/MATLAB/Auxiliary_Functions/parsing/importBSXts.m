%% Build BSX  Data Timeseries
% Get BSX start datetime array
bsxStart = datetime([sweep.date ' ' sweep.UTCtime],'InputFormat','y/MM/dd HH:mm:ss');

% Counts Time
bsxCOUNTStime = bsxStart: seconds(1/sweep.samp_rate): bsxStart + seconds( (length(sweep.time)-1)/sweep.samp_rate); %hack to make sure that the time length is longer than the data length

timeoffset = length(sweep.count15)-length(bsxCOUNTStime);
% Bad Hack to make up for small offset in number of time elements 
while timeoffset>0
   bsxCOUNTStime(end+1) = bsxCOUNTStime(end)+ seconds(1/sweep.samp_rate); % Make bsxCOUNTStime longer
   timeoffset = length(sweep.count15)-length(bsxCOUNTStime);
end

if timeoffset<0
    bsxCOUNTStime = bsxCOUNTStime(1:length(sweep.count15)); % make bsxCountstime shorter
end

% IMU Time
bsxIMUtstime = bsxStart: seconds(1/sweep.imu_samp_rate): bsxStart + seconds( length(sweep.time)/sweep.imu_samp_rate - 1/sweep.imu_samp_rate );
% Bad Hack to make up for small offset in number of time elements 
timeoffset = length(sweep.Acc_y)-length(bsxIMUtstime);
while timeoffset>0
   bsxIMUtstime(end+1) = bsxIMUtstime(end)+ seconds(1/sweep.samp_rate); % Make bsxIMUtstime longer
   timeoffset = length(sweep.Acc_y)-length(bsxIMUtstime);
end

if timeoffset<0
    bsxIMUtstime = bsxIMUtstime(1:length(sweep.Acc_y)); % make bsxIMUtstime shorter
end

        

COUNTSts = timeseries( [sweep.count15 sweep.count27], datestr(bsxCOUNTStime), 'name', 'Counts');
COUNTSts.DataInfo.units = 'ADC';

% ODs
ODts = timeseries([process.OD15, process.OD27], datestr(bsxCOUNTStime), 'name', 'ODs');
ODts.DataInfo.units = 'OD Units';

% tHb
tHBts = timeseries(process.tHb, datestr(bsxCOUNTStime), 'name', 'tHB');
tHBts.DataInfo.units = 'g/dL';

% sMO2
sMO2ts = timeseries(process.rawSmO2, datestr(bsxCOUNTStime), 'name', 'sMO2');
sMO2ts.DataInfo.units = '%';

% IMU
ACCts = timeseries([sweep.Acc_y sweep.Acc_z], datestr(bsxIMUtstime), 'name', 'Accelerometer (Y and Z)');
ACCts.DataInfo.units = 'g';

GYROts = timeseries([sweep.Gyro_x sweep.Gyro_y], datestr(bsxIMUtstime), 'name', 'Gyro (X and Y)');
GYROts.DataInfo.units = 'deg';