% Script used to process dynamic hydration data.
% See \Google Drive\Tech_RD\Sensor\Research\Testing\Hydration\Dynamic Osmolality experiment.gsheet
% for more details.
%
% P. Silveira, Jan. 2016
% BSX Proprietary

%% Initialize
clear
close all

% Activity IDs (from first to last trial, listed by site).
id.calf = {
    '5682c276adac1883188b456a'
    '5682c3a2adac187e188b456e'
    '5682E40DADAC184A1B8B456A'
    '5682e400adac18741b8b456a'
    '56830ae6adac186d1f8b456e'
    '56830afcadac18c41e8b456d'
    '5684394cadac185d2a8b456b'
    '56844490adac18d62a8b4567'
    };

id.wrist = {
    '5682c11badac187e188b4569'
    '5682c268adac187e188b456c'
    '5682e2f7adac18501b8b456a'
    '5682e2e6adac18501b8b4569'
    '568309c8adac18c41e8b456c'
    '568309ceadac186d1f8b456d'
    '56843812adac185d2a8b456a'
    '56843c25adac18722a8b4568'
    };

id.pectoral = {
    '5682bdb0adac187e188b4568'
    '5682c110adac1883188b4567'
    '5682e19badac18501b8b4568'
    '5682e18aadac184a1b8b4568'
    '568307eeadac18791e8b456b'
    '56830805adac18791e8b456c'
    '568436e3adac185d2a8b4569'
    '5684397eadac182c2a8b456d'
    };

id.temple = {
    '5682bc6dadac1802188b456b'
    '5682bfacadac1877188b456a'
    '5682e088adac18741b8b4568'
    '5682e078adac18741b8b4567'
    '568306a7adac18791e8b4569'
    '568306b4adac18b91d8b4568'
    '56843531adac18b0298b456a'
    '568436b0adac182c2a8b456b'
    };

BL_osm = [295
293
292
287
291
289
295
289];   % baseline plasma osmolality (mOsm/kg)

eh_osm = [290
287
285
283
286
282
293
281];   % euhydrated osmolality (mOsm/kg)

osm = [BL_osm eh_osm];

EVENTS = {'start' 'drink' '1h' 'end'};
EVENT_TIMES = [1 600 4200 4766];
FILTER_LENGTH = 60;  % filter length (s)
MIN_MULT = 0.98; % max and min multipliers used to scale axes
MAX_MULT = 1.02;

% Path parameters
USERPATH = getenv('USERPROFILE');   % get user path (in Windows environment)
FILE_PATH = [USERPATH '\Google Drive\Tech_RD\Sensor\Research\Testing\Hydration\Dynamic Osmolality\Sanity check\'];
SWEEP_SUFFIX = '_sweep.mat';    % suffix of files with sweep structures

%% Data input

sites = fields(id); % get list of sites
numSites = length(sites);
numTrials = length(id.(sites{1}));
for ii = 1:numTrials
    figure(ii)
    for jj = 1:numSites
        load([FILE_PATH id.(sites{jj}){ii} SWEEP_SUFFIX])
        sampRate = sweep.samp_rate;
%        time = round(sweep.time(EVENT_TIMES(1)*sampRate:EVENT_TIMES(end)*sampRate));
        [OD15, OD27] = processCounts(sweep);
        ODDiff = OD27 - OD15; % calculate OD difference and crop at last event
        [pH2Oproj, pH2Ocos] = calc_hydration(ODDiff);
        [pH2Ocolip, Pk2] = calc_hydration2(ODDiff);
        pH2OcolipR = pH2Ocolip ./ Pk2(:,4); % ratio of water over collagen+lipid
        [SmO2, Resid, mu_eff, HbF, Pk] = calc_SmO2(ODDiff);
        process.(sites{jj}).trial{ii}.pH2O_pInv = avgfiltNaN(Pk(:,3), FILTER_LENGTH*sampRate);
        process.(sites{jj}).trial{ii}.pH2O_cos = avgfiltNaN(pH2Ocos, FILTER_LENGTH*sampRate);
        process.(sites{jj}).trial{ii}.pH2O_proj = avgfiltNaN(pH2Oproj, FILTER_LENGTH*sampRate);
        process.(sites{jj}).trial{ii}.pH2O_colip = avgfiltNaN(pH2Ocolip, FILTER_LENGTH*sampRate);
        process.(sites{jj}).trial{ii}.pH2O_colipR = avgfiltNaN(pH2OcolipR, FILTER_LENGTH*sampRate);
        process.(sites{jj}).trial{ii}.NearOD = avgfiltNaN(OD15, FILTER_LENGTH*sampRate);
        process.(sites{jj}).trial{ii}.FarOD = avgfiltNaN(OD27, FILTER_LENGTH*sampRate);
        process.(sites{jj}).stat.pH2O_pInv = baselineStats(process.(sites{jj}).trial{ii}.pH2O_pInv);
        process.(sites{jj}).stat.pH2O_cos = baselineStats(process.(sites{jj}).trial{ii}.pH2O_cos);
        process.(sites{jj}).stat.pH2O_proj = baselineStats(process.(sites{jj}).trial{ii}.pH2O_proj);
        process.(sites{jj}).stat.pH2O_colip = baselineStats(process.(sites{jj}).trial{ii}.pH2O_colip);
        process.(sites{jj}).stat.pH2O_colipR = baselineStats(process.(sites{jj}).trial{ii}.pH2O_colipR);
        process.(sites{jj}).stat.NearOD = baselineStats(process.(sites{jj}).trial{ii}.NearOD);
        process.(sites{jj}).stat.FarOD = baselineStats(process.(sites{jj}).trial{ii}.FarOD);
        timePlot = sweep.time; %time - EVENT_TIMES(1);
        set (gcf, 'Position', [1        -659        2304        1283]);
        numMethods = length(fields(process.(sites{jj}).trial{ii}));   % number of methods used to calculate hydration
        subplot(numSites,numMethods,(jj-1)*numMethods+1)
        plot(timePlot, process.(sites{jj}).trial{ii}.pH2O_pInv)
        ylabel('pInv method')
        if jj == 1
            title(['Trial = ' num2str(ii) '. Site = ' sites{jj}])
        else
            title(['Site = ' sites{jj}])
            if jj == numSites
                xlabel('time (s)')
            end
        end
        grid
        axis([0 timePlot(end) MIN_MULT*process.(sites{jj}).stat.pH2O_pInv.min_prctile MAX_MULT*process.(sites{jj}).stat.pH2O_pInv.max_prctile])
        showEvents(EVENTS(2:end-1), EVENT_TIMES(2:end-1));
        subplot(numSites,numMethods,(jj-1)*numMethods+2)
        plot(timePlot, process.(sites{jj}).trial{ii}.pH2O_cos)
        ylabel('cosine method')
        if jj == 1
            title(['Trial = ' num2str(ii) '. Site = ' sites{jj}])
        else
            title(['Site = ' sites{jj}])
            if jj == numSites
                xlabel('time (s)')
            end
        end
        grid
        axis([0 timePlot(end) process.(sites{jj}).stat.pH2O_cos.min_prctile process.(sites{jj}).stat.pH2O_cos.max_prctile])
%         plot(timePlot,  process.(sites{jj}).trial{ii}.NearOD)
%         ylabel('OD 15mm')
%         if jj == 1
%             title(['Trial = ' num2str(ii) '. Site = ' sites{jj}])
%         else
%             title(['Site = ' sites{jj}])
%             if jj == numSites
%                 xlabel('time (s)')
%             end
%         end
%         grid
%         axis([0 timePlot(end) process.(sites{jj}).stat.NearOD.min_prctile process.(sites{jj}).stat.NearOD.max_prctile])
    
        showEvents(EVENTS(2:end-1), EVENT_TIMES(2:end-1));
        subplot(numSites,numMethods,(jj-1)*numMethods+3)
        plot(timePlot, process.(sites{jj}).trial{ii}.pH2O_proj)
        ylabel('projection')
        if jj == 1
            title(['Trial = ' num2str(ii)])
        else
            title(sites{jj})
            if jj == numSites
                xlabel('time (s)')
            end
        end
        grid
        axis([0 timePlot(end) process.(sites{jj}).stat.pH2O_proj.min_prctile process.(sites{jj}).stat.pH2O_proj.max_prctile])
%         plot(timePlot,  process.(sites{jj}).trial{ii}.FarOD)
%         ylabel('OD 27mm')
%         if jj == 1
%             title(['Trial = ' num2str(ii)])
%         else
%             title(sites{jj})
%             if jj == numSites
%                 xlabel('time (s)')
%             end
%         end
%         grid
%         axis([0 timePlot(end) process.(sites{jj}).stat.FarOD.min_prctile process.(sites{jj}).stat.FarOD.max_prctile])
     
    showEvents(EVENTS(2:end-1), EVENT_TIMES(2:end-1));
        subplot(numSites,numMethods,(jj-1)*numMethods+4)
        plot(timePlot, process.(sites{jj}).trial{ii}.pH2O_colip)
        ylabel('colip method')
        if jj == 1
            title(['Trial = ' num2str(ii) '. Site = ' sites{jj}])
        else
            title(['Site = ' sites{jj}])
            if jj == numSites
                xlabel('time (s)')
            end
        end
        grid
        axis([0 timePlot(end) process.(sites{jj}).stat.pH2O_colip.min_prctile process.(sites{jj}).stat.pH2O_colip.max_prctile])
        showEvents(EVENTS(2:end-1), EVENT_TIMES(2:end-1));
        clear('ODDiff', 'time', 'temp')
        subplot(numSites,numMethods,(jj-1)*numMethods+5)
        plot(timePlot, process.(sites{jj}).trial{ii}.pH2O_colipR)
        ylabel('colip ratio')
        if jj == 1
            title(['Trial = ' num2str(ii) '. Site = ' sites{jj}])
        else
            title(['Site = ' sites{jj}])
            if jj == numSites
                xlabel('time (s)')
            end
        end
        grid
        axis([0 timePlot(end) process.(sites{jj}).stat.pH2O_colipR.min_prctile process.(sites{jj}).stat.pH2O_colipR.max_prctile])
        showEvents(EVENTS(2:end-1), EVENT_TIMES(2:end-1));
        clear('ODDiff', 'time', 'temp')

        save([FILE_PATH 'Trial_' num2str(ii) sites{jj}], 'OD15', 'OD27')
            
    end
%    print(sprintf('%sTrial%d.tif', FILE_PATH,ii), '-dtiff')   % save plot as Level 2, Color
    print(sprintf('%sTrial%d.emf', FILE_PATH,ii), '-dmeta')   % save plot as emf file
    
end

% plotMethod(jj, ii, numSites, numMethods, timePlot, process.(sites{jj}).trial{ii}.pH2O, process.(sites{jj}).stat.pH2O_proj)
% showEvents(EVENTS(2:end-1), EVENT_TIMES(2:end-1));
% function plotMethod(jj, ii, numSites, numMethods, timePlot, proj, stats)
%         subplot(numSites,numMethods,(jj-1)*numMethods+3)
%         plot(timePlot, process.(sites{jj}).trial{ii}.pH2O_proj)
%         ylabel('projection')
%         if jj == 1
%             title(['Trial = ' num2str(ii)])
%         else
%             title(sites{jj})
%             if jj == numSites
%                 xlabel('time (s)')
%             end
%         end
%         grid
%         axis([0 timePlot(end) stats.min_prctile stats.max_prctile])
% end
