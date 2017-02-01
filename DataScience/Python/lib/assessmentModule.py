"""
Functions for gathering data for assessments.

"""

import os
import pandas as pd
import requests
import tempfile

__author__ = "Todd Minehardt"


def convert_ms_to_pace(speed):
    """Given speed in m/s, return pace in minutes per mile."""
    min_mile = 26.8224 / speed
    minutes = int(min_mile)
    seconds = round(60 * (min_mile - minutes))
    return str(minutes) + ':' + str(seconds).zfill(2)


def createDataDictForUpload(data, activity):
    """Return dictionary for sport activity in assessment data."""
    data_dict = {}
    if activity == 'run':
        data_dict['conversational_speed'] = 1.5
        data_dict['race_speed'] = 3.0
    else:
        data_dict['conversational_power'] = 100.0
        data_dict['race_power'] = 300.0
    data_dict['sport'] = activity
    return data_dict


def getAccessToken():
    """Return the authorization token for getting assessments."""
    r = requests.post('https://api.bsxinsight.com/access-token',
                      data={'client_id': 'WEf7lFXcARobgUqG',
                      'client_secret': 'mV1YoPTAFyWibtu0O5pOQQKPHkAq2ITv',
                      'grant_type': 'client_credentials',
                      'scope': 'matlab'})
    access_token = r.json()['access_token']
    return access_token


def getActivity(activity_id):
    """Return an activity given an activity ID."""
    global access_token
    try:
        return requests.get('https://api.bsxinsight.com/getactivity/' +
                            activity_id,
                            headers={'Authorization': access_token})
    except:
        access_token = getAccessToken()
        return requests.get('https://api.bsxinsight.com/getactivity/' +
                            activity_id,
                            headers={'Authorization': access_token})


def getAssessmentData(assessment_id):
    """Return the JSON file for an assessment."""
    global access_token
    try:
        return requests.get('https://api.bsxinsight.com/v2/getassessment/' +
                            assessment_id,
                            headers={'Authorization': access_token})
    except:
        access_token = getAccessToken()
        return requests.get('https://api.bsxinsight.com/v2/getassessment/' +
                            assessment_id,
                            headers={'Authorization': access_token})


def getDataFrameFromActivity(activity_id):
    """Return a pandas dataframe object containing activity data."""
    r = getActivity(activity_id)
    f = getFileFromJSON(r, 'fitcsv')
    x = f.content.decode().split('\n')[6:]
    r.close()
    columns = ['ts', 'HR', 'SmO2', 'power']
    data = []
    for i in range(len(x)-1):
        y = x[i].split(',')
        data.append([y[4], y[7], y[10], y[13]])
    return pd.DataFrame(data, columns=columns)


def getDataFrameFromOxyFile(oxy_file):
    """Return pandas DataFrame object from oxy file."""
    df = pd.DataFrame(oxy_file.json()['result']['content'][1:],
                      columns=None)
    return df


def getDevAccessToken():
    """Return the authorization token for development server."""
    r = requests.post('http://devapi.bsxinsight.com/access-token',
                      data={'client_id': 'WEf7lFXcARobgUqG',
                      'client_secret': 'mV1YoPTAFyWibtu0O5pOQQKPHkAq2ITv',
                      'grant_type': 'client_credentials',
                      'scope': 'matlab'})
    access_token = r.json()['access_token']
    return access_token


def getDeviceCalibrationRecords(device_id):
    """Return calibration records (JSON) given a device ID."""
    global access_token
    try:
        return requests.get('https://api.bsxinsight.com/devices/' +
                            device_id,
                            headers={'Authorization': access_token})
    except:
        access_token = getAccessToken()
        return requests.get('https://api.bsxinsight.com/devices/' +
                            device_id,
                            headers={'Authorization': access_token})


def getDeviceCheckoutsFromJSON(json_data):
    """Return dictionary of items from 'checkouts'
    given a JSON file as returned by getDeviceCalibrationRecords.
    """
    try:
        checkout_dict = {}
        checkouts = json_data.json()['checkouts'][0]
        checkout_keys = checkouts.keys()
        for key in checkout_keys:
            checkout_dict[key] = checkouts[key]
        return checkout_dict
    except:
        print("Checkouts not found.")


def getDeviceIDFromOxyFile(oxy_file):
    """Return device hardware ID from oxy file."""
    return oxy_file.json()['result']['header']['Device_id']


def getExcludedAssessmentList():
    """Return list of excluded assessments."""
    ex_file = '/Users/todd/code/AnalysisTools/Python/config/exclude_assessments.txt'
    with open(ex_file, 'r') as fn:
        exclude_list = []
        for line in fn:
            exclude_list.append(line)
    exclude_list = [i.strip('\n') for i in exclude_list]
    return exclude_list


def getFileFromJSON(json_data, data_type):
    """Return file from link in JSON data."""
    try:
        data_file = requests.get(json_data.json()['links'][data_type])
        return data_file
    except:
        print("Could not get {0} file. Check URL.".format(data_type))


def getNewAssessmentID(data_dict, sandbox_token):
    """Return new assessment ID for sandbox user."""
    try:
        r = requests.post('https://api.bsxinsight.com/assessments',
                          data=data_dict,
                          headers={'Authorization': sandbox_token})
        return r.headers['Location'].split('/')[-1]
    except:
        print("Unable to get new assessment ID headers.")


def getOxyFileFromJSON(json_data):
    return getFileFromJSON(json_data, 'oxy')


def getSandboxUserToken():
    """Return authentication token for sandbox user."""
    try:
        r = requests.post('https://api.bsxinsight.com/access-token',
                          data={'client_id': 'StUFunuGequq6M3c',
                          'client_secret': '85aXa4ErERaPREpuve6Aden8C4eN2Gut',
                          'grant_type': 'password',
                          'scope': 'private',
                          'username': 'todd@bsxathletics.com',
                          'password': 'bsxbsx'})
        return r.json()['access_token']
    except:
        print("Could not get sandbox user authentication token.")


def getSportTypeFromJSON(data):
    """Return sport type from JSON data."""
    try:
        return data.json()['sport']
    except:
        print("Could not get sport from JSON data.")


def getUserProfileDataFromJSON(json_data):
    """
    Return conversational speed and race speed for 'run'
    and conversational power and race power for 'bike'.
    """
    if json_data.json()['sport'] == 'run':
        return [json_data.json()['conversational_speed'],
                json_data.json()['race_speed']]
    elif json_data.json()['sport'] == 'bike':
        return [json_data.json()['conversational_power'],
                json_data.json()['race_power']]
    else:
        return


def putDataToSandbox(new_assessment_id, assessment_id, sandbox_token):
    """Read oxy file from disk, write to sandbox account."""
    temp_dir = tempfile.gettempdir()
    data_file = os.path.join(temp_dir, assessment_id + '.dat')
    try:
        files = {'oxy_data': open(data_file, 'rb')}
        r = requests.put('https://api.bsxinsight.com/assessments/' +
                         new_assessment_id,
                         files=files,
                         headers={'Authorization': sandbox_token})
    except:
        print("Local oxy data file not found or not readable.")
    return r.status_code


def summarizeData(df, json_data, activity):
    """Return summary of dataframe object."""
    if len(df.columns) != 11:
        print("Could not parse activity for summary. Exiting.")
        return None
    # Populate a dict with column names.
    column_names = {0: 'cHhb_15',
                    1: 'cHbO2_15',
                    2: 'cHhb_27',
                    3: 'cHbO2_27',
                    4: 'HR',
                    6: 'time',
                    7: 'SmO2',
                    8: 'alert_bits',
                    9: 'pace_from_IMU',
                    10: 'pace_without_gyro'}
    if activity == 'run':
        column_names[5] = 'pace'
    else:
        column_names[5] = 'power'
    print()
    print("Length of dataset: {0}".format(len(df)))
    print()
    print("Activity type: {0}".format(activity))
    print()
    # Get a list of profile metrics.
    metrics = getUserProfileDataFromJSON(json_data)
    if activity == 'run':
        conv_spd = float(metrics[0])
        race_spd = float(metrics[1])
        conv_pace = convert_ms_to_pace(conv_spd)
        race_pace = convert_ms_to_pace(race_spd)
        print("Conversational Speed = {0:.2f} m/s".format(conv_spd))
        print("Conversational Pace = {0} min:mile".format(conv_pace))
        print("Race Speed = {0:.2f} m/s".format(race_spd))
        print("Race Pace = {0} min:mile".format(race_pace))
    elif activity == 'bike':
        print("Conversational Power = {0} W".format(metrics[0]))
        print("Race Power = {0} W".format(metrics[1]))
    print()
    for col in df.columns:
        col_name = column_names[col]
        nulls = df[col].isnull().sum()
        print("[{0}] Number of missing values: {1}".format(col_name, nulls))
    print()
    return


def writeOxyFileToDisk(assessment_id, data):
    """Write content of oxy file to disk."""
    temp_dir = tempfile.gettempdir()
    file_name = os.path.join(temp_dir, assessment_id + '.dat')
    with open(file_name, 'wb') as f:
        f.write(data.content)
    return


class deviceCheckout():
    """Given a dictionary of checkouts, return class with
    attributes from keys.
    Instantiate as:

    deviceCheckout(**entries)

    where entries is the dict returned by getDeviceCheckoutsFromJSON.
    Attributes will include:

    block
    calibration_file
    created_at
    current_sweep
    device_id
    diagnostic_file
    firmware
    led_lot
    lookup_current
    operator_id
    station
    status
    updated_at

    """
    def __init__(self, **entries):
        self.__dict__.update(entries)
