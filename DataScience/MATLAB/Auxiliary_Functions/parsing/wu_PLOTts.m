%% Plot all Timeseries
load('timeseries.mat')
timefig = figure;
subplot(4,2,1)       
plot(COUNTStsSYNC)

subplot(4,2,3)      
plot(ODtsSYNC)       

subplot(4,2,5)       
plot(ACCtsSYNC)      

subplot(4,2,7)       
plot(COREtsSYNC)   

subplot(4,2,2)       
plot(sMO2tsSYNC)

subplot(4,2,4)       
plot(tHBtsSYNC)       

subplot(4,2,6)       
plot(PWRtsSYNC) 

subplot(4,2,8)       
plot(HRtsSYNC) 
 
  
set(timefig, 'Position', [0 0 1920 1080])
saveas(timefig,'timeseries.png');
close all