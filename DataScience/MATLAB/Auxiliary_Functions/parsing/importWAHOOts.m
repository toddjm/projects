%% Import wahoo Data
% Get wahoo start time 
wahoo = importdata('Wahoo.csv');
C = strsplit(wahoo.textdata{2},',')'; % The date is in the 2nd row in Hour
Y = str2double(C{2,1});
M = str2double(C{4,1});
D = str2double(C{6,1});
H = str2double(C{8,1});
MI= str2double(C{10,1});
S = str2double(C{12,1});
wahooStart = datetime(Y,M,D,H,MI,S);

% Laps
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


% Get the wahoo sensor data
wahoo = importdata('Wahoo.csv',delimiterIn,headerlinesIn+size(wahooEvents.data,1)+2); % need to step two rows after the end of the laps section to enter Data Section


% Build wahoo Timeseries
time = wahooStart: seconds(1): wahooStart+ seconds(length(wahoo.data)-1);
HRts = timeseries(wahoo.data(:,12), datestr(time), 'name', 'Heart Rate');
HRts.DataInfo.units = 'bpm';
PWRts = timeseries(wahoo.data(:,6), datestr(time), 'name', 'Power');
PWRts.DataInfo.units = 'watts';

e = tsdata.event('Lap 1',datestr(time(1)));
e.Units = 'seconds';        % Specify the units for time
HRts = addevent(HRts,e);    % Add the event to HR
for i=2:size(wahooEvents.data,1)    
   e = tsdata.event(['Lap ' num2str(i)],datestr(time(round(wahooEvents.data(i,2)))));
   e.Units = 'seconds';        % Specify the units for time
   HRts = addevent(HRts,e);    % Add the event to HR
end
