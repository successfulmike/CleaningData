# load test and train set data files

test_set <- read.table(file="./UCI Har Dataset/test/X_test.txt", comment.char="")
train_set <- read.table(file="./UCI Har Dataset/train/X_train.txt", comment.char="")
                       
# refactor above data frames into data frame table for analysis with dplyr
test_set_tbl <- tbl_df(test_set)
train_set_tbl <- tbl_df(train_set)

# remove previous data frames from memory
rm(test_set)
rm(train_set)

# add column to differentiate between data sets
test_set_tbl <- test_set_tbl %>% mutate(data_category = "test")
train_set_tbl <- train_set_tbl %>% mutate(data_category = "train")

# merge data sets together
combined_set <- rbind_list(test_set_tbl, train_set_tbl)

# adding foreign_key to combined data set
combined_set <- combined_set %>% mutate(activity_foreignKey = row_number())

# load features.txt that contains names of variables in data set
features <- read.table(file="./UCI Har Dataset/features.txt", comment.char="", stringsAsFactors = TRUE)

# refactor features data frame into data fram table for analysis with dplyr
features_tbl <- tbl_df(features)

# remove features data frame from memory
rm(features)

# renaming columns in features_tbl
features_tbl <- features_tbl %>% select(index = V1, feature_descr = V2)

# find indexes that have mean and standard deviation (std) in features_tbl
# placed in variable for use in loop
mean.std.idx <- features_tbl %>% filter(grepl("mean|std", feature_descr)) %>% select(index)

# loop through indexes from above
for (x in seq_along(as.vector(t(mean.std.idx)))) {
    #     print(as.vector(t(mean.std.idx))[x]) ## testing right index returned
    # retrieve & print feature name for equivalent mean/std index
    filter(features_tbl, index == x) %>% select(feature_descr) %>% print
    # retrieve & print data set for equivalent mean/std index
    select(combined_set,as.vector(t(mean.std.idx))[x]) %>% print
}

# load activity data for test and train
test_actv <- read.table(file="./UCI Har Dataset/test/Y_test.txt", comment.char="")
train_actv <- read.table(file="./UCI Har Dataset/train/Y_train.txt", comment.char="")

# refactor above data frames into data frame table for analysis with dplyr
test_actv_tbl <- tbl_df(test_actv)
train_actv_tbl <- tbl_df(train_actv)

# remove above data frames from memory
rm(list = c("test_actv","train_actv"))

# add column to differentiate between data sets
test_actv_tbl <- test_actv_tbl %>% mutate(data_category = "test")
train_actv_tbl <- train_actv_tbl %>% mutate(data_category = "train")

# merge data sets together
combined_actv <- rbind_list(test_actv_tbl, train_actv_tbl)

#renaming columns in combined_labels
combined_actv <- combined_actv %>% rename(activity_key = V1)

# load activity labels
actv_labels <- read.table(file="./UCI Har Dataset/activity_labels.txt", comment.char="")

# refactor above data frames into data frame table for analysis with dplyr
actv_labels_tbl <- tbl_df(actv_labels)

# remove above data frames from memory
rm(actv_labels)

# renaming columns in actvy_labels
actv_labels_tbl <- actv_labels_tbl %>% rename(activity_key = V1, activity_description = V2)

# join combined_actv with actv_labels_tbl to get activity descriptions
new_actv_tbl <- left_join(combined_actv,actv_labels_tbl, by=c("activity_key" = "activity_key"))

# adding primary_key to new activity table
new_actv_tbl <- new_actv_tbl %>% mutate(activity_primaryKey = row_number())

# join cmobined_set to new_actv_tbl to get activity description per observation
combined_set <- combined_set %>% left_join(new_actv_tbl, by=c("activity_foreignKey" = "activity_primaryKey"))

# extract necessary columns only from combined_set
combined_set <- combined_set %>% select(subject = activity_foreignKey, activity_description, data_category.x, V1:V561)

# reshape combined_set into tall/slim shape by gathering feature (V..) columns
combined_set <- combined_set %>% gather(feature,measurement,-subject,-activity_description,-data_category.x)

# do separate on feature columns
combined_set <- combined_set %>% separate(feature, c("features","featuresKey"),1)

# extra ket column required because featuresKey above is type character
# and cannot be used in join with features_tbl index which is integer
combined_set <- combined_set %>% mutate(featureIDX = row_number())

# join combined_set to features_tbl to get features description
combined_set <- combined_set %>% left_join(features_tbl, by=c("featureIDX" = "index"))

# reshape combined_set to display only relevant columns
combined_set <- combined_set %>% select(subject:activity_description,feature_descr,measurement)

################ NEW TIDY DATA SET ANALYSIS ####################

# group by feature descr, activity_description and person (subject) to derive averages
tidy_set <- group_by(combined_set, feature_descr, activity_description, subject)

# utilize summarize function to perform average by attributes above
tidy_set <- tidy_set %>% summarize(mean(measurement))
