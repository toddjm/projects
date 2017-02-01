%% Run LT Script

% change directory to the most recent master
cd(strrep(userpath,'MATLAB;','GitHub\BSXprotocol\'));

% Ask to force or not 
config_flag = input('Enter 1 to force the protocol, otherwise press enter: ');  
if isempty(config_flag)
    config_flag = 0;
end

% Run script commant
if config_flag == 1
    [exitCode,Message] = system(sprintf('python deployLTmodel.py %s ModelParamsR.mat %s force-everything-plots.config',oxyfile,finalfile));
else
    [exitCode,Message] = system(sprintf('python deployLTmodel.py %s ModelParamsR.mat %s plots.config',oxyfile,finalfile));
end

% Display for error
if exitCode,
    fprintf('deployLTmodel encountered a problem see %s for details\n',finalfile);
end

% change directory back to deploy
cd(strrep(userpath,';',''));
