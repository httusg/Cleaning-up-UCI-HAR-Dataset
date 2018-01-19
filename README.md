## Cleaning up UCI HAR Dataset

### Load packages
Package **dplyr** provides helpful functions to manipulate data frames. 
```{r load-packages, message = FALSE}
library(dplyr)
```

### Load data

Make sure your data folders and R Markdown files are in the same directory.

```{r load-data}
subject_train <-read.table("./train/subject_train.txt")
X_train <-read.table("./train/X_train.txt")
y_train <-read.table("./train/y_train.txt")

subject_test <-read.table("./test/subject_test.txt")
X_test <-read.table("./test/X_test.txt")
y_test <-read.table("./test/y_test.txt")
```

* * *

### Cleaning data

**Step 1: Merges the training and the test sets to create one data set.**

```{r}
subject<-bind_rows(subject_train, subject_test)
X<-bind_rows(X_train, X_test)
y<-bind_rows(y_train, y_test)
```

**Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.**

The measurement variables are listed up in the file *features.txt*. The variables of the mean and standard deviation measurements have the terms *mean*,*Mean*, or *std* in the name. The indices of the variables in the file *features.txt* corresponds to the columns of the training dataset **X**, which need to be extracted.

```{r}
features <- read.table("./features.txt")
mlist <- features %>% filter(grepl("mean|Mean",V2))
slist <- features %>% filter(grepl("std",V2))
mean_measurements <- X %>% select(as.numeric(unlist(mlist$V1)))
std_measurements <- X %>% select(as.numeric(unlist(slist$V1)))
```

**Step 3: Uses descriptive activity names to name the activities in the data set.**

The activities are coded in the file *activity_labels.txt*. Adding a *description* column in the target dataset **y** makes it easier to read the data. The column name of the **subject** dataset should be changed to be meaningful also. 

```{r}
activity_labels <- read.table("./activity_labels.txt")
y <- y %>% mutate(V2=activity_labels$V2[V1])
colnames(y) = c("activity","description")
colnames(subject) = "subID"
```

**Step 4: Appropriately labels the data set with descriptive variable names.**

The variables names in the file *features.txt* contain un-descriptive characters like "-", "(", ")", which should be removed. The first character of a term should be capitalized, and duplicated terms "BodyBody" need to be shrinken as well. The column names of the extracted dataset in step two are replaced by the descriptive names.

```{r}
# make the names easier to read, and clean up un-descriptive characters
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
```

**Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.**

activity and subject are grouped together, and the average values of each group are calculated by the function **summarise_all**

```{r}
#subject (subject) - activity (y) - variables (mean_measurements, std_measurements)
activity <- y$activity
SubActMeas <- cbind(subject, activity, mean_measurements, std_measurements)
SubActAvg  <- SubActMeas %>% group_by(subID,activity) %>% summarise_all(mean)
```
