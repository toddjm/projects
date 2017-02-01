% Script used to enter new LED
%

USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)

LED_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Development\Release to Market Product\LED_characterization\'];

LED_PATH = uigetdir(LED_PATH, 'Select path with LED spectra');
files = uigetfile([LED_PATH '\*.txt'], 'Select files with LED spectra', 'MultiSelect', 'on');

[spe, wavel] = readOO(files, LED_PATH);

fprintf('Cut and paste the following irradiance values into one of the existing LED spectra functions.\n(e.g., fietje_1020.m)\n')
fprintf('Path = %s\n', LED_PATH)
spe(spe<0) = 0;
fprintf('%f\n', spe)