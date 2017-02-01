function [ irradiance, wavelength ] = readOO( filen, pathn)
% function [ irradiance, wavelength ] = readOO( filen, pathn )
%   Reads Ocean Optics CSV file stored in pathn and returns irradiance and
%   wavelengths as two output vectors. Returns the averaged irradiance if
%   filen is a cell structure containing multiple input files.
%
% Inputs
% filen - input files. Can be a string array describing the path of a
% single file, or a cell array of strings describing the path of multiple
% files.
% pathn - path where files are located. If not provided, filen is assumed to contain the complete path.
%
% Outputs
% irradiance - vector with irradiances (uW/cm^2/nm). When using multiple
% files, the averaged irradiance is returned.
% wavelength - vector with wavelengths (nm). When using multiple files,
% wavelegnths are expected to be the same for all files. Otherwise, an
% error is generated.
%
% See also
% fscanf, dlmread
%
% P. Silveira, June 2015
% BSX Proprietary

% Initializations
%HEADERLINES = 17;   % header lines to skip
%HEADERSTRINGS = 80; % # of strings to read when looking for end of header
FORMAT = '%f %f';    % data format
SIZEDATA = [2 Inf];
HEADER_END = 'Data<<<<<';  % string indicating end of header

% Read data

if iscell(filen) % check for multiple files
    irradiance = 0;
    wavelength = 0;
    num_files = length(filen);
    for ii = 1:num_files
        if exist('pathn', 'var')
            fid = fopen([pathn '\' filen{ii}]);
        else
            fid = fopen(filen{ii});
        end
        header = fscanf(fid, '%s', 1);
        while ~feof(fid) && ~strcmp(header, HEADER_END)
            header = fscanf(fid, '%s', 1);
        end
        if feof(fid)
            error(['Unable to find end of header in file ' filen{ii}])
        end
        data = fscanf(fid,FORMAT, SIZEDATA);
        fclose(fid);
        % Parse data
        irradiance = irradiance + data(2,:)';
        wavelength = data(1,:)';
        % Make sure wavelengths are the same
        if ii == 1
            wavelength_old = wavelength;
        else if any(wavelength ~= wavelength_old)
                error('Wavelengths do not match.')
            end
        end
    end
    irradiance = irradiance/num_files;
else % single file
    if exist('pathn', 'var')
        fid = fopen([pathn '\' filen]);
    else
        fid = fopen(filen);
    end
    header = fscanf(fid, '%s', 1);
    while ~feof(fid) && ~strcmp(header, HEADER_END)
        header = fscanf(fid, '%s', 1);
    end
    if feof(fid)
        error(['Unable to find end of header in file ' filen{ii}])
    end
    %     header = fscanf(fid, '%s', HEADERCHARS);
    data = fscanf(fid,FORMAT, SIZEDATA);
    fclose(fid);
    
    % Parse data
    irradiance = data(2,:)';
    wavelength = data(1,:)';
end

end

