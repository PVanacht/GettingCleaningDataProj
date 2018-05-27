## Getting and Cleaning Data Project

## You should create one R script called run_analysis.R that does the following.

## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names.
## 5. From the data set in step 4, creates a second, 
##    independent tidy data set with the average of each variable 
##    for each activity and each subject.

rm(list=ls())
library(dplyr)
library(reshape2)
library(tidyr)
library(data.table)

getwd()
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "C:/users/domin/Desktop/CourseraProjects/datafiles.zip")
unzip(zipfile = "datafiles.zip")

## import features and activity text files
UCI_Data_Activity_Labels <- as.data.table(read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE, col.names = c("Levels", "Activity")))
UCI_Data_Features <- as.data.table(read.table("UCI HAR Dataset/features.txt", header = FALSE, col.names = c("Levels", "Features")))
correct_features <- grep("(mean|std)\\(\\)", UCI_Data_Features[, Features])
measurements <- UCI_Data_Features[correct_features, Features]
measurements <- gsub('[()]', '', measurements)

## read in the training sets
training_set <- as.data.table(read.table("UCI HAR Dataset/train/X_train.txt"))
training_set1 <- training_set[, correct_features, with = FALSE]
colnames(training_set1) <- measurements

training_activities <- as.data.table(read.table("UCI HAR Dataset/train/Y_train.txt", header = FALSE, col.names = c("Activity")))
training_subjects <- as.data.table(read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE, col.names = c("Test_Subject")))

## create one tidy training dataset with all appropriate information
Training_End <- cbind(training_subjects, training_activities, training_set1)

## perform the same procedure, this time with the test datasets
testing_set <- as.data.table(read.table("UCI HAR Dataset/test/X_test.txt"))
testing_set1 <- testing_set[, correct_features, with = FALSE]
colnames(testing_set1) <- measurements

testing_activities <- as.data.table(read.table("UCI HAR Dataset/test/Y_test.txt", header = FALSE, col.names = c("Activity")))
testing_subjects <- as.data.table(read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE, col.names = c("Test_Subject")))

## create one tidy testing dataset with all appropriate information
Testing_End <- cbind(testing_subjects, testing_activities, testing_set1)

## merge both datasets
Combined_Data <- rbind(Training_End, Testing_End)
rm(testing_activities, training_activities, testing_set1, training_set1, testing_subjects, training_subjects)
str(Combined_Data)

## list <- c("Class", "Activity")
## factors <- names(Combined_Data) %in% list
## Combined_Data[, factors] <- lapply(Combined_Data[, factors], as.factor)

###
Combined_Data[["Activity"]] <- factor(Combined_Data[, Activity], 
                                      levels = UCI_Data_Activity_Labels[["Levels"]],
                                      labels = UCI_Data_Activity_Labels[["Activity"]])
Combined_Data[["Test_Subject"]] <- as.factor(Combined_Data[, Test_Subject])
str(Combined_Data)

Combined_Data <- melt(Combined_Data, id = c("Test_Subject", "Activity"))
Combined_Data_Tidy <- dcast(Combined_Data, Test_Subject + Activity ~ variable, fun.aggregate = mean)

write.table(Combined_Data_Tidy, 'CombinedTidyData.txt', row.names = FALSE)

