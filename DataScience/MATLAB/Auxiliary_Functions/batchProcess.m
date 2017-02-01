function batchProcess( pathn )
% function batchProcess( pathn )
% Function used to generate the process structure from a batch of files
% within the directory defined by pathn.
%
% Inputs
% pathn - path of directory containing files to be processed. They can be
% either sweep files or bin files.
%
% Outputs
% Files are saved to the same directory, with the same root name and with a "_process.mat" extension.
%
% See also
% sweep2process
%
% P. Silveira, Feb. 2016
% BSX Proprietary

SWEEP_SUFFIX = '_sweep.mat';
%SWEEP_SUFFIX = '_process.mat';
PROCESS_SUFFIX = '_process.mat';
BIN_SUFFIX = '.bin';

if ~exist('pathn', 'var')
    pathn = [pwd '\'];
end

files = dir([pathn '*' SWEEP_SUFFIX]);
EXT = SWEEP_SUFFIX;

if isempty(files)
    files = dir([pathn '*' BIN_SUFFIX]);
    EXT = BIN_SUFFIX;
end

extLen = length(EXT);
fileNum = length(files);
for ii = 1:fileNum
    filen = files(ii).name;
    sweep = getSweep(filen);
    [~, rootn] = fileparts(filen);
    rootn = filen(1:end-extLen);
    new_filen = [pathn rootn PROCESS_SUFFIX];
    process = sweep2process(sweep);
    
%     load(filen);
%     sweep = getSweep([pathn rootn '_sweep.mat']);
%     new_filen = [pathn 'WARMUP\' rootn '_warmup.mat'];
%     warmup.SmO2 = process.SmO2;
%     warmup.tHb = process.tHb;
%     warmup.HR = sweep.HR;
%     warmup.PacePower = sweep.PacePower;
%     if isfield(sweep, 'imu_samp_rate')
%         r = sweep.imu_samp_rate / sweep.samp_rate;
%         warmup.Acc_y = sweep.Acc_y(1:r:end);
%         warmup.Acc_z = sweep.Acc_z(1:r:end);
%         warmup.Gyro_x = sweep.Gyro_x(1:r:end);
%         warmup.Gyro_y = sweep.Gyro_y(1:r:end);
%         warmup.Pace_on_dev = sweep.Pace_on_dev(1:r:end);
%         warmup.imu_samp_rate = sweep.samp_rate;
%     end
%     warmup.samp_rate = sweep.samp_rate;
%     warmup.cpuTemp = sweep.cpuTemp;
%     warmup.pH2O = process.pH2O;
%     warmup.tissueTF = process.tissueTF;
%     save(new_filen, 'warmup');
    
    save(new_filen, 'process');
    
    %    csvwrite([pathn rootn 'SmO2.csv'], [sweep.time process.SmO2 process.tHb sweep.HR]);
end
