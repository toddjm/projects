import matlabModule as mmod
import matplotlib.font_manager as font_manager
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import numpy as np
import os
import signalModule as smod
import sys

# Set data directory.
data_dir = '/Users/todd/data/warmup_trials'

# Set output directory.
out_dir = os.path.join(data_dir, 'output')

# Read in .mat file name for trial.
fn = sys.argv[1]

# Import Matlab file.
in_file = os.path.join(data_dir, fn)

if os.path.isfile(in_file):
    mdata = mmod.getMatlabData(in_file)
else:
    sys.exit(1)

# Instantite a class for our data.
data = mmod.matlabData(**mdata)

# Find the offset for time 0.
offset_idx = np.where(data.sweep_Calf_Left['time'] == 0)[0][0]

# Work with the left calf SmO2 and tHb data.
SmO2 = data.process_Calf_Left['SmO2'][offset_idx:]
tHb = data.process_Calf_Left['tHb'][offset_idx:]
HR = data.process_Calf_Left['HR'][offset_idx:]

# Stack SmO2 and tHb, then pull out only non-NaN pairs.
SmO2_tHb_HR = np.column_stack((SmO2, tHb, HR))
SmO2_tHb_HR = SmO2_tHb_HR[~np.isnan(SmO2_tHb_HR).any(1)]

# Go back to 1-D arrays.
SmO2 = SmO2_tHb_HR[:, 0]
tHb = SmO2_tHb_HR[:, 1]
HR = SmO2_tHb_HR[:, 2]

# Begin plotting.
plt.rc('axes', grid=True)
plt.rc('grid', color='0.75', linestyle='-', linewidth=0.5)

textsize = 9
left, width = 0.1, 0.8
rect1 = [left, 0.7, width, 0.2]
rect2 = [left, 0.3, width, 0.4]
rect3 = [left, 0.1, width, 0.2]

fig = plt.figure(facecolor='white')
axescolor = '#f6f6f6'  # axes background color

ax1 = fig.add_axes(rect1, axisbg=axescolor)
ax2 = fig.add_axes(rect2, axisbg=axescolor, sharex=ax1)
ax3 = fig.add_axes(rect3, axisbg=axescolor, sharex=ax1)

# Plot RSI.
nper = 100
rsi = smod.rsi(HR, n=nper)
# Set x-axis as seconds.
fillcolor = 'darkgoldenrod'

ax1.plot(rsi, color=fillcolor)
ax1.axhline(80, color=fillcolor)
ax1.axhline(20, color=fillcolor)
ax1.fill_between(rsi, 80, where=(rsi >= 80),
                 facecolor=fillcolor, edgecolor=fillcolor)
ax1.fill_between(rsi, 20, where=(rsi <= 20),
                 facecolor=fillcolor, edgecolor=fillcolor)
ax1.text(0.6, 0.9, '>80 = increases', va='top',
         transform=ax1.transAxes, fontsize=textsize)
ax1.text(0.6, 0.1, '<20 = decreases',
         transform=ax1.transAxes, fontsize=textsize)
ax1.set_xlim(0, len(HR))
ax1.set_ylim(0, 100)
ax1.set_yticks([20, 80])
ax1.text(0.025, 0.95, 'RSI (%d)' % nper, va='top',
         transform=ax1.transAxes, fontsize=textsize)
ax1.set_title('%s' % 'HR')

# Plot MACD.
fillcolor = 'darkslategrey'
nslow = 250
nfast = 100
nema = 75
emaslow, emafast, macd = smod.macd(HR, nslow=nslow, nfast=nfast)
ema9 = smod.moving_average(macd, nema, type='exponential')
ax2.plot(macd, color='black', lw=2)
ax2.plot(ema9, color='blue', lw=1)
ax2.fill_between(macd - ema9, 0, alpha=0.5,
                 facecolor=fillcolor, edgecolor=fillcolor)
ax2.text(0.025, 0.95, 'MACD (%d, %d, %d)' % (nfast, nslow, nema),
         va='top', transform=ax2.transAxes, fontsize=textsize)

# Plot Bollinger bands.
numsd = 3
avg, upband, dnband = smod.bbands(HR, n=500, numsd=numsd)

ax3.plot(HR, color='black', label='HR')
ax3.plot(avg, color='blue', label='mean')
ax3.plot(upband, color='red', label='+{0} $\sigma$'.format(numsd))
ax3.plot(dnband, color='green', label='-{0} $\sigma$'.format(numsd))

props = font_manager.FontProperties(size=10)
ax3.legend(loc='upper left', prop=props)

for ax in ax1, ax2, ax3:
    if ax != ax3:
        for label in ax.get_xticklabels():
            label.set_visible(False)


class MyLocator(mticker.MaxNLocator):
    def __init__(self, *args, **kwargs):
        mticker.MaxNLocator.__init__(self, *args, **kwargs)

    def __call__(self, *args, **kwargs):
        return mticker.MaxNLocator.__call__(self, *args, **kwargs)

ax2.yaxis.set_major_locator(MyLocator(5, prune='both'))
ax3.yaxis.set_major_locator(MyLocator(5, prune='both'))

plot_name = fn.strip('.mat') + '_HR.png'
plt.savefig(os.path.join(out_dir, plot_name))
plt.close()
#plt.show()
