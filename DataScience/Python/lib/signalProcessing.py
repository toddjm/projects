"""
Statistical functions for determining good predictors.

"""

import math
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np

__author__ = "Todd Minehardt"
__copyright__ = "Copyright 2011, bicycle trading, llc"
__email__ = "todd@bicycletrading.com"


def lift(x_1, y_1, buy_threshold=0.0, sell_threshold=0.0, plot=True):
    """
    Construct lift curves and summary statistics for buy and sell targets.

    """
    if (len(x_1) != len(y_1)):
        return 0

    # stack predictor and target vectors
    data = np.column_stack((x_1, y_1))

    # number of observations = # of rows of data
    nobv = data.shape[0]

    # sort data on predictor (column 0), high to low
    idx = data[:, 0].argsort()[::-1]
    data = data[idx]

    # lift for buy and sell targets
    lift_buy = np.where(data[:, 1] >
                          buy_threshold, 1.0, 0.0).cumsum()
    lift_sell = np.where(data[:, 1][::-1] <
                           sell_threshold, -1.0, 0.0).cumsum()

    # mean lift = (total # of targets in class buy or sell) / nobv
    #meanLiftBuy =  liftBuy[-1] / float(nobv)
    #meanLiftSell = liftSell[-1] / float(nobv)

    # output [column]:
    # [0] buy or sell
    # [1] percent of ordered observations
    # [2] raw lift
    # [3] ratio of lift to mean lift for the percentile
    # [4] number of samples in the percentile

    bins = np.floor(np.sqrt(nobv) + 0.5).astype(int)
    step = int(nobv / bins)
    idx = [np.floor(float(i) / nobv * 100.0 + 0.5) for i in
            range(1, nobv + 1)]

    # zero-pad element 0 of rawLift arrays
    raw_lift_buy = np.insert(
        (np.array([lift_buy[i] / float(i) for i in range(1, nobv)])),
        0, 0.0)
    raw_lift_sell = np.insert(
        (np.array([lift_sell[i] / float(i) for i in range(1, nobv)])),
        0, 0.0)

    print('buy:')
    for i in range(step - 1, nobv, step):
        print('{0:.2f} {1:.3f} {2:.3f} {3:3d}'.format(
            idx[i],
            raw_lift_buy[i],
            100.0 *
            (((raw_lift_buy[i] * float(nobv)) / lift_buy[-1]) - 1.0) /
            idx[i],
            i))

    print()

    print('sell:')
    for i in range(step - 1, nobv, step):
        print('{0:.2f} {1:.3f} {2:.3f} {3:3d}'.format(
            idx[i],
            raw_lift_sell[i],
            100.0 *
            (((raw_lift_sell[i] * float(nobv)) / lift_sell[-1]) - 1.0) /
            idx[i],
            i))

    # normalize lift by subtracting the cumulative mean lift
    lift_buy -= np.array([lift_buy[-1] / float(nobv)] * nobv).cumsum()
    lift_sell -= np.array([lift_sell[-1] / float(nobv)] * nobv).cumsum()

    if plot:
        plot_lift(lift_buy, data[:, 0], lift_sell, data[:, 0][::-1])
    return


def plot_lift(y_1, y_2, y_3, y_4):
    """Plot normalized lift and sorted predictors."""
    len_y_1 = len(y_1)
    fig = plt.figure()
    p_1 = fig.add_subplot(111)
    arange_y_1 = np.arange(len_y_1)
    p_1.plot(arange_y_1, y_1, 'b-')
    p_1.grid(which='both')
    p_1.minorticks_on()
    p_1.set_xlabel('observations')
    p_1.set_ylabel('normalized lift - buy', color='b')
    for tick in p_1.get_yticklabels():
        tick.set_color('b')
    p_2 = p_1.twinx()
    p_2.plot(y_2, 'b-')
    p_3 = p_1.twinx()
    p_3.plot(y_3, 'r-')
    p_3.set_ylabel('normalized lift - sell', color='r')
    for tick in p_3.get_yticklabels():
        tick.set_color('r')
    p_4 = p_1.twinx()
    p_4.plot(y_4, 'r-')
    yticklabels = p_2.get_yticklabels() + p_4.get_yticklabels()
    yticklines = p_2.get_yticklines() + p_4.get_yticklines()
    plt.setp(yticklabels, visible=False)
    plt.setp(yticklines, visible=False)
    plt.show()
    return
