import assessmentModule as amod
import base64
import numpy as np
import sys
"""
Script for getting data from a device file.

"""

__author__ = "Todd Minehardt"


# Pass in device ID on command line.
device_id = sys.argv[1]

# Pull the device calibration records (JSON).
device_data = amod.getDeviceCalibrationRecords(device_id)

# Pull the device checkouts from the device_data JSON file.
device_checkouts = amod.getDeviceCheckoutsFromJSON(device_data)

# Instantiate deviceCheckout() in order to access attributes.
device_info = amod.deviceCheckout(**device_checkouts)

# The attribute 'calibration_file' is decoded from base64 to
# a byte string (length 216). We take the last 200 bytes
# and cast as float32 array of dimension (25, 8).
calibration_file = device_info.calibration_file
all_count_decoded = base64.b64decode(calibration_file)[64:]
all_count = np.fromstring(all_count_decoded, dtype='float32')
all_count = np.reshape(all_count, (25, 8))

# The first 16 bytes of 'calibration_file' contain the 16 elements
# of the inverse matrix, which in turn are the dimension (2, 4)
# arrays inv_C15 and inv_C27.
inverse_matrix_decoded = base64.b64decode(calibration_file)[:64]
inverse_matrix = np.fromstring(inverse_matrix_decoded, dtype='float32')
inv_C15 = np.reshape(inverse_matrix[:8], (2, 4))
inv_C27 = np.reshape(inverse_matrix[8:16], (2, 4))

print(all_count)
print()
print(inv_C15)
print()
print(inv_C27)
