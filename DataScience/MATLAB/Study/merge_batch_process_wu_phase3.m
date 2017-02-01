%% Initialize Parameters

USERPATH = getenv('USERPROFILE');

%% Build List of Activites by Trial Number and Location on the body 

% Trial Number
activitiesList{1} = {...
'52';
'53';
'54';
'55';
'56';
'57';
'58';
'59';
'60';
'61';
'62';
'63';
'64';
'65';
};

% Left Calf
activitiesList{2} = {...
'56fbfc520f9d8832058b4569';
'56fc11570f9d88e0058b4567';
'56fc29d50f9d8894068b4569';
'56fc591f0f9d884a0a8b4569';
'56fd512a0f9d8847118b4568';
'56fd67040f9d88e5118b456a';
'56fd7e4e0f9d88dd128b4567';
'56fda5330f9d8889138b456b';
'56fea2fe0f9d889d1a8b456d';
'56feb81a0f9d882d1b8b456b';
'56fecd760f9d88521d8b4568';
'570413b50f9d88cc6e8b4568';
'570425510f9d8853708b4568';
'57043b030f9d889e718b456a';
};

% Left Quad
activitiesList{3} = {...
'56fbfaff0f9d88fa048b4567';
'56fc0f290f9d88af058b4567';
'56fc270e0f9d8870068b4567';
'56fc57850f9d884a0a8b4568';
'56fd4fe30f9d8846118b4568';
'56fd65180f9d8814128b4567';
'56fd7dac0f9d88e1128b4568';
'56fda3df0f9d88d9138b4567';
'56fea0a20f9d88c11a8b4567';
'56feb6150f9d882d1b8b456a';
'56fecc250f9d88cc1d8b4567';
'570414d60f9d88de6e8b456c';
'570423ea0f9d88f66f8b4567';
'570439f20f9d881a718b4569';
};

% Right Forearm
activitiesList{4} = {...
'56fbfce60f9d8850058b4567';
'56fc11d40f9d88e0058b4568';
'56fc2aa10f9d8870068b456a';
'56fc5a4a0f9d884a0a8b456b';
'56fd51eb0f9d8847118b4569';
'56fd68030f9d88e5118b456b';
'56fd7f7f0f9d88af128b456a';
'56fda6d90f9d8889138b456d';
'56fea49c0f9d88e91a8b4568';
'56feb8ad0f9d88551b8b456e';
'56fece200f9d88cc1d8b456a';
'570412db0f9d88e06e8b4568';
'570425ed0f9d8862708b4569';
'57043b950f9d889e718b456b';
};

% Right Calf
activitiesList{5} = {...
'56fbfbac0f9d88fa048b4568';
'56fc0fc40f9d88c6058b4568';
'56fc29030f9d8894068b4568';
'56fc58570f9d88490a8b4567';
'56fd50600f9d8844118b4567';
'56fd66450f9d8814128b4569';
'56fd7ed30f9d88dd128b4568';
'56fda4880f9d8863138b4569';
'56fea3dd0f9d88c11a8b4569';
'56feb77e0f9d88fb1a8b456b';
'56feccc80f9d88cc1d8b4568';
'5704143b0f9d88cc6e8b4569';
'570424c70f9d8831708b4568';
'57043a6b0f9d889d718b4568';
};

StartTrialNum = 12;
EndTrialNum = size(activitiesList{1,1},1);

for i=StartTrialNum:EndTrialNum   
    pathf = strcat(USERPATH,'\Google Drive\Tech_RD\Sensor\Research\Testing\Warmup_Indicator\Trial',activitiesList{1,1}{i,1} ); % change this to the google drive path on your local machine
    cd(pathf)
    i
    
    %% Import Wahoo Data and Laps
    Wahoo = getWahoo('Wahoo.csv');
    ind = [ 1; find(diff(Wahoo.interval)); length(Wahoo.time)];   % find points in time when Wahoo laps change
    laps{1} = 'Warmup';     % create labels for each lap    
    laps{2} = 'LT Sample';     % create labels for each lap
    laps{3} = 'Time Trail';     % create labels for each lap
    laps{4} = 'Rest';     % create labels for each lap

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
    plot(sweep_Calf_Left.imu_time,sqrt((sweep_Calf_Left.Gyro_y.*sweep_Calf_Left.Gyro_y)+(sweep_Calf_Left.Gyro_x.*sweep_Calf_Left.Gyro_x)))
    hold on
    plot(Wahoo.time,Wahoo.pwr_instpwr,'r')
    xlabel('time (s)')
    ylabel('Power and Gyro (F)')
    showEvents(laps, lapTimes);                % function used to show events and vertical lines in plot
    set(timefig, 'Position', [0 0 1920 1080]);
   
    for j=2:length(lapTimes)-1
        axis([lapTimes(j,1)-10,lapTimes(j,1)+10,0,500])
        title(['Offset Lap ' num2str(j)])
        saveas(timefig,strrep(filename,'.mat',['Lap' num2str(j) '_Offset.png']));
    end
   
        
    close all;
end

