import glob
import matplotlib.pyplot as plt
import numpy as np
import os
import sys

# Set data directory. Are we on Linux or Mac OS X?
if sys.platform == 'linux':
    data_dir = '/home/todd/data/lt1_dmax/clean/LT1/running'
elif sys.platform == 'darwin':
    data_dir = '/Users/todd/data/lt1_dmax/clean/LT1/running'

# Set output directory.
out_dir = os.path.join(data_dir, 'output')

# Read in .csv file names from data directory as list.
file_names = glob.glob(os.path.join(data_dir, '*.csv'))
file_names = [i.strip('\n') for i in file_names]

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
    plt.plot(xs, ys, label='original')

    # Create a linear space for fitting polynomials.
    x_for_fit = np.linspace(xs.min(), xs.max(), num=100)

    # Fit 1st-order polynomial to the first and last
    # points to get L2.
    L2_coef = np.polyfit([xs[0], xs[-1]], [ys[0], ys[-1]], deg=1)
    L2 = np.polyval(L2_coef, x_for_fit)

    # Plot L2.
    plt.plot(x_for_fit, L2, label='L2')

    # Calculate 1st derivative  of L2.
    L2_deriv = (ys[-1] - ys[0]) / (xs[-1] - xs[0])

    # Fit a 3rd-order polynomial to the data for L3.
    L3_coef = np.polyfit(xs, ys, deg=3)
    L3 = np.polyval(L3_coef, x_for_fit)

    # Plot L3.
    plt.plot(x_for_fit, L3, label='L3')

    # Find where the first derivative of L3 = L2_deriv.
    dmax = np.polynomial.polynomial.polyroots([L3_coef[2] - L2_deriv,
                                              2 * L3_coef[1],
                                              3 * L3_coef[0]]).max()

    # Draw line for Dmax.
    plt.axvline(dmax, color='magenta',
            label='Dmax {0:.2f}'.format(dmax))

    # Set title and axes labels.
    title = fn.split('/')[-1]
    title = title.split('.')[0]
    plt.title(title)

    # Show plot.
    plt.rcParams['legend.loc'] = 'best'
    plt.xlabel('pace (m/s)')
    #plt.xlabel('power (W)')
    plt.ylabel('[lactate], mmol/L')
    plt.legend()
#    plt.show()
    out_file = title + '.png'
    plt.savefig(os.path.join(out_dir, out_file))
    plt.close()
