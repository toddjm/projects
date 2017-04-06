#!/usr/bin/env python
"""
Get data from Quandl.

Command line arguments:

--symbol : symbol
--exchange : Quandl-specific exchange name
--start : start year
--end : end year

"""

import argparse
import configobj
import os
import quandl

__author__ = "Todd Minehardt"
__email__ = "todd.minehardt@gmail.com"


def set_parser():
    """Return parser for command line arguments."""
    values = argparse.ArgumentParser(description='Read parameters.')
    values.add_argument('--symbol',
                        default='CL',
                        dest='symbol',
                        help='Symbol for security '
                             '(default: %(default)s)')
    values.add_argument('--exchange',
                        default='CME',
                        dest='exchange',
                        help='Quandl-specific exchange code '
                             '(default: %(default)s)')
    values.add_argument('--start',
                        default='1983',
                        dest='start',
                        help='Start year '
                             '(default: %(default)s)')
    values.add_argument('--end',
                        default='2025',
                        dest='end',
                        help='End year '
                             '(default: %(default)s)')
    return values

# Parse command line arguments.
parser = set_parser()
symbol = parser.parse_args().symbol
exchange = parser.parse_args().exchange
start = int(parser.parse_args().start)
end = int(parser.parse_args().end)

config = configobj.ConfigObj('/Users/tminehardt/.authtoken_Quandl')
authtoken = config['authtoken']

# For continuous data.
data = {}
for i in range(1, 50):
    name = symbol + str(i)
    contract = 'CHRIS/' + exchange + '_' + symbol + str(i)
    try:
        data[name] = quandl.get(contract, authtoken=authtoken)
    except:
        pass

# Write to disk.
outdir = os.path.join('futures', exchange, symbol, 'continuous')
if not os.path.exists(outdir):
    os.makedirs(outdir)
for i in data.keys():
    data[i].to_csv(os.path.join(outdir, i + '.csv'))

# For individual contracts.
data = {}
for i in range(start, end + 1):
    for j in ['F', 'G', 'H', 'J', 'K', 'M', 'N', 'Q', 'U', 'V', 'X', 'Z']:
        name = symbol + j + str(i)
        contract = exchange + '/' + symbol + j + str(i)
        try:
            data[name] = quandl.get(contract, authtoken=authtoken)
        except:
            pass

# Write to disk.
outdir = os.path.join('futures', exchange, symbol, 'individual')
if not os.path.exists(outdir):
    os.makedirs(outdir)
for i in data.keys():
    data[i].to_csv(os.path.join(outdir, i + '.csv'))
