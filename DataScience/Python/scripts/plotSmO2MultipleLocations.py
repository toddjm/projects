import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd


def smooth(x, n):
    """Return moving average for period n."""
    w = np.ones((n, )) / n
    return np.convolve(x, w, mode='valid')

# Specify data directory.
home_dir = '/Users/todd/code'
data_dir = os.path.join(home_dir,
                        'AnalysisTools/Python/data/adam_alter/20151216')
os.chdir(data_dir)

column_names_non_calf = ['c0', 'c1', 'c2', 'c3', 'ts',
                         'c5', 'c6', 'HR', 'c8', 'c9',
                         'SmO2', 'c11', 'c12', 'power', 'c14']

column_names_calf = ['c0', 'c1', 'c2', 'c3', 'ts',
                     'c5', 'c6', 'HR', 'c8', 'c9',
                     'SmO2', 'c11', 'c12', 'power', 'c14',
                     'c15', 'c16', 'c17']

right_forearm = pd.read_csv('right_forearm_LT_20151216.csv',
                            skiprows=5,
                            names=column_names_non_calf)
left_wrist = pd.read_csv('left_wrist_LT_20151216.csv',
                         skiprows=5,
                         names=column_names_non_calf)
back = pd.read_csv('back_LT_20151216.csv',
                   skiprows=5,
                   names=column_names_calf)
chest = pd.read_csv('chest_LT_20151216.csv',
                    skiprows=5,
                    names=column_names_non_calf)
left_calf = pd.read_csv('left_calf_LT_20151216.csv',
                        skiprows=5,
                        names=column_names_non_calf)

data = {}
data['forearm'] = right_forearm
data['wrist'] = left_wrist
data['back'] = back
data['chest'] = chest
data['calf'] = left_calf

for i in ['back', 'chest', 'forearm', 'calf']:
    ts = data[i]['SmO2']
    plt.plot(smooth(ts, 10) / ts.max(), label=i)
plt.grid()
plt.title('Muscle Oxygen Recorded in Multiple Locations: BSXinsight')
plt.ylabel('muscle oxygen')
plt.xlabel('time (s)')
plt.tick_params(axis='y',
                which='both',
                left='off',
                right='off',
                labelleft='off')
plt.rcParams['figure.figsize'] = 10, 8
plt.rcParams['legend.loc'] = 'best'
plt.xlim(xmin=0, xmax=1440)
plt.ylim(ymin=0.5, ymax=1.05)
plt.legend()
plt.show()  # Have a look at the data. Turn off when using savefig.
# plt.savefig('SmO2_multiple_locations.png')  # Turn off when using show.
