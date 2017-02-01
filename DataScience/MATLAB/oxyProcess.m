%% Gen 2 Oxy File

calibration_period = cell2mat(assessment.protocol.calibration_period{1,1});
for i=1:numel(assessment.protocol.stages)
    stages(i,:) = cell2mat(assessment.protocol.stages{1,i});
end
anticipated_stage = assessment.protocol.anticipated_stage;
anticipated_stage_range = assessment.protocol.anticipated_stage_range;

Height = 170;
Weight = 70;
Gender = 'male';

 
if str2double(sweep.FW_version(1))>=2
    FID = fopen(oxyfile,'w');
    %% Header Block
    % header: {
    % Device_id: "0C:EF:AF:80:00:2C",
    % FW_version: "2.0.87",
    % Schema_version: "1.0.0",
    % sport: "bike",
    % sample_rate: "1Hz"
    % },
    fprintf(FID,sprintf('{\n\t"result": {\n\t\t"header": {\n\t\t"Device_id": "%s",\n',sweep.device_id));
    fprintf(FID,sprintf('\t\t"FW_version": "%s", \n\t\t"Schema_version": "1.0.0",\n\t\t"sport": "%s",\n',sweep.FW_version,sweep.sport));
    fprintf(FID,sprintf('\t\t"sample_rate": "1Hz"\n\t\t},\n'));

    %% Write Profile Block
    fprintf(FID,'\t"profile": {\n');
    fprintf(FID,sprintf('\t\t"height": %d, \n\t\t"weight": %d, \n\t\t"gender": "%s"\n\t\t},\n', Height, Weight, Gender));

    %% Protocol Block
    fprintf(FID,'\t"protocol": {\n\t\t');
    fprintf(FID,'"calibration_period": [\n\t\t');
    fprintf(FID,'[%d,%.4f],',calibration_period);
    fseek(FID,-1,'cof');fprintf(FID,'],\n\t\t');
    fprintf(FID,'"stages": [');
    fprintf(FID,'[%d,%.4f],',stages');
    fseek(FID,-1,'cof');fprintf(FID,'],\n\t\t"anticipated_stage": %d,\n\t\t"anticipated_stage_range": %d\n\t},\n',anticipated_stage,anticipated_stage_range);

    % Interpolate missing/noisy HR/PP data
    hr_ts = timeseries(sweep.HR, sweep.time);
    bad_data = find(hr_ts.Data<10);
    hr_ts = delsample(hr_ts,'Index', bad_data);
    hr_ts = resample(hr_ts, sweep.time);

    
    PP_ts = timeseries(sweep.PacePower, sweep.time);
    bad_data = find(PP_ts.Data<10);
    PP_ts = delsample(PP_ts,'Index', bad_data);
    PP_ts = resample(PP_ts, sweep.time);



    Pace_on_Dev = [0;sweep.Pace_on_dev(1:sweep.imu_samp_rate/sweep.samp_rate:end)];
    
    if length(Pace_on_Dev)>length(process.cHb15)
        Pace_on_Dev = Pace_on_Dev(1:length(process.cHb15));
    elseif length(Pace_on_Dev)<length(process.cHb15)
        Pace_on_Dev = padarray(Pace_on_Dev,length(process.cHb15));
    end
    
    
    % Content Block
    fprintf(FID,'\t\t"content": [ \n');
    l2w = sprintf('\t\t[%f,%f,%f,%f,%f,%f,%f,%f,%f,%f],\n', ...
    [process.cHb15(:,2) process.cHb15(:,1) process.cHb27(:,2) process.cHb27(:,1) hr_ts.Data PP_ts.Data sweep.time*1000 sweep.SmO2 sweep.Alert(:,1) Pace_on_Dev]');
    fprintf(FID,strrep(l2w,'NaN','null'));
    
    % Meta Block
    fseek(FID,-2,'cof'); 
    fprintf(FID,'\n\t\t]\n\t},\n\t"meta": {},\n\t"error": {}\n\t}\n');
    fclose(FID);
else
    FID = fopen(oxyfile,'w');

    %% Header Block
    % header: {
    % Device_id: "0C:EF:AF:80:00:2C",
    % FW_version: "21",
    % Schema_version: "1.0.0",
    % sport: "bike",
    % sample_rate: "1Hz"
    % },
    fprintf(FID,sprintf('{\n\t"result": {\n\t\t"header": {\n\t\t"Device_id": "%s",\n',sweep.device_id));
    fprintf(FID,sprintf('\t\t"FW_version": "21",\n\t\t"Schema_version": "1.0.0",\n\t\t"sport": "%s",\n',sweep.sport));
    fprintf(FID,sprintf('\t\t"sample_rate": "2Hz"\n\t\t},\n'));

    %% Write Profile Block
    fprintf(FID,'\t"profile": {\n');
    fprintf(FID,sprintf('\t\t"height": %d, \n\t\t"weight": %d, \n\t\t"gender": "%s"\n\t\t},\n', Height, Weight, Gender));

    %% Protocol Block
    fprintf(FID,'\t"protocol": {\n\t\t');
    fprintf(FID,'"calibration_period": [\n\t\t');
    fprintf(FID,'[%d,%.4f],', calibration_period);
    fseek(FID,-1,'cof');fprintf(FID,'],\n\t\t');
    fprintf(FID,'"stages": [');
    fprintf(FID,'[%d,%.4f],',stages');
    fseek(FID,-1,'cof');fprintf(FID,'],\n\t\t"anticipated_stage": %d,\n\t\t"anticipated_stage_range": %d\n\t},\n',anticipated_stage,anticipated_stage_range);

    % Interpolate missing/noisy HR/PP data
    hr_ts = timeseries(sweep.HR, sweep.time);
    bad_data = find(hr_ts.Data<10);
    hr_ts = delsample(hr_ts,'Index', bad_data);
    hr_ts = resample(hr_ts, sweep.time);

    PP_ts = timeseries(sweep.PacePower, sweep.time);
    bad_data = find(PP_ts.Data<10);
    PP_ts = delsample(PP_ts,'Index', bad_data);
    PP_ts = resample(PP_ts, sweep.time);


    % Content Block
    if ~isfield(sweep,'SmO2')
        fprintf(FID,'\t\t"content": [ \n');
        l2w = sprintf('\t\t[%f,%f,%f,%f,%f,%f,%f,%f],\n', ...
        [process.cHb15(:,2) process.cHb15(:,1) process.cHb27(:,2) process.cHb27(:,1) hr_ts.Data PP_ts.Data sweep.time*1000 rawSmO2*100]');
        fprintf(FID,strrep(l2w,'NaN','null'));
    else
        fprintf(FID,'\t\t"content": [ \n');
        l2w = sprintf('\t\t[%f,%f,%f,%f,%f,%f,%f,%f],\n', ...
        [process.cHb15(:,2) process.cHb15(:,1) process.cHb27(:,2) process.cHb27(:,1) hr_ts.Data PP_ts.Data sweep.time*1000 sweep.SmO2]');
        fprintf(FID,strrep(l2w,'NaN','null'));
    end




    fseek(FID,-2,'cof'); 
    fprintf(FID,'\n\t\t]\n\t},\n\t"meta": {},\n\t"error": {}\n\t}\n');
    fclose(FID);
end
