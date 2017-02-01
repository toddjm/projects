import matlabModule as mmod
import matplotlib.font_manager as font_manager
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import numpy as np
import os
import signalModule as smod
import signal_statistics as ss
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
SmO2 = data.process_Calf_Left['SmO2'][offset_idx::20]
tHb = data.process_Calf_Left['tHb'][offset_idx::20]
HR = data.process_Calf_Left['HR'][offset_idx::20]

# Stack SmO2 and tHb, then pull out only non-NaN pairs.
SmO2_tHb_HR = np.column_stack((SmO2, tHb, HR))
SmO2_tHb_HR = SmO2_tHb_HR[~np.isnan(SmO2_tHb_HR).any(1)]

# Go back to 1-D arrays.
SmO2 = SmO2_tHb_HR[:, 0]
tHb = SmO2_tHb_HR[:, 1]
HR = SmO2_tHb_HR[:, 2]

# Predictor: f(t) - f(t - period)
period = 100
predictor = (np.roll(SmO2, -period) - SmO2)[:-period]

# Target: f(t + period) - f(t)
target = (HR - np.roll(HR, period))[period:]

ss.lift(predictor, target)

