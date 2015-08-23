
#You should create one R script called run_analysis.R that does the following. 
# 1 Merges the training and the test sets to create one data set.

file1 <- "UCI HAR Dataset/train/X_train.txt"
file2 <- "UCI HAR Dataset/train/y_train.txt"
file3 <- "UCI HAR Dataset/train/subject_train.txt"

file4 <- "UCI HAR Dataset/test/X_test.txt"
file5 <- "UCI HAR Dataset/test/y_test.txt"
file6 <- "UCI HAR Dataset/test/subject_test.txt"

## read X_train.txt - the features data from each window
xtrain <- read.table(file1 ,header = FALSE,fill = TRUE, 
                     col.names = paste("f", 1:561))

## read y_train.txt - the activity label for each window
ytrain <- read.table(file2)

## read subject_train.txt - person who provided the data
sub_train <- read.table(file3)

## read similar files on test dataset
xtest <- read.table(file4 ,header = FALSE,fill = TRUE, 
                     col.names = paste("f", 1:561))
ytest <- read.table(file5)
sub_test <- read.table(file6)

## combine subject, activity and features data
test_data <- cbind(sub_test,ytest,xtest)
dim(test_data)
rm(list = c("xtest", "ytest", "sub_test"))
ls()

train_data <- cbind(sub_train,ytrain,xtrain)
dim(train_data)
rm(list = c("xtrain", "ytrain", "sub_train"))
ls()


names(test_data[1:5])
names(train_data[1:5])

## combine test and training data using row bind
data <- rbind(test_data,train_data)
names(data)[1:2] <- c("person","activity")
names(data)[1:2]

## add test/training dataset identifier
dataset <- c(rep(1,2947),rep(2,7352))
str(dataset)
data <- cbind(dataset,data)
names(data)[1:2]

#4 Appropriately labels the data set with descriptive variable names. 
## use names of features to column names

file7 <- "UCI HAR Dataset/features.txt"
fname <- read.table(file7 ,header = FALSE,fill = TRUE, 
                    stringsAsFactors = FALSE, col.names = c("clm", "fnames"))
str(fname)

names(data)[4:564] <- fname[,2]

names(data)[1:6]

#2 Extracts only the measurements on the mean and standard deviation for each measurement. 
## read column indices to be extracted
extract <- read.table("extract-meanstd.txt")
extract <- extract + 3
head(extract)

data <- data[,c(1:3,extract[,1])]
names(data)[1:10]

# convert table to data frame
data <- as.data.frame(data)
str(data)

#3 Uses descriptive activity names to name the activities in the data set
## assigne labels to activity and data set type
data$activity <- factor(data$activity,
                        labels=c("WALKING",
                                 "WALKING_UPSTAIRS",
                                 "WALKING_DOWNSTAIRS",
                                 "SITTING",
                                 "STANDING",
                                 "LAYING"))
str(data$activity)                                               

data$dataset <- factor(data$dataset, labels = c("test","training"))
str(data$dataset)
table(data$dataset)
table(data$activity)
table(data$person)

table(data$person,data$activity)



#5 From the data set in step 4, creates a second, 
#  independent tidy data set with the average of each variable 
#  for each activity and each person.

library(reshape2)
## remove test/training identifier
data <- data[,-1]
long <- melt(data,id=c("person","activity"),na.rm = TRUE)
head(long,n=5)

tidydata <- dcast(long,person+activity~variable,mean)

## update column names to clarify that they are means
names(tidydata)[3:68]<-paste("mean_",names(tidydata)[3:68])

## write tidydata in text format for uploading
write.table(tidydata,file="tidydata_upload.txt",row.names=FALSE)
