## Getting and Cleaning Data. Course Project.

## Introduction

This project delivers a tidy data set given, as project's input, the data collected from the accelerometers from the Samsung Galaxy S smartphone.

A full description is available at the site where the data was obtained: 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The steps that the script performs for the creation of the data set required is described here.

### Check that the file system of the input data is in place.

```
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

### Read the input data into a table.

```
dir <- paste(dir, "UCI HAR Dataset", sep="")
#
Dat <- rbind(read.table(paste(dir, "/train/X_train.txt", sep=""), colClasses="numeric"),
             read.table(paste(dir, "/test/X_test.txt", sep=""), colClasses="numeric"))
#
```
#### Choose up features
We are interested in those with "mean()" or "std()" in their names.
```
features <- scan(paste(dir, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]

selcol <- grep("(mean|std)\\(\\)", features)

```
#### Convert features names to valid R names

make.names {base} can do it, but this is costumized.
```
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

#### Add two fixed variables columns: Subject and Measurement
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

#### Append Subject column

selcol is the index of columns with "mean()" or "std()" in their names.
"Fixed variables come first"

```
Dat <- cbind(as.data.frame(Subject), Dat[, selcol])
```

#### Append Measurement column

```
Dat <- cbind(as.data.frame(Measurement), Dat)
```
### These two are the datasets to be delivered.

#### D2 is the resulting 180x66 matrix of average for each activity and each subject.

```
D2 <- NULL 
```
#### D1 is the 10299x68 dataset partitioned by Measurement and each ordered by Subject.

```
D1 <- data.frame()
```

### Split by Measurement

```
dat <- split(Dat, Measurement)
```

### Programmatly access to the list of data.frames dat

```
rnames <- NULL # row names
for(measurement in measurements){
    D <- dat[[measurement]]
    D <- D[order(D[2]), ]  # order by Subject this Measurement
    D1 <- rbind(D1, D) # feeding up D1 with subsets of Measurement ordered by Subject.  
    for(subject in subjects){ # for each Subject in this Measurement calculate colMeans.
        tmp <- colMeans(D[D[2] == subject, 3:ncol(D)])
        names(tmp) <- NULL  ## !! important
        D2 <- rbind(D2, tmp) # feed up the matrix D2 with a new row
        # Collect row names
        rnames <- c(rnames, 
                    paste(measurement, # ex. produces "WALKING_UPSTAIRS.S_04"
                          ifelse(subject < 10, ".S_0", ".S_"),
                          subject,
                          sep=""))
    }    
}
```

### Assign names to columns and rows of D2

```
colnames(D2) <- colnames(D1)[3:ncol(D1)]
rownames(D2) <- rnames
```

