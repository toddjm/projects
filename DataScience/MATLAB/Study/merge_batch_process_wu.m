%% Initialize Parameters

USERPATH = getenv('USERPROFILE');

activitiesList = ...
{...
'01','56c4fb4cadac1869268b456a','56c4fbfcadac1869268b456c','56c4fca0adac1860268b456d';
'02','56c613feadac181d308b4567','56c6148eadac181a308b456a','56c61ac2adac1868308b4568';
'03','56c634a0adac18df308b456d','56c63594adac18df308b456e','56c6368fadac180c318b4569';
'04','56c64fdaadac18e7318b4567','56c65106adac180a328b4567','56c651cbadac1811328b4568';
'05',[],[],[];
'06','56c73d69adac18623b8b4568','56c73debadac18623b8b4569','56c7835fadac182a3f8b456b';
'07','56c7542aadac18b03c8b4567','56c7572dadac18173d8b4567','56c78300adac182c3f8b456a';
'08',[],[],[];
'09','56c7a0aeadac181a408b4568','56c7a1acadac181f408b4568','56c7a425adac181f408b4569';
'10','56cb6a22adac18d35c8b456c','56cb6a85adac1843608b4568','56cb6b0eadac18d35c8b456d';
'11','56cb7ba7adac1868608b4578','56cb7c1aadac18d9608b4567','56cb7c9dadac18d9608b4569';
'12','56cb994eadac1899618b4568','56cb99ffadac1838618b4569','56cb9a9fadac181b638b4568';
'13',[],'56ccb645adac18636e8b456a','56ccb6ecadac18326e8b4572';
'14','56ccda60adac185a718b4567','56ccdc70adac1861718b4568','56ccdd8aadac1862718b4568';
'15','56cd046eadac183d728b4567','56cd04caadac1844728b456a','56cd0787adac1844728b456c';
'16','56cdecfeadac18267e8b4568','56cdedabadac18fd7d8b456c',[];
'17','56ce0946adac18b47e8b456a','56ce0a2fadac18fb7e8b4567','56ce0acdadac18017f8b4567';
'18','56ce20c2adac186a7f8b4568','56ce2123adac186c7f8b4569','56ce2050adac186c7f8b4568';
'19','56ce4914adac187e018b4569','56ce4802adac18aa018b4569','56ce488fadac18aa018b456a';
'20','56cf4751adac18a60c8b4567','56cf493eadac18a60c8b456a','56cf4847adac18a60c8b4569';
'21','56d08e48adac184a1a8b456c','56d08cdeadac18471a8b4567','56d08fabadac18b71a8b456d';
'22','56d0a3fdadac18181c8b456f','56d0a366adac18181c8b456a','56d0a4eaadac18181c8b4570';
'23','56d0b79fadac18ee1d8b4568','56d0b71cadac18ee1d8b4567','56d0b827adac189b1d8b4569';
'24','56d47cbeadac18573f8b456e','56d47d6cadac18bf3f8b4568','56d47c03adac18573f8b456d';
'25','56d499efadac18c13f8b4573','56d49ab6adac187e3f8b457a','56d49960adac187e3f8b4578';
'26','56d4b61cadac18f3408b456a','56d4b552adac1861418b4569','56d4b417adac18f3408b4567';
'27',[],'56d5d808adac18e04c8b456e','56d5d673adac18e04c8b4568';
'28','56d5f105adac18694d8b456a','56d5f21aadac18694d8b456c','56d5f036adac18694d8b4569';
'29','56d614efadac18f34e8b456a','56d61360adac18f34e8b4568','56d61458adac188d4d8b4571';
'30','56d71b58adac18da568b456a','56d7198badac18c9568b4567','56d71aaeadac18da568b4569';
'31','56d734ceadac18b0588b4567','56d73555adac1881588b456e','56d73607adac1893588b4570';
'32','56d75191adac18d15c8b456b','56d75317adac18f25c8b456a','56d75217adac18d15c8b456c';
'33','56d87404adac1877688b4567','56d872a3adac1847688b4568','56d8735badac1847688b456a';
'34','56d89625adac18ba698b4569','56d892b5adac18be688b456b','56d8959aadac18ba698b4568';
'35','56d8ae34adac18996b8b4569','56d8aec7adac18716a8b456a','56d8adc1adac18996b8b4568';
'36','56d9c92cadac1802758b456c','56d9c8b6adac1802758b456b','56d9c7e2adac18eb748b4569';
'37','56d9e56cadac1802758b4577','56d9e60fadac1884758b456e','56d9e6aeadac1851758b4571';
'38','56d9fa8aadac1851758b4573','56d9fb08adac1851758b4574','56d9fb91adac1851758b4575'...
};

StartTrialNum = 30;
EndTrialNum = 30;% size(activitiesList,1);

%% Process Trial Data
for i=StartTrialNum:EndTrialNum
   
    pathf = strcat(USERPATH,'\Google Drive\Tech_RD\Sensor\Research\Testing\Warmup_Indicator\Trial',num2str(activitiesList{i,1})); % change this to the google drive path on your local machine
    cd(pathf)
    i
    
    %% Import and Wahoo and Lap Data
    Wahoo = getWahoo('Wahoo.csv');
    ind = [ 1; find(diff(Wahoo.interval)); length(Wahoo.time)];   % find points in time when Wahoo laps change
    laps{1} = 'Warmup';     % create labels for each lap
    laps{2} = 'Brief Rest';     % create labels for each lap
    laps{3} = 'Time Trial';     % create labels for each lap
    laps{4} = 'Rest';     % create labels for each lap
    lapTimes = Wahoo.time(ind);               % find times of each lap    
    
    %% Import and Sync Zyphyr Data
    Zephyr = [];
    if exist('Zephyr.csv', 'file') == 2
        Zephyr = getZephyr('Zephyr.csv');
        Zephyr = strSync(Zephyr, Wahoo.StartTime); % synchronize Zephyr and Wahoo
    end
    
    %% Import and Sync Core Temp Data
    CoreTemp = [];
    if exist('CorTemp.cvt', 'file') == 2
        CoreTemp = getCorTemp('CorTemp.cvt');
        CoreTemp = strSync(CoreTemp, Wahoo.StartTime);  % synchronize Core and Wahoo
    end
    
    %% Import and Sync Calf Data
    sweep_Calf_Left = [];
    process_Calf_Left = [];
    if ~isempty(activitiesList{i,2})       
        activity = getActivity(activitiesList{i,2});
        sweep_Calf_Left = getSweep(activity);
        sweep_Calf_Left = strSync(sweep_Calf_Left, Wahoo.StartTime);    % synchronize Calf and Wahoo
        process_Calf_Left = sweep2process(sweep_Calf_Left);
        
        % Find Baselines
        WU_BASELINE_RANGE = findRange(sweep_Calf_Left.time,Wahoo.time(lapTimes(1))+30, Wahoo.time(lapTimes(2)));   % warmup baseline range (seconds)
        TT_BASELINE_RANGE = findRange(sweep_Calf_Left.time,Wahoo.time(lapTimes(3)),Wahoo.time(lapTimes(4)));   % time trial baseline range (seconds)
        RR_BASELINE_RANGE = findRange(sweep_Calf_Left.time,Wahoo.time(lapTimes(4)+30),Wahoo.time(end)-30);   % rest/recovery baseline range (seconds)
        process_Calf_Left.wu_baseline = baselineStats(sweep_Calf_Left.SmO2, WU_BASELINE_RANGE); process_Calf_Left.wu_baseline;
        process_Calf_Left.tt_baseline = baselineStats(sweep_Calf_Left.SmO2, TT_BASELINE_RANGE);
        process_Calf_Left.rr_baseline = baselineStats(sweep_Calf_Left.SmO2, RR_BASELINE_RANGE);        

    end

    %% Import and Sync Calf Data    
    sweep_Quad_Left = [];
    process_Quad_Left = [];
    if ~isempty(activitiesList{i,3})           
        activity = getActivity(activitiesList{i,3});
        sweep_Quad_Left = getSweep(activity);
        sweep_Quad_Left = strSync(sweep_Quad_Left, Wahoo.StartTime);    % synchronize Quad and Wahoo
        process_Quad_Left = sweep2process(sweep_Quad_Left);
        
        % Find Baselines
        WU_BASELINE_RANGE = findRange(sweep_Quad_Left.time,Wahoo.time(lapTimes(1))+30, Wahoo.time(lapTimes(2)));   % warmup baseline range (seconds)
        TT_BASELINE_RANGE = findRange(sweep_Quad_Left.time,Wahoo.time(lapTimes(3)),Wahoo.time(lapTimes(4)));   % time trial baseline range (seconds)
        RR_BASELINE_RANGE = findRange(sweep_Quad_Left.time,Wahoo.time(lapTimes(4)+30),Wahoo.time(end)-30);   % rest/recovery baseline range (seconds)
        process_Quad_Left.wu_baseline = baselineStats(sweep_Quad_Left.SmO2, WU_BASELINE_RANGE); process_Quad_Left.wu_baseline;
        process_Quad_Left.tt_baseline = baselineStats(sweep_Quad_Left.SmO2, TT_BASELINE_RANGE);
        process_Quad_Left.rr_baseline = baselineStats(sweep_Quad_Left.SmO2, RR_BASELINE_RANGE);  
    end
    
    %% Import and Sync Wrist Data    
    sweep_Wrist_Right = [];
    process_Wrist_Right = [];
    if ~isempty(activitiesList{i,4})           
        activity = getActivity(activitiesList{i,4});
        sweep_Wrist_Right = getSweep(activity);
        sweep_Wrist_Right = strSync(sweep_Wrist_Right, Wahoo.StartTime);    % synchronize Wrist and Wahoo
        process_Wrist_Right = sweep2process(sweep_Wrist_Right); 
        
        % Find Baselines
        WU_BASELINE_RANGE = findRange(sweep_Wrist_Right.time,Wahoo.time(lapTimes(1))+30, Wahoo.time(lapTimes(2)));   % warmup baseline range (seconds)
        TT_BASELINE_RANGE = findRange(sweep_Wrist_Right.time,Wahoo.time(lapTimes(3)),Wahoo.time(lapTimes(4)));   % time trial baseline range (seconds)
        RR_BASELINE_RANGE = findRange(sweep_Wrist_Right.time,Wahoo.time(lapTimes(4)+30),Wahoo.time(end)-30);   % rest/recovery baseline range (seconds)
        process_Wrist_Right.wu_baseline = baselineStats(sweep_Wrist_Right.SmO2, WU_BASELINE_RANGE);
        process_Wrist_Right.tt_baseline = baselineStats(sweep_Wrist_Right.SmO2, TT_BASELINE_RANGE);
        process_Wrist_Right.rr_baseline = baselineStats(sweep_Wrist_Right.SmO2, RR_BASELINE_RANGE);         
    end
    
    
    filename = ['Trial' num2str(activitiesList{i,1}) '.mat'];
    save(filename, 'sweep_Calf_Left', 'process_Calf_Left', 'sweep_Quad_Left', 'process_Quad_Left','sweep_Wrist_Right', 'process_Wrist_Right', 'Wahoo', 'Zephyr', 'CoreTemp', 'lapTimes');
    
    %% Plot Wahoo
    timefig = figure; grid on;grid minor; hold on
    plot(Wahoo.time, [Wahoo.hr_heartrate Wahoo.pwr_instpwr])
    title('HR and Power over Time ')
    xlabel('time (s)')
    ylabel('Hear rate (bpm)')
    showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
    legend('HR', 'Power', 'Location', 'Best')
    set(timefig, 'Position', [0 0 1920 1080]);
	saveas(timefig,strrep(filename,'.mat','_Wahoo.png'));
        
    %% Plot SmO2
    timefig = figure; grid on;grid minor; hold on
    if ~isempty(process_Calf_Left)     
        % plot Calf_Left
        indx_common = find(sweep_Calf_Left.time>lapTimes(1)&sweep_Calf_Left.time<lapTimes(end));
        plot(sweep_Calf_Left.time(indx_common), [process_Calf_Left.SmO2(indx_common)], 'r') 
    end

    if ~isempty(process_Calf_Left) 
        % plot Quad_Left
        indx_common = find(sweep_Quad_Left.time>lapTimes(1)&sweep_Quad_Left.time<lapTimes(end));
        plot(sweep_Quad_Left.time(indx_common), [process_Quad_Left.SmO2(indx_common)], 'b')
    end
    
    title('SmO2 for Calf, Quad ')
    xlabel('time (s)')
    ylabel('SmO2 (%)')
    showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
    set(timefig, 'Position', [0 0 1920 1080]);
    saveas(timefig,strrep(filename,'.mat','_SmO2.png'));


    %% Plot tHb
    timefig = figure; grid on;grid minor; hold on
    if ~isempty(process_Calf_Left)     
        % plot Calf_Left
        indx_common = find(sweep_Calf_Left.time>lapTimes(1)&sweep_Calf_Left.time<lapTimes(end));
        plot(sweep_Calf_Left.time(indx_common), [process_Calf_Left.tHb(indx_common)], 'r') 
    end
    
    if ~isempty(process_Calf_Left) 
        % plot Quad_Left
        indx_common = find(sweep_Quad_Left.time>lapTimes(1)&sweep_Quad_Left.time<lapTimes(end));
        plot(sweep_Quad_Left.time(indx_common), [process_Quad_Left.tHb(indx_common)], 'b')
    end

    title('tHB for Calf, Quad')
    xlabel('time (s)')
    ylabel('tHB (g/dL)')
    showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
    set(timefig, 'Position', [0 0 1920 1080]);
    saveas(timefig,strrep(filename,'.mat','_tHb.png'));
    
    %% Plot Core Temp
    if ~isempty(CoreTemp)
        timefig = figure; grid on; grid minor;hold on;
        indx_common = find(CoreTemp.time>lapTimes(1)&CoreTemp.time<lapTimes(end));
        plot(CoreTemp.time(indx_common), [CoreTemp.temperature(indx_common)])
        title('Core Body Temperature')
        xlabel('time (s)')
        ylabel('Degrees (F)')
        showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
        set(timefig, 'Position', [0 0 1920 1080]);
        saveas(timefig,strrep(filename,'.mat','_CoreTemp.png'));
    end
    %close all
end

