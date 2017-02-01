% Script used to analyze AllCounts calibration data from all failed files in a
% given directory.
% Output is saved in a Powerpoint file
%
% P. Silveira, Feb. 2015
%

%% Initialize
clear all
close all
%leds = {'665', '810', '850', '950'};
pathname = 'C:\Users\paulobsx\Google Drive\Tech_RD\Sensor\Development\Design & Development Engineering\Calibration\02032015\';
PASSFAIL_PATH = '\\nas\homes\paulo\CloudStation\BSX_Athletics\Docs\Calibration\INO432\CalibrationFiles\CalibrationPassCriteriaModel.json';
%MIN_PASS = [282669281,232586254,274788318,357803530,368848382,257079492,323916876,428116331];
%MAX_PASS = [375263487,396356835,425983145,495779080,472439051,470211535,487250850,565723327];

%% Data input

% Input MIN and MAX counts pass/fail criteria
h = fopen(PASSFAIL_PATH);   % open jason file with pass/fail criteria
str = fread(h,'*char');     % read file contents
fclose(h);
temp = parse_json(str');    % parse json data
MIN_PASS = cell2mat(temp{1}.FullPwrAllCntMinThreshold);
MAX_PASS = cell2mat(temp{1}.FullPwrAllCntMaxThreshold);

% Open output PowerPoint file
[ppt_filen, ppt_pathn] = uiputfile('*.ppt', 'Select PowerPoint output file');
ppt_file = [ppt_pathn ppt_filen];
ppt_obj = saveppt2(ppt_file, 'init');    % initialize PowerPoint file

oldpath = pwd;
cd(pathname);
%[filename, pathname] = uigetfile('*FAILURE*binallcnt.csv', 'Pick files with calibration data', 'MultiSelect', 'on');
[filename, pathname] = uigetfile('*binallcnt.csv', 'Pick files with calibration data', 'MultiSelect', 'on');
saveppt2('ppt', ppt_obj, 'figure',0,'text',['Analysis of devices saved in path: \n' pathname]);

temp = size(filename);
num_files = temp(2);    % find number of files to be read

figure(2);  % persistent figure
plot(MAX_PASS,'r')
hold on
plot(MIN_PASS,'r')
grid
xlabel('LED')
ylabel('Count/OD')
set(gcf, 'Position', [1183 219 818 420]);

figure(1)
set(gcf, 'Position', [312 223 818 420]);

for ii = 1:num_files,
    data = csvread([pathname char(filename(ii))],3,0);  % Read file, skipping first 3 rows (header)
    allData(:,:) = data(:,1:end-1);   % save all data, ignoring last column (blank)
    maxCnt = allData(end,:);
    h = figure(1);
    plot(maxCnt,'k')
    hold on
    plot(MAX_PASS,'r')
    plot(MIN_PASS,'r')
    grid
    xlabel('LED')
    ylabel('Count/OD')
    legend('Device', 'Max. pass', 'Min. pass', 'Location', 'Best')
    hold off
        
    saveppt2('ppt', ppt_obj, 'text', [char(filename(ii)) '\n' 'Action: None'], 'driver', 'bitmap', 'stretch', 'off');
%    saveppt(ppt_file, char(filename(ii)));

    h = figure(2);  % persistent figure
    plot(maxCnt,'k')
 
end
hold off
saveppt2('ppt', ppt_obj, 'title', 'Aggregate plot of all devices', 'driver', 'bitmap');
saveppt2(ppt_file, 'ppt', ppt_obj, 'close');

cd(oldpath)
disp('Done!')


