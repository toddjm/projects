function [ moved ] = condMove( inFname, outFname )
% function [ moved ] = condMoveFile( inFname, outFname )
%
% Moves file inFname to outFname if file exists and was created today.
% 
% Inputs
% inFname - complete path of input file name (string)
% outFname - complete path of output file name (string)
%
% Output
% moved - boolean indicating whether file was moved
%
% P. Silveira, Oct. 2015
% BSX Proprietary

moved = false;
if exist(inFname, 'file')
    fileInfo = dir(inFname);
    today = date;
    if strcmp(fileInfo.date, today(1:11))   % make sure file is recent
        movefile(inFname, outFname);
        moved = true;
    end
end

