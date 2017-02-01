import numpy as np
import pandas as pd


def bbands(x, n=30, numsd=2):
    """Returns average, upper band, and lower band."""
    avg = pd.DataFrame(x).rolling(window=n).mean()
    sd = pd.DataFrame(x).rolling(window=n).std()
    upband = avg + (sd * numsd)
    dnband = avg - (sd * numsd)
    return np.round(avg, 3), np.round(upband, 3), np.round(dnband, 3)


def moving_average(x, n, type='simple'):
    """
    Compute an n-period moving average.

    type is 'simple' or 'exponential'

    """
    x = np.asarray(x)
    if type == 'simple':
        weights = np.ones(n)
    else:
        weights = np.exp(np.linspace(-1.0, 0.0, n))

    weights /= weights.sum()

    a = np.convolve(x, weights, mode='full')[:len(x)]
    a[:n] = a[n]
    return a


def macd(x, nslow=26, nfast=12):
    """
    Compute MACD using fast and slow exponential moving
    averages. Return values are emaslow, emafast, and macd
    which are len(x) arrays.

    """
    emaslow = moving_average(x, nslow, type='exponential')
    emafast = moving_average(x, nfast, type='exponential')
    return emaslow, emafast, emafast - emaslow


def rsi(x, n=14):
    """Compute the n-period relative strength indicator."""
    deltas = np.diff(x)
    seed = deltas[:n+1]
    up = seed[seed >= 0].sum() / n
    down = -seed[seed < 0].sum() / n
    rs = up / down
    rsi = np.zeros_like(x)
    rsi[:n] = 100.0 - 100.0 / (1.0 + rs)

    for i in range(n, len(x)):
        delta = deltas[i-1]
        if delta > 0:
            upval = delta
            downval = 0.0
        else:
            upval = 0.0
            downval = -delta

        up = (up * (n - 1) + upval) / n
        down = (down * (n - 1) + downval) / n

        rs = up / down
        rsi[i] = 100.0 - 100.0 / (1.0 + rs)
    return rsi
