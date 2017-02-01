%% Find Laps
for headerlinesIn=1:100   
    delimiterIn = ',';
    wahooEvents = importdata('Wahoo.csv',delimiterIn,headerlinesIn);
    if isstruct(wahooEvents)
        if isfield(wahooEvents,'data')
            if size(wahooEvents.data,1)>1 && size(wahooEvents.data,2)>1 % The wahoo file always has some headers that extend until the laps section (this is my check to find that row)
                break
            end
        end
    end
end

%% Add the Events to the Timeseries 

% Add 1st lap
e = tsdata.event('Lap 1',datestr(time(1)));
e.Units = 'seconds';        % Specify the units for time
HRts = addevent(HRts,e);    % Add the event to HR
PWRts = addevent(PWRts,e);  % Add the event to PWR
COUNTSts = addevent(COUNTSts,e);  % Add the event to COUNTS
ACCts = addevent(ACCts,e);  % Add the event to ACC
GYROts = addevent(GYROts,e);  % Add the event to GYRO
COREts = addevent(COREts,e);  % Add the event to CORE
ODts = addevent(ODts,e);  % Add the event to CORE
tHBts = addevent(tHBts,e);  % Add the event to CORE
sMO2ts = addevent(sMO2ts,e);  % Add the event to CORE

for i=2:size(wahooEvents.data,1)    
   e = tsdata.event(['Lap ' num2str(i)],datestr(time(round(wahooEvents.data(i,2)))) );
   e.Units = 'seconds';        % Specify the units for time
   HRts = addevent(HRts,e);    % Add the event to HR
   PWRts = addevent(PWRts,e);  % Add the event to PWR
   COUNTSts = addevent(COUNTSts,e);  % Add the event to COUNTS
   ACCts = addevent(ACCts,e);  % Add the event to ACC
   GYROts = addevent(GYROts,e);  % Add the event to GYRO
   COREts = addevent(COREts,e);  % Add the event to CORE
   ODts = addevent(ODts,e);  % Add the event to CORE
   tHBts = addevent(tHBts,e);  % Add the event to CORE
   sMO2ts = addevent(sMO2ts,e);  % Add the event to CORE
end