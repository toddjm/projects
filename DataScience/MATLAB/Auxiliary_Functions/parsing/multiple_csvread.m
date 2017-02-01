function [data, fnames, pathn]=multiple_csvread(filenames)

% [data, fnames, pathn]=multiple_csvread(filenames)
%
% Will read in multiple Comma Separated Value (CSV) files, in the cell array filenames.
% Use filenames='' to be given a 
% file dialog window that allows you to select files. The function
% returns an array of input data in data, and will optionally return the
% file names (fnames) in a cell array and the path from which they came
% (pathn) also as a cell array.
%
% Input parameters:
%
% filenames - cell array of input file names. May also be a char array. If
% empty, prompts the user for the directory that contains files.
% 
% Output parameters:
%
% data - array of data
% fnames - cell array of image file names
% pathn - path where data files are located
%

% save the current path
oldp=pwd;

if ~exist('filenames', 'var')
    % have user point to data files
    [fnames,pathn]=uigetfile(['*.csv'],'Choose data Files', 'Multiselect', 'on');
    fnames=sort(fnames); % uigetfiles reverses order of picking
    cd(pathn) % change directories
    pathn={pathn};
else
    if iscell(filenames)
        fnames=filenames;
        pathn='';
    else
        if ischar(filenames)
            % convert to a cell array
            temp = size(filenames);
            for ii = 1:temp(1),
                fnames{ii} = filenames(ii,:);
            end
        else
            error('Input "filenames" must be either a cell or a char array.')
        end
    end
end

    % load in each data file and store their contents on array data
for i=1:length(fnames)
    % get path
    [tp,n,e]=fileparts(fnames{i});
    if isempty(tp)
        pathn{i}=pwd;
    else
        pathn{i}=tp;
    end
    
    % read in data file and find its size
    tmp=csvread(fnames{i});
    tmpsz=size(tmp);
    if i==1 % first time through record "standard" size
        sz = tmpsz;
    else % other times, make sure the current data file matches the "standard" size
        if any(tmpsz ~= sz) % if it doesn't match ask the user what to do
            ButtonName=questdlg('The data file %s is not the same size as the previous files, what shall I do?', ...
                       'Multiple csvread', ...
                       'Retry','Skip','Abort','Abort');
 
            switch ButtonName,
                case 'Retry', 
                    i=i-1;
                    continue;
                case 'Skip',
                    continue;
                case 'Abort',
                    return;
            end % switch
        end
    end
    
    % store data
    data(sz(1)*(i-1)+1:sz(1)*i,:) = tmp(:,:);
end

% change back to the original directory
cd(oldp)
