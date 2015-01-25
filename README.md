- CleaningData

## How my script works

The below sequence of events are what occur throughout my script to get desired results. Said comments are available in actual R package with supporting code.

- I first load test and train set data files
- Then refactor above data frames into data frame table for analysis with dplyr
- remove previous data frames from memory
- add column to differentiate between data sets
- merge data sets together
- add foreign_key to combined data set
- load features.txt that contains names of variables in data set
- refactor features data frame into data fram table for analysis with dplyr
- remove features data frame from memory
- rename columns in features_tbl
- find indexes that have mean and standard deviation (std) in features_tbl
- placed in variable for use in loop
- loop through indexes from above
- load activity data for test and train
- refactor above data frames into data frame table for analysis with dplyr
- remove above data frames from memory
- add column to differentiate between data sets
- merge data sets together
-renaming columns in combined_labels
- load activity labels
- refactor above data frames into data frame table for analysis with dplyr
- remove above data frames from memory
- renaming columns in actvy_labels
- join combined_actv with actv_labels_tbl to get activity descriptions
- adding primary_key to new activity table
- join cmobined_set to new_actv_tbl to get activity description per observation
- extract necessary columns only from combined_set
- reshape combined_set into tall/slim shape by gathering feature (V..) columns
- do separate on feature columns
- extra ket column required because featuresKey above is type character
- and cannot be used in join with features_tbl index which is integer
- join combined_set to features_tbl to get features description
- reshape combined_set to display only relevant columns


############### NEW TIDY DATA SET ANALYSIS ####################

- group by feature descr, activity_description and person (subject) to derive averages
- utilize summarize function to perform average by attributes above

