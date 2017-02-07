# Coursera-CleaningData-Project
Code and documentation for the Project for the Coursera JHU 'Getting and Cleaning Data' course

Script pulls in two sets of data - test and training data for measurements of accelerometer readings when people undertake different standardised activities,

Adds key data for these files from separaet raw data files,

then cleans the data slightly

and summarizes by taking means of key measurement values, by Subject (person) and Activity

output is written to a text file

Text (output) contains:

1 header line, with field names

180 data lines, one for each person-activity combination (30 subjects x 6 activities)

each data line has SUbject (key), Activity (description) and mean value of 79 selected measurments for this Subject-Activity

header row describes the measurements
