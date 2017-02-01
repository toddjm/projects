import csv
import datetime as dtime
import matlabModule as mmod
import numpy as np
import os
import sys

# Set data directory.
data_dir = '/home/todd/data/warmup_trials'

# Set output directory.
out_dir = os.path.join(data_dir, 'output')

# Make sure we have 2 arguments passed in.
if len(sys.argv) != 3:
    sys.exit(1)

# Import Matlab data.
fn = sys.argv[1]

# Get key (SmO2, tHb, HR) from command line.
key = sys.argv[2]

# Import Matlab file.
in_file = os.path.join(data_dir, fn)

if os.path.isfile(in_file):
    mdata = mmod.getMatlabData(in_file)
else:
    sys.exit(1)

# Instantiate a class for our data.
data = mmod.matlabData(**mdata)

# Find the offset for time 0.
times = data.sweep_Calf_Left['time'].flatten()
offset_idx = int(np.where(times == 0)[0])

# Pull out key for times at and later than offset, remove NaNs.
vals = data.process_Calf_Left[key][offset_idx:]
vals = vals[~np.isnan(vals)]

# Condense vals to every 20th sample, turn it into a list.
vals = vals[::20].tolist()

# Make a list of datetimes the same length of vals.
date_list = [dtime.date.today() - dtime.timedelta(days=x)
             for x in range(1, len(vals) + 1)]
date_list = date_list[::-1]

# Convert list of datetimes to date names such as
# 02-Feb-2010.
dates = [x.strftime('%d-%b-%Y') for x in date_list]

ticker = fn.strip('.mat').upper() + key
out_file = os.path.join(out_dir, fn.strip('.mat') + '_' + key + '.csv')

writer = csv.writer(open(out_file, 'w'))
for i, j in zip(dates, vals):
    writer.writerow([ticker, i, j, j, j, j, j])
