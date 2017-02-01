# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from matplotlib import pyplot as plt
import pandas as pd


pd.read_csv('/Users/emily/Downloads/Wahoo.csv')
pd.read_csv('/Users/emily/Downloads/Wahoo.csv', skiprows=19)
wahoo_data = pd.read_csv('/Users/emily/Downloads/Wahoo.csv', skiprows=19)
wahoo_data.cad_cadence
cadence = wahoo_data.cad_cadence


plt.plot(cadence)

