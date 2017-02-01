import assessmentModule as amod
import glob
import matlabModule as matmod
import matplotlib.pyplot as plt
import numpy as np
import os
"""
Script for reading _process.mat files, filtering SmO2, and finding
maxima and minima.

"""

__author__ = 'Todd Minehardt'


def getValuesDict(in_dict, key_type, tags, start_idx, end_idx):
    """Return dict keys on tags."""
    tmp_dict = {}
    for key in in_dict[key_type].keys():
        if key in tags:
            values = in_dict[key_type][key][start_idx:end_idx]
            tmp_dict[key + '_values'] = values
    return tmp_dict


# Key type. Should be one of 'assessment', 'sweep', 'process',
# 'stat', 'device', 'warmup'.
key_type = 'warmup'

# Suffix for Matlab files. Should correspond to key.
matfile_suffix = '_' + key_type + '.mat'

# Define working directory where Matlab files are and output directory.
data_dir = '/Users/todd/data/COMPLETE/warmup'
out_dir = '/Users/todd/data/COMPLETE/warmup'

# List process files, get assessment IDs from them.
os.chdir(data_dir)
matlab_files = glob.glob('*' + matfile_suffix)
assessment_ids = [i.split('_', 1)[0] for i in matlab_files]

# Get rid of assessments on the exclude_file.
exclude_file = '/Users/todd/code/AnalysisTools/config/exclude_assessments.txt'
with open(exclude_file, 'r') as fn:
    exclude_list = []
    for line in fn:
        exclude_list.append(line)
exclude_list = [i.strip('\n') for i in exclude_list]

# Amend bad_list if assessment ID appears on exclude list.
excluded_list = []
for assess_id in assessment_ids:
    if assess_id in exclude_list:
        assessment_ids.remove(assess_id)
        excluded_list.append(assess_id)

# Build a dict keyed on assessment ID, containing all information
# from relevant Matlab files. This returns a dict of dicts.
data = {}
for assess_id in assessment_ids:
    data[assess_id] = matmod.getMatlabData(assess_id + matfile_suffix)

# Plot parameters.
plt.rcParams['figure.figsize'] = 10, 8
plt.rcParams['legend.loc'] = 'best'

# Tags are keys of interest.
tags = ['HR', 'SmO2', 'tHb']

# Define start and end indices for data arrays.
start_idx = 61
end_idx = None

# Exclude assessments where > 10% of values are NaN and
# where > 10% of HR values are 1.0.
assess_to_del_list = []
bad_HR_list = []
missing_list = []
for assess_id in data.keys():
    values_dict = getValuesDict(data[assess_id],
                                key_type,
                                tags,
                                start_idx,
                                end_idx)

    # Check for NaN.
    HR_vals = values_dict['HR_values']
    SmO2_vals = values_dict['SmO2_values']
    tHb_vals = values_dict['tHb_values']
    hr_pct = np.isnan(HR_vals).sum() / len(HR_vals) * 100.0
    smo2_pct = np.isnan(SmO2_vals).sum() / len(SmO2_vals) * 100.0
    thb_pct = np.isnan(tHb_vals).sum() / len(tHb_vals) * 100.0
    if hr_pct > 10.0 and smo2_pct > 10.0 and thb_pct > 10.0:
        missing_list.append(assess_id)
        assess_to_del_list.append(assess_id)

    # Check for HR.
    hr_gt_cnt = np.count_nonzero(np.where(HR_vals > 20.0))
    hr_pct = hr_gt_cnt / len(HR_vals) * 100.0
    if hr_pct < 90.0:
        bad_HR_list.append(assess_id)
        assess_to_del_list.append(assess_id)

# Remove data dict entries.
assess_to_del_list = list(set(assess_to_del_list))
for entry in assess_to_del_list:
    del data[entry]

# Plot remaining assessments.
good_list = []
for assess_id in data.keys():
    HR = data[assess_id][key_type]['HR']
    SmO2 = data[assess_id][key_type]['SmO2']
    tHb = data[assess_id][key_type]['tHb']

    fig, ax1 = plt.subplots()
    ax1.plot(HR, 'r-', label='HR')
    ax1.plot(SmO2, 'g-', label='SmO2')
    ax1.set_xlabel('time (s)')
    ax1.set_ylabel('HR (bpm) or SmO2 (%)', color='black')
    for tl in ax1.get_yticklabels():
        tl.set_color('black')

    # Fit 4-th order polynomial to tHb and plot.
    y = tHb
    x = np.arange(len(y))
    z = np.polyfit(x, y, deg=4)
    fit = np.polyval(z, x)

    ax2 = ax1.twinx()
    ax2.plot(tHb, 'b-', label='tHb')
    ax2.plot(fit, 'm-', label='fitted tHb')
    ax2.set_ylabel('tHb', color='blue')
    for tl in ax2.get_yticklabels():
        tl.set_color('blue')

    plt.title('HR, SmO2, and tHb for LT Assessments')
    out_file = os.path.join(out_dir, assess_id + '.png')
    plt.savefig(out_file)
    plt.close()
    good_list.append(assess_id)

with open(os.path.join(out_dir, 'good_LT_warmup.txt'), 'a') as fn:
    for line in good_list:
        fn.write(line + '\n')

with open(os.path.join(out_dir, 'excluded_LT_warmup.txt'), 'a') as fn:
    for line in excluded_list:
        fn.write(line + '\n')

with open(os.path.join(out_dir, 'missing_LT_warmup.txt'), 'a') as fn:
    for line in missing_list:
        fn.write(line + '\n')

with open(os.path.join(out_dir, 'bad_HR_LT_warmup.txt'), 'a') as fn:
    for line in bad_HR_list:
        fn.write(line + '\n')
