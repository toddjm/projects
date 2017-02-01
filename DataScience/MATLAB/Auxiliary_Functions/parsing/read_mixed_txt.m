function rawdata = read_mixed_txt(fileName, HEADER_ROWS, delimiter)
% If you don't know a priori how many columns are in your csv file,
% you can use a more general approach like I did in the following function.
% I first used the function FGETL to read each line of the file into a cell array.
% Then I used the function TEXTSCAN to parse each line into separate strings
% using a predefined field delimiter and treating the integer fields as strings
% that can then be converted to numeric values.
% Source : http://stackoverflow.com/questions/4747834/import-csv-file-with-mixed-data-types

if ~exist('delimiter', 'var')
    delimiter = ',';  % Default. use for CSV files
end


if ~exist('HEADER_ROWS','var')
    HEADER_ROWS = 0;
end

if ~exist(fileName, 'file')
    fid = fileName;	% assume an fid was used instead of a file name
else
    fid = fopen(fileName,'r');   %# Open the file
end
lineArray = cell(1e5,1);     %# Preallocate a cell array (ideally slightly larger than is needed)
%lineIndex = HEADER_ROWS;     %# Index of cell to place the next line in
lineIndex = 1;
nextLine = fgetl(fid);       %# Read the first line from the file
ii = 0;
while ii < HEADER_ROWS && ~isequal(nextLine, -1)    % skip header, if any
    nextLine = fgetl(fid);       %# Read the header
    ii = ii+1;
end
while ~isequal(nextLine,-1)       %# Loop while not at the end of the file
    lineArray{lineIndex} = nextLine;  %# Add the line to the cell array
    lineIndex = lineIndex+1;          %# Increment the line index
    nextLine = fgetl(fid);            %# Read the next line from the file
end
fclose(fid);                 %# Close the file
lineArray = lineArray(1:lineIndex-1);  %# Remove empty cells, if needed
for iLine = 1:lineIndex-1              %# Loop over lines
    lineData = textscan(lineArray{iLine},'%s',...    %# Read strings
        'Delimiter',delimiter);
    lineData = lineData{1};              %# Remove cell encapsulation
%    if strcmp(lineArray{iLine}(end),delimiter)  %# Account for when the line
%        lineData{end+1} = '';                     %#   ends with a delimiter
%    end
    lineArray(iLine,1:numel(lineData)) = lineData;  %# Overwrite line data
end

lineArray = cellfun(@(s) {str2double(s)},lineArray);    % Convert from cell aray of strings to cell array of doubles
rawdata = cell2mat(lineArray);                          % Convert cell array of doubles to matrix

end