function genBoxPlots( in, flds )
% function genBoxPlots( in, flds )
% Function used to generate multiple bloxplots from a two-layer
% structured variable (in) with first-layer fields optionally defined by flds (Default = all fields)
%
% Inputs
% in - input 2-layer structure array
% flds - fields to be included in plot (cell array)
%
% Outputs
% N figures with M boxplots each, wherein N is the number of fields in the
% second layer of structure in, and M is the number of fields listed in flds (or the same number of fields
% in in array when flds is not defined).
%
% See also
% boxplot
%
% P. Silveira, Sep. 2015
% BSX Proprietary

%% Initializations
FONTSIZE = 15;  % font size of top title

if ~exist('flds', 'var')
    flds = fields(in);  % use all fields
end

num_flds = numel(flds);
flds2 = fields(in.(flds{1})); % second layer of fields. Assumes all first layer fields have the same sub-fields.
num_flds2 = numel(flds2);

%% Recursive plotting
for jj = 1:num_flds2
    figure
    set(gcf, 'Position', [718 139 969 612]);
    for ii = 1:num_flds
        temp = [in.(flds{ii}).(flds2{jj})];
        sz = size(temp);
        subplot(1,num_flds,ii)
        if num_flds == sz(2)
            boxplot(temp, flds{ii});%, 'orientation', 'horizontal')
        else
            boxplot(temp)
            title(flds{ii})
        end
        grid
    end
    annotation(gcf,'textbox', [0.4 0.9 0.1 0.1], 'String',{[flds2{jj} ' values']}, 'FontSize', FONTSIZE);
end

