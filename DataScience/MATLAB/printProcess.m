
%% Display results

reply = questdlg('Save output to PDF file?');
if strcmp(reply,'Yes')
    pdf_file = publish('Run_check_plot.m', 'outputDir', pwd, 'format', 'pdf','showCode', false);
    new_pdf_file = [char(pwd) '\' assessment_ID{1} '.pdf'];
    movefile(pdf_file, new_pdf_file,'f'); % move pdf file to final destination, renaming it in the process
    fprintf('Saved PDF to file %s\n', pwd)
else
    Run_check_plot  % plot results
end
close all
