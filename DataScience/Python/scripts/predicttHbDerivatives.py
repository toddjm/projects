import assessmentModule as amod
import matplotlib.pyplot as plt
import numpy as np
import os
import scipy.signal as ss
"""
For a subset of running LT assessments, look at relationships
between SmO2, tHb, and HR using change in slope.

"""

__author__ = 'Todd Minehardt'


# Filter data with Savitsky-Golay.
def returnSGFilteredData(x, window_length, polyorder, deriv):
    """Given x, window size, and polynomial order, return
    Savitsky-Golay filtered data.
    """
    return ss.savgol_filter(x.flatten(),
                            window_length=window_length,
                            polyorder=polyorder,
                            deriv=deriv)


def smooth(x, n):
    """Return moving average for period n."""
    w = np.ones((n, )) / n
    return np.convolve(x, w, mode='valid')


# Define working directory where Matlab files are and output directory.
data_dir = '/Users/todd/data/WARMUP/RUN'
out_dir = '/Users/todd/data/WARMUP/RUN/derivatives'

# Go to working directory.
os.chdir(data_dir)

# Get list of LT assessment IDs from list.
aid_file = '/Users/todd/code/AnalysisTools/config/subset_runs_score_16-18.txt'
with open(aid_file, 'r') as fn:
    aid_list = []
    for line in fn:
        aid_list.append(line)
assessment_ids = [i.strip('\n') for i in aid_list]

# Build a dict keyed on assessment ID, containing all information
# from relevant Matlab files. This returns a dict of dicts.
data = {}
for assess_id in assessment_ids:
    data[assess_id] = amod.getMatlabData(assess_id + '_process.mat')
    data[assess_id].update(amod.getMatlabData(assess_id + '_sweep.mat'))

# Define start and end indices for data arrays.
start_idx = 161
end_idx = None

# Plot remaining assessments.
for assess_id in data.keys():

    if 'HR' in data[assess_id]['process'].keys():
        HR = data[assess_id]['process']['HR']
    elif 'HR' in data[assess_id]['sweep'].keys():
        HR = data[assess_id]['sweep']['HR']

    if 'SmO2' in data[assess_id]['process'].keys():
        SmO2 = data[assess_id]['process']['SmO2']
    elif 'SmO2' in data[assess_id]['sweep'].keys():
        SmO2 = data[assess_id]['sweep']['SmO2']

    if 'tHb' in data[assess_id]['process'].keys():
        tHb = data[assess_id]['process']['tHb']

    # Truncate arrays on start and end indices.
    HR = HR[start_idx:end_idx]
    SmO2 = SmO2[start_idx:end_idx]
    tHb = tHb[start_idx:end_idx]

    # Three subplots sharing x axis
    f, (ax1, ax2, ax3) = plt.subplots(3, sharex=False, sharey=False)

    # Plot the polynomial fit for HR.
    idx = np.isfinite(HR)
    y = HR[idx]
    x = np.arange(len(y))
    z = np.polyfit(x, y, deg=4)
    fit = np.polyval(z, np.arange(len(HR)))

    x_time_ticks = np.arange(len(fit)) / 5
    ax1.plot(x_time_ticks,
             fit,
             color='red',
             label='HR fit')

    ax1.plot(x_time_ticks,
             HR,
             color='red',
             label='HR')

    ax1.set_ylim(np.nanmin(HR),
                 np.nanmax(HR))
    ax1.set_ylabel('HR (bpm)',
                   color='red')
    for tl in ax1.get_yticklabels():
        tl.set_color('red')
    ax1.set_title('Assessment ' + assess_id)

    ax1.minorticks_on()
    ax1.xaxis.grid(True, which='major')
    ax1.xaxis.grid(True, which='minor')
    ax1.yaxis.grid(True, which='major')
    ax1.yaxis.grid(False, which='minor')
    ax1.tick_params(axis='y', which='minor', left='off')

    # Plot the polynomial fit for SmO2.
    idx = np.isfinite(SmO2)
    y = SmO2[idx]
    x = np.arange(len(y))
    z = np.polyfit(x, y, deg=4)
    fit = np.polyval(z, np.arange(len(SmO2)))
    x_time_ticks = np.arange(len(fit)) / 5

    ax2.plot(x_time_ticks,
             fit,
             color='green',
             label='SmO2 fit')
    ax2.plot(x_time_ticks,
             SmO2,
             color='green',
             label='SmO2',
             alpha=0.25)
    ax2.set_ylim(np.nanmin(SmO2),
                 np.nanmax(SmO2))
    ax2.set_ylabel('SmO2 (%)',
                   color='green')
    for tl in ax2.get_yticklabels():
        tl.set_color('green')

    ax2.minorticks_on()
    ax2.xaxis.grid(True, which='major')
    ax2.xaxis.grid(True, which='minor')
    ax2.yaxis.grid(True, which='major')
    ax2.yaxis.grid(False, which='minor')
    ax2.tick_params(axis='y', which='minor', left='off')

    # Find local maximum from end of stage 1 to stage 8.
    local_max = start_idx + np.argmax(fit[900:7200]) / 5
    ax2.axvline(local_max,
                color='green',
                linewidth=3,
                label=local_max)
    ax2.legend()

    # Plot the polynomial fit for tHb.
    idx = np.isfinite(tHb)
    y = tHb[idx]
    x = np.arange(len(y))
    z = np.polyfit(x, y, deg=4)
    fit = np.polyval(z, np.arange(len(tHb)))

    x_time_ticks = np.arange(len(fit)) / 5
    ax3.plot(x_time_ticks,
             fit,
             color='blue',
             label='tHb fit')
    ax3.plot(x_time_ticks,
             tHb,
             color='blue',
             label='tHb',
             alpha=0.25)
    ax3.set_ylim(np.nanmin(tHb),
                 np.nanmax(tHb))
    ax3.set_ylabel('tHb fit (g/dL)',
                   color='blue')

    for tl in ax3.get_yticklabels():
        tl.set_color('blue')
    ax3.set_xlabel('time (s)')

    ax3.minorticks_on()
    ax3.xaxis.grid(True, which='major')
    ax3.xaxis.grid(True, which='minor')
    ax3.yaxis.grid(True, which='major')
    ax3.yaxis.grid(False, which='minor')
    ax3.tick_params(axis='y', which='minor', left='off')
    # Find local maximum from end of stage 1 to stage 8.
    local_max = start_idx + np.argmax(fit[900:7200]) / 5
    ax3.axvline(local_max,
                color='blue',
                linewidth=3,
                label=local_max)
    ax3.legend()

    # Fine-tune figure; make subplots close to each other and hide x ticks for
    # all but bottom plot.
    f.subplots_adjust(hspace=0)

    plt.setp([a.get_xticklabels() for a in f.axes[:-1]], visible=False)

    # Plot parameters.
    plt.rcParams['figure.figsize'] = 10, 8
    plt.rcParams['legend.loc'] = 'best'
#    out_file = os.path.join(out_dir, assess_id + '.png')
#    plt.savefig(out_file)
#    plt.close()
    plt.show()
