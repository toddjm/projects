% Script used to list devices and their status
%
% P. Silveira, Feb. 2015. Modified Apr. 2015

%% Initializatons

clear

% List of statuses
status = [ '1' '2' '3' '4' '5' '6'];   % defective devices
dateBegin = '20150202'; % start date to include in query
dateEnd = '20150409';   % end date to include in query

[filen, pathn] = uiputfile('*.csv', 'Select output file');
outf = fopen([pathn filen],'a');
fprintf(outf,'Device,Status\n');

%% Get data

for ii = 1:numel(status)
    kk = 0; % defective device counter
    device_chks_cell = '';
    disp(['Retrieving devices with status ' status(ii)])
    devlist_chks = getDevice('', 'status', status(ii), 'dateBegin', dateBegin, 'dateEnd', dateEnd);
    fprintf('%d total checkouts found, ', numel(devlist_chks));
    for jj = 1:numel(devlist_chks); device_chks_cell{jj} = devlist_chks{jj}.device_id; end  % convert device ids to cell array
    unique_device = unique(device_chks_cell);  % make sure all devices are unique. Remove duplicate device ids.
    fprintf('of which %d are from unique devices.\n', numel(unique_device));
    for jj = 1:numel(unique_device)
        device = getDevice(unique_device{jj});
        if device.checkouts{1}.status == str2num(status(ii))
            kk = kk + 1;
            selected_device{kk} = device;
        else    % skip devices that no longer present this status
            continue
        end
    end
    defec_num(ii) = kk; % keep a tally
    fprintf('Of which %d still present the same status.\n', defec_num(ii));
    for jj = 1:defec_num(ii),
        dev_id = selected_device{jj}.device_id;
        fprintf(outf, [dev_id ',' status(ii) '\n']);
    end
end

fprintf(outf, '\nDate: %s\n', date)
for ii = 1:numel(status)
    fprintf(outf, ['Type ' status(ii) ' failures ,' num2str(defec_num(ii)) ]);
end
fprintf(outf, ['\nTotal failures ,' num2str(sum(defec_num(:))) ]);


%% Finalize

fclose(outf);
disp('Done!')


    