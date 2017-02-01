%% Initialize Parameters

USERPATH = getenv('USERPROFILE');

%% Build List of Activites by Trial Number and Location on the body 

% Trial Number
activitiesList{1} = {...
'39';...
'40';...
'41';...
'42';...
'43';...
'44';...
'45';...
'46';...
'47';...
'48';...
'49';...
'50';...
'51';...
};

% Left Calf
activitiesList{2} = {...
'56f1bb3a0f9d88f1248b456a';
'56f2cf510f9d88572c8b456c';
'56f4248a0f9d881d378b456d';
'56f437670f9d88c6378b456d';
'56f465800f9d8875398b4568';
'56f598d30f9d887f498b4569';
[];
'56f95d240f9d88b0698b456e';
[];%'56f977380f9d88d8698b456f';
'56f9948f0f9d88856e8b4569';
'56f9ac130f9d88426f8b456a';
'56faae2d0f9d88e6758b456e';
'56fad81a0f9d88fa798b4567';
'56fbfc520f9d8832058b4569';
};

% Left Quad
activitiesList{3} = {...
'56f1bbe60f9d88f1248b456b';
'56f2cfce0f9d88d32c8b4569';
'56f423150f9d881d378b4569';
'56f438d50f9d88c9378b456d';
'56f4673d0f9d8875398b456b';
'56f597db0f9d88d4468b456e';
'56f5aecf0f9d8816498b4573';
'56f95cb20f9d88b0698b456c';
'56f971620f9d88d9698b4570';
'56f996140f9d88856e8b456b';
'56f9aaf40f9d88426f8b4569';
'56faad150f9d88e6758b456b';
'56fad6c20f9d88f8798b4567';
'56fbfaff0f9d88fa048b4567';
};

% Right Forearm
activitiesList{4} = {...
'56f1bc840f9d88f1248b456c';
'56f2d0740f9d88d32c8b456a';
'56f4250d0f9d881d378b456e';
'56f4395d0f9d880e388b4568';
'56f468240f9d8875398b456e';
'56f59a9c0f9d887f498b456c';
'56f5b0130f9d88d4468b457b';
'56f95ec20f9d88d9698b456b';
'56f977cd0f9d88d9698b4572';
'56f995790f9d88856e8b456a';
'56f9ad5f0f9d88416f8b456a';
'56faaede0f9d8888768b456e';
'56fad9a20f9d88037a8b456a';
'56fbfce60f9d8850058b4567';
};

% Right Calf
activitiesList{5} = {...
'56f1ba270f9d88f1248b4569';
'56f2ce820f9d88d32c8b4567';
'56f423df0f9d885b378b4567';
'56f438340f9d88c6378b456e';
'56f466a10f9d8876398b4569';
'56f599c10f9d8816498b456e';
'56f5ad4e0f9d88d4468b4576';
'56f95e170f9d88b0698b456f';
'56f974070f9d88d8698b456d';
'56f993c00f9d88856e8b4568';
'56f9acbc0f9d881b6f8b456c';
'56faad9c0f9d8888768b456b';
'56fad7880f9d88ff798b4567';
'56fbfbac0f9d88fa048b4568';
};

StartTrialNum = 14;
EndTrialNum = size(activitiesList{1,1},1);

for i=StartTrialNum:EndTrialNum
   
    pathf = strcat(USERPATH,'\Google Drive\Tech_RD\Sensor\Research\Testing\Warmup_Indicator\Trial',activitiesList{1,1}{i,1} ); % change this to the google drive path on your local machine
    cd(pathf)
    i
    
    %% Import Wahoo Data and Laps
    Wahoo = getWahoo('Wahoo.csv');
    ind = [ 1; find(diff(Wahoo.interval)); length(Wahoo.time)];   % find points in time when Wahoo laps change
    laps{1} = 'Time Trial';     % create labels for each lap    
    laps{2} = 'Rest';     % create labels for each lap
    laps{3} = 'End';     % create labels for each lap
    lapTimes = Wahoo.time(ind);               % find times of each lap    
    
    %% Import and Sync Zephyr datat
    Zephyr = [];
    if exist('Zephyr.csv', 'file') == 2
        Zephyr = getZephyr('Zephyr.csv');
        Zephyr = strSync(Zephyr, Wahoo.StartTime); % synchronize Zephyr and Wahoo
    end
    
    %% Sync Left Calf Sweep, Process, and Baseline           
    sweep_Calf_Left = []
    process_Calf_Left = [];
    if ~isempty(activitiesList{1,2}{i,1})       
        activity = getActivity(activitiesList{1,2}{i,1})
        sweep_Calf_Left = getSweep(activity);
        sweep_Calf_Left = strSync(sweep_Calf_Left, Wahoo.StartTime);    % synchronize Calf and Wahoo
        process_Calf_Left = sweep2process(sweep_Calf_Left);
        
        % Find Baselines
        TT_BASELINE_RANGE = findRange(sweep_Calf_Left.time,Wahoo.time(lapTimes(1)),Wahoo.time(lapTimes(1)));   % time trial baseline range (seconds)
        RR_BASELINE_RANGE = findRange(sweep_Calf_Left.time,Wahoo.time(lapTimes(2)+30),Wahoo.time(end)-30);   % rest/recovery baseline range (seconds)
        process_Calf_Left.tt_baseline = baselineStats(process_Calf_Left.SmO2, TT_BASELINE_RANGE);
        process_Calf_Left.rr_baseline = baselineStats(process_Calf_Left.SmO2, RR_BASELINE_RANGE);        

    end
    
    %% Sync Left Quad Sweep, Process, and Baseline    
    sweep_Quad_Left = []
    process_Quad_Left = [];
    if ~isempty(activitiesList{1,3}{i,1})           
        activity = getActivity(activitiesList{1,3}{i,1})
        sweep_Quad_Left = getSweep(activity);
        sweep_Quad_Left = strSync(sweep_Quad_Left, Wahoo.StartTime);    % synchronize Quad and Wahoo
        process_Quad_Left = sweep2process(sweep_Quad_Left);
        
        % Find Baselines
        TT_BASELINE_RANGE = findRange(sweep_Quad_Left.time,Wahoo.time(lapTimes(1)),Wahoo.time(lapTimes(2)));   % time trial baseline range (seconds)
        RR_BASELINE_RANGE = findRange(sweep_Quad_Left.time,Wahoo.time(lapTimes(2)+30),Wahoo.time(end)-30);   % rest/recovery baseline range (seconds)
        process_Quad_Left.tt_baseline = baselineStats(process_Quad_Left.SmO2, TT_BASELINE_RANGE);
        process_Quad_Left.rr_baseline = baselineStats(process_Quad_Left.SmO2, RR_BASELINE_RANGE);  
    end
    
    %% Sync Right Forearm Sweep, Process, and Baseline
    sweep_Forearm_Right = []
    process_Forearm_Right = [];
    if ~isempty(activitiesList{1,4}{i,1})           
        activity = getActivity(activitiesList{1,4}{i,1})
        sweep_Forearm_Right = getSweep(activity);
        sweep_Forearm_Right = strSync(sweep_Forearm_Right, Wahoo.StartTime);    % synchronize Wrist and Wahoo
        process_Forearm_Right = sweep2process(sweep_Forearm_Right); 
        
        % Find Baselines
        TT_BASELINE_RANGE = findRange(sweep_Forearm_Right.time,Wahoo.time(lapTimes(1)),Wahoo.time(lapTimes(2)));   % time trial baseline range (seconds)
        RR_BASELINE_RANGE = findRange(sweep_Forearm_Right.time,Wahoo.time(lapTimes(2)+30),Wahoo.time(end)-30);   % rest/recovery baseline range (seconds)
        process_Forearm_Right.tt_baseline = baselineStats(process_Forearm_Right.SmO2, TT_BASELINE_RANGE);
        process_Forearm_Right.rr_baseline = baselineStats(process_Forearm_Right.SmO2, RR_BASELINE_RANGE);         
    end
    
    %% Sync Right Calf Seep, Process, and Baseline
    sweep_Calf_Right = []
    process_Calf_Right = [];
    if ~isempty(activitiesList{1,5}{i,1})       
        activity = getActivity(activitiesList{1,5}{i,1})
        sweep_Calf_Right = getSweep(activity);
        sweep_Calf_Right = strSync(sweep_Calf_Right, Wahoo.StartTime);    % synchronize Calf and Wahoo
        process_Calf_Right = sweep2process(sweep_Calf_Right);
        
        % Find Baselines
        TT_BASELINE_RANGE = findRange(sweep_Calf_Right.time,Wahoo.time(lapTimes(1)),Wahoo.time(lapTimes(2)));   % time trial baseline range (seconds)
        RR_BASELINE_RANGE = findRange(sweep_Calf_Right.time,Wahoo.time(lapTimes(2)+30),Wahoo.time(end)-30);   % rest/recovery baseline range (seconds)
        process_Calf_Right.tt_baseline = baselineStats(process_Calf_Right.SmO2, TT_BASELINE_RANGE);
        process_Calf_Right.rr_baseline = baselineStats(process_Calf_Right.SmO2, RR_BASELINE_RANGE);        

    end
    
    %% Save Data
    filename = ['Trial' activitiesList{1,1}{i,1} '.mat'];
    save(filename,  'sweep_Calf_Left', 'process_Calf_Left',...
                    'sweep_Quad_Left', 'process_Quad_Left',...
                    'sweep_Forearm_Right', 'process_Forearm_Right',...
                    'sweep_Calf_Right', 'process_Calf_Right',...
                    'Wahoo', 'Zephyr', 'lapTimes', 'laps');
                
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

    % plot Calf_Left
    if ~isempty(process_Calf_Left)
        indx_common = find(sweep_Calf_Left.time>lapTimes(1)&sweep_Calf_Left.time<lapTimes(end));
        plot(sweep_Calf_Left.time(indx_common), [process_Calf_Left.SmO2(indx_common)], 'r')
    end

    % plot Quad_Left
    if ~isempty(sweep_Quad_Left)
        indx_common = find(sweep_Quad_Left.time>lapTimes(1)&sweep_Quad_Left.time<lapTimes(end));
        plot(sweep_Quad_Left.time(indx_common), [process_Quad_Left.SmO2(indx_common)], 'b')
    end

    % plot Calf_Right
    if ~isempty(sweep_Calf_Right)
        indx_common = find(sweep_Calf_Right.time>lapTimes(1)&sweep_Calf_Right.time<lapTimes(end));
        plot(sweep_Calf_Right.time(indx_common), [process_Calf_Right.SmO2(indx_common)], 'g')
    end

    title('SmO2 for Calfs and Quad')
    xlabel('time (s)')
    ylabel('SmO2 (%)')
    showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
    set(timefig, 'Position', [0 0 1920 1080]);
    saveas(timefig,strrep(filename,'.mat','_SmO2.png'));

    %% Plot tHb
    timefig = figure; grid on;grid minor; hold on

    % plot Calf_Left
    if ~isempty(sweep_Calf_Left)
        indx_common = find(sweep_Calf_Left.time>lapTimes(1)&sweep_Calf_Left.time<lapTimes(end));
        plot(sweep_Calf_Left.time(indx_common), [process_Calf_Left.tHb(indx_common)], 'r') 
    end

    % plot Quad_Left
    if ~isempty(sweep_Quad_Left)
        indx_common = find(sweep_Quad_Left.time>lapTimes(1)&sweep_Quad_Left.time<lapTimes(end));
        plot(sweep_Quad_Left.time(indx_common), [process_Quad_Left.tHb(indx_common)], 'b')
    end

    % plot Calf_Right
    if ~isempty(sweep_Calf_Right)
        indx_common = find(sweep_Calf_Right.time>lapTimes(1)&sweep_Calf_Right.time<lapTimes(end));
        plot(sweep_Calf_Right.time(indx_common), [process_Calf_Right.tHb(indx_common)], 'g') 
    end

    title('tHB for Calfs and Quad')
    xlabel('time (s)')
    ylabel('tHB (g/dL)')
    showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
    set(timefig, 'Position', [0 0 1920 1080]);
    saveas(timefig,strrep(filename,'.mat','_tHb.png'));
    
    timefig = figure; grid on;grid minor; hold on
    plot(sweep_Calf_Right.imu_time,sqrt((sweep_Calf_Right.Gyro_y.*sweep_Calf_Right.Gyro_y)+(sweep_Calf_Right.Gyro_x.*sweep_Calf_Right.Gyro_x)))
    hold on
    plot(Wahoo.time,Wahoo.pwr_instpwr,'r')
    title('Offset')
    xlabel('time (s)')
    ylabel('Power and Gyro (F)')
    showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
    set(timefig, 'Position', [0 0 1920 1080]);
    axis([lapTimes(2)-30,lapTimes(2)+5,0,500])
    saveas(timefig,strrep(filename,'.mat','_Offset.png'));
        
    close all;
end

