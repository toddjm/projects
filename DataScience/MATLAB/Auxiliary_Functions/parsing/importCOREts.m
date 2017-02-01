%% Get CoreTem Data
corTemp = importdata('CorTemp.cvt');

% Get CoreTemp datetime array
COREtime = num2cell(corTemp.textdata,1);
COREtime = strcat(COREtime{1,1},{' '}, COREtime{1,2});
COREtime = datetime(COREtime,'InputFormat','MM/dd/y HH:mm:ss');

% Build CoreTemp Timeseries
COREts = timeseries(corTemp.data, datestr(COREtime), 'name', 'Core Temperature');
COREts.DataInfo.units = 'Degrees F';