import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

# Read in train_{features, salaries} files.
train_features = pd.read_csv('train_features_2013-03-07.csv')
train_salaries = pd.read_csv('train_salaries_2013-03-07.csv')

# Join the features and salaries on jobId, inner join keeps
# entries with job ID in both files.
train_data = pd.merge(train_features, train_salaries, on='jobId',
                      how='inner')

# We know there are 5 entries where salary = 0, so let's get
# rid of them.
train_data = train_data[train_data.salary != 0]

# Get rid of rows with any null values.
train_data.dropna(how='any', inplace=True)

# Keep track of the mappings of names to integers.
mapping = {}
names = ['companyId', 'jobType', 'degree', 'major', 'industry']
for name in names:
    for i in enumerate(train_data[name].unique()):
        if name not in mapping.keys():
            mapping[name] = {i[1]: i[0]}
        else:
            mapping[name].update({i[1]: i[0]})
    # Replace name with integer.
    train_data[name] = train_data[name].replace(mapping[name])

# Look at correlation coefficients for each of the categories vs. salary.
names = ['companyId', 'industry', 'major', 'jobType', 'degree',
         'yearsExperience', 'milesFromMetropolis']
for name in names:
    x = scipy.stats.pearsonr(train_data.salary, train_data[name])
    print(name, x[0])

# Keep 
