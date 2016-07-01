import pandas as pd
import scipy.stats
import statsmodels.formula.api as sm

# Read in our files.
train_features = pd.read_csv('train_features_2013-03-07.csv')
train_salaries = pd.read_csv('train_salaries_2013-03-07.csv')
test_data = pd.read_csv('test_features_2013-03-07.csv')

# Join train_{features, salaries} on jobId as primary key.
train_data = pd.merge(train_features, train_salaries, on='jobId', how='inner')

# In-place drop rows with any NaN value.
train_data.dropna(how='any', inplace=True)
test_data.dropna(how='any', inplace=True)

# Drop entries where salary = 0. Keep these in for now.
# train_data = train_data[train_data.salary != 0]

# Dictionary for mapping variable names to integers.
mapping = {}

# Assign integers for these (string) variables.
names = ['companyId', 'industry', 'major', 'jobType', 'degree']
for name in names:
    for i in enumerate(train_data[name].unique()):
        if name not in mapping.keys():
            mapping[name] = {i[1]: i[0]}
        else:
            mapping[name].update({i[1]: i[0]})
    train_data[name] = train_data[name].replace(mapping[name])
    test_data[name] = test_data[name].replace(mapping[name])

# Look at the Pearson correlation coefficient for each of the 7 non-salary
# variables with salary.
names = ['companyId', 'industry', 'major', 'jobType', 'degree',
         'yearsExperience', 'milesFromMetropolis']
for name in names:
    x = scipy.stats.pearsonr(train_data.salary, train_data[name])
    print(name, x[0])

# Create our linear model with the 5 variables with highest absolute value
# for correlation coefficient.
olsmod = sm.ols(formula="salary ~ yearsExperience + major +\
                degree + jobType + milesFromMetropolis", data=train_data)

# Fit the model.
olsres = olsmod.fit()

# Summary of results.
print(olsres.summary())

# This gives us the actual coefficients for the linear model.
print(olsres.params)

# Insert a column in train_data for our predicted values.
train_data['salary_predicted'] = pd.Series(olsres.predict()).astype(int)

# The mean of the difference of predicted and given salaries.
mean = (train_data.salary - train_data.salary_predicted).mean()
print('Mean = {0}'.format(mean))

# The std dev of the difference of predicted and given salaries.
std = (train_data.salary - train_data.salary_predicted).std()
print('Std dev = {0}'.format(std))

# Insert a column in test_data for our predicted salary values as ints.
test_data['salary'] = pd.Series(olsres.predict()).astype(int)

# Save our results to file.
header = ['jobId', 'salary']
test_data.to_csv('test_salaries.csv', columns=header)
