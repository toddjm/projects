function [ out ] = duplicate( in )
%function [ out ] = duplicate( in )
%   Returns duplicate elements of matrix or vector in
%
% Inputs
% in - input matrix, vector or cell array
%
% Outputs
% out - array of structures with the following fields
%       element - duplicate element
%       ind - index of in where a given duplicate element is found.
%       numel(ind) = # of times a given element appears on in
%
% P. Silveira, March 2015

% Initialize
kk = 1; % duplicate index counter
out = '';

if ~iscell(in), % convert to cell array
    sz = size(in);
    for ii = 1:sz(1),
        incell{ii} = in(ii,:);
    end
else
    incell = in;
end

numin = numel(incell);
if numin < 2,   % in needs at least two elements to have a duplicate
    out = '';
    return
end

[sorted_in, indin] = sort(incell);   % sort so duplicate elements are adjacent
for ii = 1:numin-1,
    if sorted_in{ii} == sorted_in{ii+1},
        out(kk).element = sorted_in{ii};    % store new duplicate element
        out(kk).ind(1) = indin(ii);
        out(kk).ind(2) = indin(ii+1);
        jj = 2;                             % reset inter-duplicate counter
        while (ii+jj+1 < numin) & (sorted_in{ii+jj} == sorted_in{ii+jj+1}),
           jj = jj + 1;
           out(kk).ind(jj) = indin(ii+jj);
        end
        kk = kk + 1;       % increment duplicate counter
    end
end


end

