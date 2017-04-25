library(reshape2)

filename <- "getdata_projectfiles_UCI HAR Dataset.zip"

##Download data if not yet present.

if (!file.exists(filename)){
  fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, filename, method="curl")
}

if (!file.exists("getdata_projectfiles_UCI HAR Dataset")){
  unzip(filename)
}

##Change working directory.

setwd("getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset")

##Get the activity and feature labels.

activity_labels <- read.table("activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("features.txt")
features[,2] <- as.character(features[,2])

##Select the features for mean and std values, simplify their names.

selected_features <- grep(".*mean.*|.*std.*", features[,2])
selected_feature_names <- features[selected_features, 2]
selected_feature_names = gsub('-mean', 'Mean', selected_feature_names)
selected_feature_names = gsub('-std', 'Std', selected_feature_names)
selected_feature_names <- gsub('[-()]', '', selected_feature_names)

##Read the training data in one data frame.

train_measurements <- read.table("train/X_train.txt")[selected_features]
train_activities <- read.table("train/y_train.txt")
train_subjects <- read.table("train/subject_train.txt")
train_set <- cbind(train_subjects, train_activities, train_measurements)

##Read the test data in one data frame.

test_measurements <- read.table("test/X_test.txt")[selected_features]
test_activities <- read.table("test/y_test.txt")
test_subjects <- read.table("test/subject_test.txt")
test_set <- cbind(test_subjects, test_activities, test_measurements)

##Combine training and test data, simplify it.

all <- rbind(train_set, test_set)
colnames(all) <- c("subject", "activity", selected_feature_names)

all$activity <- factor(all$activity, levels=activity_labels[,1], labels=activity_labels[,2])
all$subject <- factor(all$subject)

all_melted <- melt(all, id = c("subject", "activity"))
all_mean <- dcast(all_melted, subject + activity ~ variable, mean)

##Save the data.

setwd("../..")
write.table(all_mean, "tidy.txt", row.names = FALSE, quote = FALSE)