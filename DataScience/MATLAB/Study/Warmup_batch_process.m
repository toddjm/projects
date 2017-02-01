% Script used to process warmup indicator data.
% See https://docs.google.com/spreadsheets/d/1lM7xxv44fqstfg8CcBYe-MOeWz0cI2RhvzXZCo9RoAc/edit#gid=0
% for more details.
%
% P. Silveira, Feb. 2016
% BSX Proprietary

%% Initialize
clear
close all

% Activity IDs (from first to last trial, listed by site).
id.LeftCalf = {'56c4fb4cadac1869268b456a'
    
'56c613feadac181d308b4567'
'56c634a0adac18df308b456d'
'56c64fdaadac18e7318b4567'


'56c73d69adac18623b8b4568'
'56c7542aadac18b03c8b4567'

'56c7a0aeadac181a408b4568'

'56cb6a22adac18d35c8b456c'
'56cb7ba7adac1868608b4578'
'56cb994eadac1899618b4568'


'56ccda60adac185a718b4567'
'56cd046eadac183d728b4567'

'56cdecfeadac18267e8b4568'
'56ce0946adac18b47e8b456a'
'56ce20c2adac186a7f8b4568'
'56ce4914adac187e018b4569'
};


id.LeftQuad = {'56c4fbfcadac1869268b456c'
    
'56c6148eadac181a308b456a'
'56c63594adac18df308b456e'
'56c65106adac180a328b4567'


'56c73debadac18623b8b4569'
'56c7572dadac18173d8b4567'

'56c7a1acadac181f408b4568'

'56cb6a85adac1843608b4568'
'56cb7c1aadac18d9608b4567'
'56cb99ffadac1838618b4569'

'56ccb645adac18636e8b456a'
'56ccdc70adac1861718b4568'
'56cd04caadac1844728b456a'

'56cdedabadac18fd7d8b456c'
'56ce0a2fadac18fb7e8b4567'
'56ce2123adac186c7f8b4569'
'56ce4802adac18aa018b4569'
};

id.RightWrist = {'56c4fca0adac1860268b456d'
    
'56c61ac2adac1868308b4568'
'56c6368fadac180c318b4569'
'56c651cbadac1811328b4568'


'56c7835fadac182a3f8b456b'
'56c78300adac182c3f8b456a'

'56c7a425adac181f408b4569'

'56cb6b0eadac18d35c8b456d'
'56cb7c9dadac18d9608b4569'
'56cb9a9fadac181b638b4568'

'56ccb6ecadac18326e8b4572'
'56ccdd8aadac1862718b4568'
'56cd0787adac1844728b456c'


'56ce0acdadac18017f8b4567'
'56ce2050adac186c7f8b4568'
'56ce488fadac18aa018b456a'
};

trial = {'01'
    
'02'
'03'
'04'

'06'
'07'
'09'

'10'
'11'
'12'


'14'
'15'

'16'
'17'
'18'
'19'
};

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Warmup_Indicator\'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures
PROCESS_SUFFIX = '_process.mat';
IMG_SUFFIX = '.emf';

%% Data input

figure
set(gcf, 'Position', [713 176 960 544])
sites = fields(id); % get list of sites
numSites = length(sites);
numTrials = length(trial);
for ii = 1:numTrials
    for jj = 1:numSites
        activity_id =  id.(sites{jj}){ii};
        pathn = [FILE_PATH 'Trial' trial{ii} '\'];
        sweepFilen =  [pathn activity_id SWEEP_SUFFIX];
        processFilen =  [pathn activity_id PROCESS_SUFFIX];
        fprintf('Processing trial %s, site %s, activity id %s.\n', trial{ii}, sites{jj}, activity_id);
        if ~exist(sweepFilen, 'file')
            activity = getActivity(activity_id);
            sweep = getSweep(activity)
            process = sweep2process(sweep)
            save(sweepFilen, 'sweep', 'activity')
            save(processFilen, 'process')
        else
            load(sweepFilen)
            load(processFilen)
        end
        generateAssessmentPlot(sweep, process)
        print([pathn activity_id IMG_SUFFIX], '-dmeta')
    end
end



