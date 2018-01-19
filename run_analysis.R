####################################################################
#1.Merges the training and the test sets to create one data set.
####################################################################
library(dplyr)

# import dataset
subject_train <-read.table("./train/subject_train.txt")
X_train <-read.table("./train/X_train.txt")
y_train <-read.table("./train/y_train.txt")

subject_test <-read.table("./test/subject_test.txt")
X_test <-read.table("./test/X_test.txt")
y_test <-read.table("./test/y_test.txt")

# bind multiple data frames by row and column
subject<-bind_rows(subject_train, subject_test)
X<-bind_rows(X_train, X_test)
y<-bind_rows(y_train, y_test)

####################################################################
#2.Extracts only the measurements on the mean and standard deviation for each measurement.
####################################################################
features <- read.table("./features.txt")
mlist <- features %>% filter(grepl("mean|Mean",V2))
slist <- features %>% filter(grepl("std",V2))
mean_measurements <- X %>% select(as.numeric(unlist(mlist$V1)))
std_measurements <- X %>% select(as.numeric(unlist(slist$V1)))

####################################################################
#3.Uses descriptive activity names to name the activities in the data set
####################################################################
activity_labels <- read.table("./activity_labels.txt")
y <- y %>% mutate(V2=activity_labels$V2[V1])
colnames(y) = c("activity","description")
colnames(subject) = "subID"

####################################################################
#4.Appropriately labels the data set with descriptive variable names.
####################################################################
# make the names easier to read, and clean up un-descriptive characters in the names
mlist_clean <- sub("mean","Mean",mlist$V2)
mlist_clean <- sub("gravity","Gravity",mlist_clean)
mlist_clean <- sub("BodyBody","Body",mlist_clean)
mlist_clean <- sub("\\()","",mlist_clean)
mlist_clean <- gsub("-","",mlist_clean)
mlist_clean <- strsplit(mlist_clean,"\\(|\\)|,")
mlist_clean <- sapply(mlist_clean, function(ss) paste(ss,collapse=''))

slist_clean <- sub("std","Std",slist$V2)
slist_clean <- sub("BodyBody","Body",slist_clean)
slist_clean <- sub("\\()","",slist_clean)
slist_clean <- gsub("-","",slist_clean)

# rename column names
colnames(mean_measurements) = mlist_clean
colnames(std_measurements)  = slist_clean

####################################################################
#5.From the data set in step 4, creates a second, independent tidy data set
#  with the average of each variable for each activity and each subject.
#
# subject (subject) - activity (y) - var (mean_measurements, std_measurements)
####################################################################
activity <- y$activity
SubActMeas <- cbind(subject, activity, mean_measurements, std_measurements)
SubActAvg  <- SubActMeas %>% group_by(subID,activity) %>% summarise_all(mean)
