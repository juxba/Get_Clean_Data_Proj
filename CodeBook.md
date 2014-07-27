## Getting and Cleaning Data
## Course Project Code Book

## Introduction
In this document is explained how the variables and data are manipulated
in order to obtain the required data sets.

The result will be two tidy data sets.

### Reading the data in a table
The data is collected from
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

This code snip read the files in a file system.
```
dir <- paste(getwd(), "/", sep="")
if (!file.exists(paste(dir, "UCI HAR Dataset", sep=""))) {
    sc <- scan("","It can take a while, continue Y/n? ")
    if(sc != "Y") stop("This terminates execution")
    
    tmp <- paste(dir, "tmp.zip", sep="")
    # Download file, unzip and remove the temporary file
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = tmp, method = "wget")
    unzip(tmp)
    file.remove(tmp)
}
```
Now there is a directory called "UCI HAR Dataset" with the file system in it.

The files are split in two directories "train" and "test".

They contain numeric data and the two concatenated form the total sampling of the experiment.
```
dir <- paste(dir, "UCI HAR Dataset", sep="")
#
Dat <- rbind(read.table(paste(dir, "/train/X_train.txt", sep=""), colClasses="numeric"),
             read.table(paste(dir, "/test/X_test.txt", sep=""), colClasses="numeric"))
#
```
### Read the features. They will be the variables names in the clean data set
```
features <- scan(paste(dir, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]
```
Only a subset of those is needed: the variables with "mean()" and "sdt()" in theirs names.

```
selcol <- grep("(mean|std)\\(\\)", features)
```

Besides, the variables names are converted to valid R names without loosing their original meaning.
```
# make.names {base} can do it, but this is costumized
names(Dat) <- sapply(features,
                     function(s){
                         s <- gsub("\\(\\)", "", s)
                         s <- gsub("-", "_", s)
                         s <- gsub(",", ".", s)
                         s <- gsub("\\(|\\)", ".", s)
                         s <- s # none of above
                         s
                     })
```

This is the result: 66 columns in the data set.

```
        features                    valid R names
        --------                    -------------
        tBodyAcc-mean()-X           tBodyAcc_mean_X
        tBodyAcc-mean()-Y           tBodyAcc_mean_Y
        tBodyAcc-mean()-Z           tBodyAcc_mean_Z
        tBodyAcc-std()-X            tBodyAcc_std_X
        tBodyAcc-std()-Y            tBodyAcc_std_Y
        tBodyAcc-std()-Z            tBodyAcc_std_Z
        tGravityAcc-mean()-X        tGravityAcc_mean_X
        tGravityAcc-mean()-Y        tGravityAcc_mean_Y
        tGravityAcc-mean()-Z        tGravityAcc_mean_Z
        tGravityAcc-std()-X         tGravityAcc_std_X
        tGravityAcc-std()-Y         tGravityAcc_std_Y
        tGravityAcc-std()-Z         tGravityAcc_std_Z
        tBodyAccJerk-mean()-X       tBodyAccJerk_mean_X
        tBodyAccJerk-mean()-Y       tBodyAccJerk_mean_Y
        tBodyAccJerk-mean()-Z       tBodyAccJerk_mean_Z
        tBodyAccJerk-std()-X        tBodyAccJerk_std_X
        tBodyAccJerk-std()-Y        tBodyAccJerk_std_Y
        tBodyAccJerk-std()-Z        tBodyAccJerk_std_Z
        tBodyGyro-mean()-X          tBodyGyro_mean_X
        tBodyGyro-mean()-Y          tBodyGyro_mean_Y
        tBodyGyro-mean()-Z          tBodyGyro_mean_Z
        tBodyGyro-std()-X           tBodyGyro_std_X
        tBodyGyro-std()-Y           tBodyGyro_std_Y
        tBodyGyro-std()-Z           tBodyGyro_std_Z
        tBodyGyroJerk-mean()-X      tBodyGyroJerk_mean_X
        tBodyGyroJerk-mean()-Y      tBodyGyroJerk_mean_Y
        tBodyGyroJerk-mean()-Z      tBodyGyroJerk_mean_Z
        tBodyGyroJerk-std()-X       tBodyGyroJerk_std_X
        tBodyGyroJerk-std()-Y       tBodyGyroJerk_std_Y
        tBodyGyroJerk-std()-Z       tBodyGyroJerk_std_Z
        tBodyAccMag-mean()          tBodyAccMag_mean
        tBodyAccMag-std()           tBodyAccMag_std
        tGravityAccMag-mean()       tGravityAccMag_mean
        tGravityAccMag-std()        tGravityAccMag_std
        tBodyAccJerkMag-mean()      tBodyAccJerkMag_mean
        tBodyAccJerkMag-std()       tBodyAccJerkMag_std
        tBodyGyroMag-mean()         tBodyGyroMag_mean
        tBodyGyroMag-std()          tBodyGyroMag_std
        tBodyGyroJerkMag-mean()     tBodyGyroJerkMag_mean
        tBodyGyroJerkMag-std()      tBodyGyroJerkMag_std
        fBodyAcc-mean()-X           fBodyAcc_mean_X
        fBodyAcc-mean()-Y           fBodyAcc_mean_Y
        fBodyAcc-mean()-Z           fBodyAcc_mean_Z
        fBodyAcc-std()-X            fBodyAcc_std_X
        fBodyAcc-std()-Y            fBodyAcc_std_Y
        fBodyAcc-std()-Z            fBodyAcc_std_Z
        fBodyAccJerk-mean()-X       fBodyAccJerk_mean_X
        fBodyAccJerk-mean()-Y       fBodyAccJerk_mean_Y
        fBodyAccJerk-mean()-Z       fBodyAccJerk_mean_Z
        fBodyAccJerk-std()-X        fBodyAccJerk_std_X
        fBodyAccJerk-std()-Y        fBodyAccJerk_std_Y
        fBodyAccJerk-std()-Z        fBodyAccJerk_std_Z
        fBodyGyro-mean()-X          fBodyGyro_mean_X
        fBodyGyro-mean()-Y          fBodyGyro_mean_Y
        fBodyGyro-mean()-Z          fBodyGyro_mean_Z
        fBodyGyro-std()-X           fBodyGyro_std_X
        fBodyGyro-std()-Y           fBodyGyro_std_Y
        fBodyGyro-std()-Z           fBodyGyro_std_Z
        fBodyAccMag-mean()          fBodyAccMag_mean
        fBodyAccMag-std()           fBodyAccMag_std
        fBodyBodyAccJerkMag-mean()  fBodyBodyAccJerkMag_mean
        fBodyBodyAccJerkMag-std()   fBodyBodyAccJerkMag_std
        fBodyBodyGyroMag-mean()     fBodyBodyGyroMag_mean
        fBodyBodyGyroMag-std()      fBodyBodyGyroMag_std
        fBodyBodyGyroJerkMag-mean() fBodyBodyGyroJerkMag_mean
        fBodyBodyGyroJerkMag-std()  fBodyBodyGyroJerkMag_std
```
### Add two fixed variables columns: Subject and Measurement
The subject performing the experiment and the type of measure taken.

Subject is a integer identifying the performer.

Measurement is a factor with levels read from the file system.

'subjects' and 'measurements' are convinience variables for looping purposes.

```
Subject <- as.integer(c(scan(paste(dir, "/train/subject_train.txt", sep="")),
                        scan(paste(dir, "/test/subject_test.txt", sep=""))))
Dat$Subject <- Subject
subjects <- 1:30
#
Measurement <- factor(c(scan(paste(dir, "/train/y_train.txt", sep="")),
                        scan(paste(dir, "/test/y_test.txt", sep=""))))
levels(Measurement) <- scan(paste(dir, "/activity_labels.txt", sep=""),
                            what="character")[c(FALSE, TRUE)]
Dat$Measurement <- Measurement
measurements <- levels(Measurement)
```
#### Append Subject column to the data set

selcol is the index of columns with "mean()" or "std()" in their names.

"Fixed variables come first"
```
Dat <- cbind(as.data.frame(Subject), Dat[, selcol])
```
#### Append Measurement column
```
Dat <- cbind(as.data.frame(Measurement), Dat)
```
### Split the data set by Measurement
This creates a list of data.frame that will be accessed programmaticly.

Then, reordering by Subject can be done without messing up the data set.
```
dat <- split(Dat, Measurement)
```
### These two are the datasets to be delivered
```
D1 <- data.frame()
```
D1 is the 10299x68 dataset1
partitioned by Measurement and each ordered by Subject.

```
D2 <- NULL
```
D2 is the resulting 180x66 matrix
of average for each activity and each subject.

### Programmaticly access to the list of data.frames
The loop does:

1. order current Measurement by Subject
2. feed up D1 with subsets of Measurement ordered by Subject
3. for each Subject in this Measurement calculate colMeans
4. collect row names for D2, ex. "WALKING_UPSTAIRS.S_04" 
5. feed up the matrix D2 with a new row

```
rnames <- NULL # row names
for(measurement in measurements){
    D <- dat[[measurement]]
    D <- D[order(D[2]), ]
    D1 <- rbind(D1, D)  
    for(subject in subjects){
        tmp <- colMeans(D[D[2] == subject, 3:ncol(D)])
        names(tmp) <- NULL  ## !! important
        D2 <- rbind(D2, tmp)
        # Collect row names
        rnames <- c(rnames, 
                    paste(measurement,
                          ifelse(subject < 10, ".S_0", ".S_"),
                          subject,
                          sep=""))
    }    
}
```
### Assign names to rows and colomns to the resulting data set D2
Measurement and Subject variables are not needed because they are implicitly stated in the row names of the matrix D2.

```
colnames(D2) <- colnames(D1)[3:ncol(D1)]
rownames(D2) <- rnames
```

## Final
The two tidy data sets are ready for delivery.

D1 is a data.frame and D2 is a matrix.

This will be send to Coursera

```
write.table(D2, "D2_dataset.txt", sep =" ")
```
