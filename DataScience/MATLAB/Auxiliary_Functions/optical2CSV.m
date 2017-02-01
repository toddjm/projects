%% Get BSX Data

% Get Acitivty ID
% activity_ID = inputdlg('Enter activity ID number(s)');
activity = getActivity(activity_ID);

%Initialize for BSX data import
USERPATH = getenv('USERPROFILE');
BIN2CSV_CONV = ['"' USERPATH '\Google Drive\Tech_RD\Sensor\Research\SW and FW Archive\BSXInsightDeviceRecordParser\BSX.Insight.DeviceRecordParserApp.exe"'];
TEMP_CSV = [USERPATH '\temp.csv'];
TEMP_PYTHON = [USERPATH '\temp_python.csv'];
TEMP_BIN = [USERPATH '\temp.bin'];
URL_PART = 'https://';  % string always found on URLs


% Get binary file
urlwrite(activity.links.optical, TEMP_BIN); % write temporary binary file

% Convert binary to csv
COMMAND = [BIN2CSV_CONV ' "' TEMP_BIN '" ' TEMP_CSV];   % DOS command used for BIN to CSV conversion
[out, cmdout] = dos(COMMAND);
if out
    error(cmdout)
end

% Convert 20Hz CSV to Aligned CSV
COMMAND = ['python "' USERPATH '\Google Drive\Tech_RD\Sensor\Research\SW and FW Archive\Python Apps\bsx_20Hz_filter_csv.py' '" "' TEMP_CSV '" "' TEMP_PYTHON '"'];
[out, cmdout] = dos(COMMAND);
if out
    error(cmdout)
end
