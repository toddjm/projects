function out = subStruct( in, range )
% function out = subStruct( in, range )
% Function used to assign a range of a structure array to another structure.
%
% Example
% in.f1 = diag([1:100]);    % create a structure in with fields f1 and f2, each with a 100x100 array
% in.f2 = rand(100,100);
% out = subStruct(in, repmat([1:10],10,1));  % out contains 10x10 fields f1 and f2, a subset of in.
%
% Inputs
% in - input structure with arrayed fields 
% range - range of indices to be extracted
% 
% Outputs
% out - output structure with the same fields as in and with a sub-range of
%  array elements defined by range
%
% See also
% genBoxPlots
%
% P. Silveira, Sep. 2015
% BSX Proprietary


% if ~exist('flds', 'var')
     flds = fields(in);  % use all fields
% end
%flds2 = fields(in.(flds{1})); % second layer of fields. Assumes all first layer fields have the same sub-fields.

for ii = 1:numel(flds)
    this_field = in.(flds{ii});
    if length(this_field) < max(range(:))   % don't touch fields that are shorter than range
        out.(flds{ii}) = [this_field];
    else
        out.(flds{ii}) = [this_field(range)];
    end
end

end
