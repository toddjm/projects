function [ out ] = avgfiltNaN( in, filter_length )
% function [ out ] = avgfiltNaN( in, filter_length )
% Function used to perform average filtering in the presence of NaNs. Also
% performs partial filtering of first samples up to filter_length.
%
% Inputs
% in - input array
% filer_length - filter length (samples)
%
% Outputs
% out - average-filtered output array. Original NaNs in input are placed back at the same index positions.
%
% See also
% medfilt1
%
% P. Silveira, May 2015
% BSX Athletics Proprietary

in_no_NaN = isfinite(in);
%in_NaN = ~isfinite(in); % locate NaNs, +Inf and -Inf
index_no_NaN = find(in_no_NaN);  % index of valid entries (not NaN)
index_NaN = find(~in_no_NaN);

if isempty(index_no_NaN)    % handle exception
    out = ones(size(in))*NaN;
    return
end

out = ones(size(in));   % allocate memory
out(index_no_NaN) = filter(ones(1,filter_length)/filter_length,1,in(in_no_NaN));

if filter_length > length(in)   % handle exception
    for ii = 1:length(in)
        out(ii) = mean(in(index_no_NaN(1:ii)));
        return
    end
end

% Process initial samples
len = length(index_no_NaN);
for ii = 1:filter_length
    out(ii) = mean(in(index_no_NaN(1:min([ii, len]))));
end
% % Process remaining samples
% for ii = filter_length+1:length(in);
%     [temp, ind1] = min(abs(index_no_NaN - (ii - filter_length)));
%     [temp, ind2] = min(abs(index_no_NaN - ii));
%     out(ii) = mean(in(index_no_NaN(ind1):index_no_NaN(ind2)));
%     %    in(index_no_NaN < ii-filter_length : index_no_NaN <= ii)
%     %    out(ii) = mean(in(index_no_NaN(ii-filter_length:ii)));
% end
% out(index_no_NaN) = filter(ones(1,filter_length)/filter_length,1,temp_in(in_no_NaN));   %
out(index_NaN) = NaN;    % restore NaN values. Also replaces other non-numeric values (Inf) with NaNs. % remove this step if you want to "fill in the blanks"

end

