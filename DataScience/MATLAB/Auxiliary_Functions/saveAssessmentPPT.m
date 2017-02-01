function saveAssessmentPPT (pptfilen, title_text, figHandles)
%saveAssessmentPPT(ppftilen, title_text)
% Function used for saving PowerPoint file ppftilen with a title slide contained
% within string title_text
%
% Example:
% saveAssessmentPPT([pwd '\Results.ppt'], 'Result plots')
%
% Inputs
% pptfilen - complete path where PowerPoint file is to be saved
% title_text - string with text to be written to title slide
% figHandles - vector with figure handles. Default = [1:gcf]
%
% See also
% saveppt2, Run_check
%
% P. Silveira, Apr. 2015
% BSX Proprietary

disp(['Saving figures to PowerPoint file ' pptfilen]);
ppt = saveppt2(pptfilen, 'init');
if ~exist('figHandles', 'var')
    figHandles = [1:gcf]; % assumes that last figure plotted is the highest figure number
end
numfigs = numel(figHandles);  
h = waitbar(0, 'Saving figures to PowerPoint file');
saveppt2('ppt',ppt, 'fig', 0, 'textbox', title_text);
for ii = 1:numfigs,
    saveppt2('ppt', ppt, 'fig', figHandles(ii), 'stretch', 'off')
    waitbar(ii/numfigs);
end
saveppt2(pptfilen, 'ppt', ppt, 'close');
close(h)    % close waitbar
end