import assessmentModule as amod
import datetime as dt
import json
import re
import sys
"""
Script for downloading a BSXCSV file and process to an
oxy file format.

"""

__author__ = "Todd Minehardt"


# Pass in assessment ID from on line.
assessment_id = sys.argv[1]

# Pull the assessment JSON data from production.
assessment_data = amod.getAssessmentData(assessment_id)

# Get BSXCSV file from production.
bsxcsv_file = amod.getFileFromJSON(assessment_data, 'bsxcsv')

# Decode for manipulation.
data_decoded = bsxcsv_file.content.decode()

# Split on newline to get a list.
list_split_on_newline = data_decoded.split('\n')

# Get flash schema.
flash_schema = list_split_on_newline[1].split(',')[0]

# Get sampling rate (Hz).
sampling_rate = list_split_on_newline[1].split(',')[1]

# Get IMU sampling rate (Hz).
IMU_sampling_rate = list_split_on_newline[1].split(',')[2]

# Get session_type.
session_type = list_split_on_newline[1].split(',')[6]
if session_type == '2':
    sport_type = 'bike'
elif session_type == '1':
    sport_type = 'run'
else:
    sport_type = 'unknown'

# Get fw_revision.
fw_revision = list_split_on_newline[1].split(',')[7]

# Get device ID.
device_id = list_split_on_newline[1].split(',')[4]
device_id = device_id.replace('-', '')

# Column names for assessment.
column_names = list_split_on_newline[2].split(',')

# Pull every 6th row from the data, starting with the 7th record.
data = list_split_on_newline[7::6]

# Pull the date of the assessment.
assessment_date = list_split_on_newline[1].split(',')[3]

# Get a datetime object. Returns start date and time to the second.
assessment_date = dt.datetime.strptime(assessment_date, "%Y/%m/%d %H:%M:%S")

# Create an array of timestamps, with the fist one being start_ts.
timestamps = []
start_ts = int(dt.datetime.timestamp(assessment_date) * 1000)
timestamps.append(start_ts)
time_delta = 200  # Time in milliseconds.

for i in range(len(data)-1):
    new_ts = dt.datetime.timestamp(assessment_date +
                                   dt.timedelta(milliseconds=time_delta))
    new_ts = int(new_ts * 1000)
    timestamps.append(new_ts)
    time_delta += 200

# Extract heart rate.
heart_rate = []
for line in data:
    heart_rate.append(int(line.split(',')[32]))

# Extract power/pace.
power_or_pace = []
for line in data:
    power_or_pace.append(float(line.split(',')[33]))

# Extract cHhb_15.
cHhb_15 = []
for line in data:
    cHhb_15.append(float(line.split(',')[34]))

# Extract cHbO2_15.
cHbO2_15 = []
for line in data:
    cHbO2_15.append(float(line.split(',')[35]))

# Extract cHhb_27.
cHhb_27 = []
for line in data:
    cHhb_27.append(float(line.split(',')[36]))

# Extract cHbO2_27.
cHbO2_27 = []
for line in data:
    cHbO2_27.append(float(line.split(',')[37]))

# Extract SmO2, represent as percentage.
SmO2 = []
for line in data:
    SmO2.append(float(line.split(',')[38]) / 100.0)

# Extract alert bits.
alert_bits = []
for line in data:
    alert_bits.append(int(line.split(',')[41]))

# Extract SDS speed (m/s).
SDS_speed = []
for line in data:
    SDS_speed.append(float(line.split(',')[42]))

# Extract SDS cadence (spm).
SDS_cadence = []
for line in data:
    SDS_cadence.append(float(line.split(',')[43]))

# Extract pace from IMU.
pace_from_IMU = []
pattern_0 = ',,,,,,,,,,,,,,,,,,,,,,,,,'
pattern_1 = ',,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,'
for line in list_split_on_newline:
    if re.match(pattern_0, line) and not re.fullmatch(pattern_1, line):
        element = line.split(',')[29]
        if len(element) != 0:
            pace_from_IMU.append(float(element))
        else:
            pace_from_IMU.append(repr(None))
pace_from_IMU = pace_from_IMU[1::4]

# Pace info without gyro.
length = len(timestamps)
pace_without_gyro = [None] * length

# Construct a list of lists, each containing per-timestamp information.
contents = []
for i in range(len(timestamps)):
    fld_0 = cHbO2_15[i]
    fld_1 = cHhb_15[i]
    fld_2 = cHbO2_27[i]
    fld_3 = cHhb_27[i]
    fld_4 = heart_rate[i]
    fld_5 = power_or_pace[i]
    fld_6 = timestamps[i]
    fld_7 = SmO2[i]
    fld_8 = alert_bits[i]
    fld_9 = pace_from_IMU[i]
    fld_10 = pace_without_gyro[i]
    data_list = [fld_0, fld_1, fld_2, fld_3, fld_4,
                 fld_5, fld_6, fld_7, fld_8, fld_9, fld_10]
    contents.append(data_list)

# Build a dictionary to serialize an assessment.
assessment = {}
assessment['error'] = {}
assessment['meta'] = {}
assessment['result'] = {}
assessment['result']['content'] = contents
assessment['result']['device'] = {'model': 'iPad2,5',
                                  'os': 'iOS 9.2'}
assessment['result']['header'] = {'Device_id': device_id,
                                  'FW_version': fw_revision,
                                  'Schema_version': '1.0.0',
                                  'app_version_code': '2.0.2.2',
                                  'app_version_name': '2.0.2',
                                  'ble_issued_start_time_ant': 999999999,
                                  'ble_issued_start_time_ant_tz': -24,
                                  'ble_issued_start_time_utc': start_ts,
                                  'sample_rate': '2Hz',
                                  'sport': sport_type}
assessment['result']['profile'] = {'days_per_week': 6,
                                   'distance_per_week': 100,
                                   'gender': 'male',
                                   'height': 170.0,
                                   'months_training': 12,
                                   'weight': 72.0}
assessment['result']['protocol'] = {'anticipated_stage': 8,
                                    'anticipated_stage_range': 1,
                                    'calibration_period': [[180, 60]],
                                    'optional': [],
                                    'stages': [[180, 80],
                                               [180, 100],
                                               [180, 120],
                                               [180, 140],
                                               [180, 160],
                                               [180, 180],
                                               [180, 200],
                                               [180, 220],
                                               [180, 240],
                                               [180, 260],
                                               [180, 280],
                                               [180, 300],
                                               [180, 320],
                                               [180, 340],
                                               [180, 360],
                                               [180, 380],
                                               [180, 400],
                                               [180, 420],
                                               [180, 440],
                                               [180, 460]]}


output = json.dumps(assessment)
