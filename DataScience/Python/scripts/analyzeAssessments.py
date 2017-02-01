import assessmentModule as amod
import sys
"""
Script for getting oxy data and putting it to
the sandbox user account.

"""

__author__ = "Todd Minehardt"


# Pass in assessment ID on command line.
assessment_id = sys.argv[1]

# Pull the assessment JSON data from production.
assessment_data = amod.getAssessmentData(assessment_id)

# Get oxy file from URL linked in JSON data.
oxy_file = amod.getOxyFileFromJSON(assessment_data)

# Write the assessment oxy data to disk.
amod.writeOxyFileToDisk(assessment_id, oxy_file)

# Get an authentication token for sandbox user.
sandbox_token = amod.getSandboxUserToken()

# Determine which sport is being assessed.
sport = amod.getSportTypeFromJSON(assessment_data)

# Construct dictionary appropriate for sport in assessment.
data_dict = amod.createDataDictForUpload(assessment_data, sport)

# Get a new assessment ID for current assessment.
new_assessment_id = amod.getNewAssessmentID(data_dict, sandbox_token)

# Push the assessment to sandbox with new assessment ID.
amod.putDataToSandbox(new_assessment_id, assessment_id, sandbox_token)

# Get a pandas DataFrame object for summary data.
df = amod.getDataFrameFromOxyFile(oxy_file)

# Print summary data to screen.
amod.summarizeData(df, assessment_data, sport)
