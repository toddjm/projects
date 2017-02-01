function [ outStr ] = removeChar( inStr, remChar )
% function [ outStr ] = removeChar( inStr, remChar )
%
% Removes all instances of char remChar from input string inStr. outStr =
% inStr if remChar is not present in inStr.
% 
% Inputs
%
% inStr - input string
% remChar - char to be removed
%
% Outputs
%
% outStr - string with remChar removed
%
% See also
% textscan, strfind
%
% P. Silveira, March 2015

outStr = '';
temp = textscan(inStr, '%s', 'delimiter', remChar);
for ii = 1:numel(temp{1})
    outStr = [outStr temp{1}{ii}];
end

