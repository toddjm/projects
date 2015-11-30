"""
Example: Kolmogorov-Smirnov two-sided test.

"""

import math
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import Quandl


def gcd(x_1, x_2):
    """Return greatest common divisor."""
    while x_2:
        x_1, x_2 = x_2, x_1 % x_2
    return x_1


def ks_signif(x_1):
    """
    Return smallest significance level for rejecting null hypothesis,
    using the asymptotic limiting case to compute Q(x) for x > 0.

    """
    if x_1 <= 0.0:
        return 0.0
    y_1 = 0.0
    for i in range(-20, 20):
        y_1 += math.pow(-1.0, i) * math.exp(-2.0 * i ** 2 * x_1 ** 2)
    return 1.0 - y_1


def ks_test(x_1, y_1, plot=True):
    """
    Kolmogorov-Smirnov two-sided, two-sample test.

    Returns tuple of the test statistic for arrays `x` and `y` and
    the significance level for rejecting the null hypothesis.
    The empirical distribution functions F(t) and G(t) are
    computed and (optionally) plotted.

    """
    if len(x_1) == 0 or len(y_1) == 0:
        return 0
    # rows_x_1, rows_y_1 = # of rows in each array x, y
    rows_x_1 = x_1.shape[0]
    rows_y_1 = y_1.shape[0]

    # Compute GCD for (x_1, y_1).
    gcd_x_1_y_1 = float(gcd(rows_x_1, rows_y_1))

    # Flatten, concatenate, and sort all data from low to high.
    data = np.concatenate((x_1.flatten(), y_1.flatten()))
    data = np.sort(data)

    # ECDFs evaluated at ordered combined sample values data.
    f_of_t = np.zeros(len(data))
    g_of_t = np.zeros(len(data))

    # Compute j_stat, the K-S statistic.
    j_stat = 0.0
    for i in range(len(data)):
        for j in range(rows_x_1):
            if x_1[j] <= data[i]:
                f_of_t[i] += 1
        f_of_t[i] /= float(rows_x_1)
        for j in range(rows_y_1):
            if y_1[j] <= data[i]:
                g_of_t[i] += 1
        g_of_t[i] /= float(rows_y_1)
        j_stat_max = np.abs(f_of_t[i] - g_of_t[i])
        j_stat = max(j_stat, j_stat_max)
    j_stat *= rows_x_1 * rows_y_1 / gcd_x_1_y_1
    # The large-sample approximation.
    j_stat_star = j_stat * gcd_x_1_y_1 / np.sqrt(rows_x_1 * rows_y_1 *
                                                 (rows_x_1 + rows_y_1))

    if plot:
        y_2 = np.arange(rows_x_1 + rows_y_1) / float(rows_x_1 + rows_y_1)
        plt.plot(f_of_t, y_2, 'm-', label='F(t)')
        plt.plot(g_of_t, y_2, 'b-', label='G(t)')
        plt.xlabel('value')
        plt.ylabel('cumulative probability')
        mpl.rcParams['legend.loc'] = 'best'
        plt.legend()
        plt.show()
    print('{0:.4f} {1:.4f}'.format(j_stat_star, ks_signif(j_stat_star)))
    return
