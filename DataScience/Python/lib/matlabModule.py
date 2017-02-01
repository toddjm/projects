import pandas as pd
import re
import scipy.io
"""
Functions for gathering data from Matlab-related files
and data structures.

"""

__author__ = "Todd Minehardt"


def getMatlabData(file_name):
    """Return a dictionary containing contents of a Matlab .mat file."""
    mat_file = scipy.io.matlab.loadmat(file_name)
    # Get rid of keys that begin with double underscores.
    for key in list(mat_file.keys()):
        if re.match('^__', key):
            del mat_file[key]
    data = {}
    for name in mat_file.keys():
        tmp_dict = {}
        tmp_data = mat_file[name]
        if tmp_data.dtype.names is not None:
            values_and_keys = list(enumerate(tmp_data.dtype.names))
            for i in values_and_keys:
                value, key = i[0], i[1]
                tmp_dict[key] = tmp_data[0, 0][value]
        data[name] = tmp_dict
    return data


class matlabData():
    """Given a dictionary, return class with attributes from keys.
    Instantiate as:

    matlabData((**entries)

    where entries is the dict returned by getMatlabData.

    """
    def __init__(self, **entries):
        self.__dict__.update(entries)
