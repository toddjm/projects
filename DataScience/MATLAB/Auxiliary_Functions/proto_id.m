function [ device ] = proto_id( device_id )
% function [ device ] = proto_id( device_id )
% Function used to identify prototypes from serial numbers
%
% Inputs
% device_id - string with device id. Usually taken from sweep.device_id
%
% Outputs
% device - structure with device id info. Fields:
%    geometry - spacing from PD to each LED channel (mm)
%    wavel - cell array with strings determining the wavelength label of each LED channel.
%    centWavel - numeric array with centroid wavelength of each LED channel (nm)
%
% BSX Athletics Proprietary



board_id = device_id(7:8);
switch(board_id)
    case '11'
        device.id = 'Nellie Muscle';
        device.geometry = [4.7 4.7 4.7 13.2 13.2 13.2 13.2 13.2 6.9 6.9 6.9 22.2 22.2 22.2 22.2 22.2];     % LED/PD distance (mm)
        device.wavel = {'470' '505' '630' '665' '810' '850' '950' '1020' '470' '505' '630' '665' '810' '850' '950' '1020'};     % nominal wavelengths
        device.centWavel = [470 505 630 663 803 851 940 1010 470 505 630 663 803 851 940 1010];     % centroid wavelengths
    case '12'
        device.id = 'Nellie Wrist';
        device.geometry = [3.8 3.8 3.8 9.4 9.4 9.4 9.4 9.4 6 6 6 17.1 17.1 17.1 17.1 17.1];     % LED/PD distance (mm)
        device.wavel = {'470' '505' '630' '665' '810' '850' '950' '1020' '470' '505' '630' '665' '810' '850' '950' '1020'};     % nominal wavelengths
        device.centWavel = [470 505 630 663 803 851 940 1010 470 505 630 663 803 851 940 1010];     % centroid wavelengths
    case '21'
        device.id = 'Calypso Muscle';
        device.geometry = [8 8 8 8 8 13.5 13.5 13.5 13.5 13.5 22.2 22.2 22.2 22.2 22.2];     % LED/PD distance (mm)
        device.wavel = {'665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020'};     % nominal wavelengths
        device.centWavel = [663 803 851 974 1010 663 803 851 974 1010 663 803 851 974 1010];     % centroid wavelengths
    case '22'
        device.id = 'Calypso Wrist';
        device.geometry = [7.3 7.3 7.3 7.3 7.3 12.5 12.5 12.5 12.5 12.5 17.7 17.7 17.7 17.7 17.7];     % LED/PD distance (mm)
        device.wavel = {'665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020' '665' '810' '850' '970' '1020'};     % nominal wavelengths
        device.centWavel = [663 803 851 974 1010 663 803 851 974 1010 663 803 851 974 1010];     % centroid wavelengths
    otherwise
        error(['Unidentified board type = ' board_id])
end

% Calypso variations
if sweep.device_id(7) == '2'
    var_id = sweep.device_id(9:10);
    switch(var_id)
        case '01' % nominal. No change
        case '02' % variation 1
            device.wavel([4,9,14]) = {'950'};
            device.centWavel([4,9,14]) = 940;
        case '03' % variation 2
            device.wavel([5,10,15]) = {'1050'};
            device.centWavel([5,10,15]) = 1045;
        case '04'  % variation 3
            device.wavel([4,9,14]) = {'950'};
            device.centWavel([4,9,14]) = 940;
            device.wavel([5,10,15]) = {'1050'};
            device.centWavel([5,10,15]) = 1045;
        case '05'   % variation 4
            %        nom_wavel = input('Calypso variation 4: Enter additional nominal wavelength: ', 's');
            %        cent_wavel = input('Enter centroid wavelength: ');
            device.wavel([4,9,14]) = {'960'};
            device.centWavel([4,9,14]) = 952;
            device.wavel([5,10,15]) = {'1050'}; %nom_wavel;
            device.centWavel([5,10,15]) = 1045; %cent_wavel;
        otherwise
            error(['Unidentified Calypso variation = ' var_id])
    end
end


end

