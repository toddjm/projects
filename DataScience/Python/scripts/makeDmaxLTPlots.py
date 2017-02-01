import glob
import matplotlib.pyplot as plt
import numpy as np
import os
import sys


def mps_to_mph(x):
    "Given m/s, return mph."""
    return x * 2.23694

# Set data directory. Are we on Linux or Mac OS X?
if sys.platform == 'linux':
    data_dir = '/home/todd/code/AnalysisTools/Python/data/lt_assessments/cycling'
elif sys.platform == 'darwin':
    data_dir = '/Users/todd/data/lt1_dmax/clean/LT1/running'

# Set output directory.
out_dir = os.path.join(data_dir, 'output')

# Read in .csv file names from data directory as list.
#file_names = glob.glob(os.path.join(data_dir, '*.csv'))
#file_names = [i.strip('\n') for i in file_names]
#file_names = ['/home/todd/data/lt1_dmax/clean/LT1/running/Subject_607_Running.csv']
file_names = ['/home/todd/code/AnalysisTools/Python/data/lt_assessments/cycling/Kelly_Kirby_20160511_Adjusted.csv']

for fn in file_names:
    # Read data from csv file to temporary array.
    data = np.genfromtxt(fn, delimiter=',')

    # Pull out arrays of x and y values.
    xs = data[:, 0]
    ys = data[:, 1]

    # If we have a zero value for an xs, drop it from analysis.
    if xs[0] == 0:
        xs = xs[1:]
        ys = ys[1:]

    # Plot original data.
    plt.plot(xs, ys, label='${L}_1$')

    # Create a linear space for fitting polynomials.
    x_for_fit = np.linspace(xs.min(), xs.max(), num=100)

    # Fit 1st-order polynomial to the first and last
    # points to get L2.
    L2_coef = np.polyfit([xs[0], xs[-1]], [ys[0], ys[-1]], deg=1)
    L2 = np.polyval(L2_coef, x_for_fit)

    # Plot L2.
    plt.plot(x_for_fit, L2, label='${L}_2$')

    # Calculate 1st derivative  of L2.
    L2_deriv = (ys[-1] - ys[0]) / (xs[-1] - xs[0])

    # Fit a 3rd-order polynomial to the data for L3.
    L3_coef = np.polyfit(xs, ys, deg=3)
    L3 = np.polyval(L3_coef, x_for_fit)

    # Plot L3.
    plt.plot(x_for_fit, L3, label='${L}_3$')

    # Find where the first derivative of L3 = L2_deriv.
    dmax = np.polynomial.polynomial.polyroots([L3_coef[2] - L2_deriv,
                                              2 * L3_coef[1],
                                              3 * L3_coef[0]]).max()

    # Draw line for Dmax.
    dmax_label = '$\mathrm{D}_\mathrm{max}$'
    mph_label = '$\mathrm{mph}$'
    watts_label = '$\mathrm{W}$'
    plt.vlines(x=dmax, ymin=0, ymax=2.0,
                color='magenta',
                label='{0} = {1:.2f} {2}'.format(dmax_label,
                    dmax, watts_label))
#    plt.vlines(x=mps_to_mph(dmax), ymin=0, ymax=2.0,
#                color='magenta',
#                label='{0} = {1:.2f} {2}'.format(dmax_label,
#                    mps_to_mph(dmax), mph_label))
#    plt.axvline(dmax, ymax=2.0,
#                color='magenta',
#                label='{0} = {1:.2f} m/s'.format(dmax_label, dmax))
#            label='$mathrm{Dmax}$ = {0:.2f} m/s'.format(dmax))

    # Set title and axes labels.
#    title = fn.split('/')[-1]
#    title = title.split('.')[0]
#    plt.title(title)
#    plt.title('$\mathrm{D}_{max}\; \mathrm{Illustration - Running}$')
    plt.title('Dmax for Kelly Kirby - Blood Lactate Data 2016-05-11')

    # Show plot.
    plt.rcParams['legend.loc'] = 'best'
#    plt.xlabel('pace (mph)')
    plt.xlabel('power (W)')
    plt.ylabel('[lactate], mmol/L')
    plt.legend()
#    plt.show()
#    out_file = title + '.png'
#    plt.savefig(os.path.join(out_dir, out_file))
    plt.savefig('Kelly_Kirby_Dmax_Adjusted.png')
    plt.close()
