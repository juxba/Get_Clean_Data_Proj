## Getting and Cleaning Data
## Course Project

## Introduction

This project delivers a tidy data set given the data collected from the accelerometers from the Samsung Galaxy S smartphone.

The tidy data sets are D1 and D2.

D1 is a 10299x68 dataframe partitioned by Measurement and each ordered by Subject.

D2 is the resulting 180x66 matrix of average for each activity and each subject.

A full description is available at the site where the data was obtained: 
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

## Description of the script
The steps that the script performs for the creation of the data set required are described here.

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

### Read input data into a table.

```
dir <- paste(dir, "UCI HAR Dataset", sep="")
#
Dat <- rbind(read.table(paste(dir, "/train/X_train.txt", sep=""), colClasses="numeric"),
             read.table(paste(dir, "/test/X_test.txt", sep=""), colClasses="numeric"))
```

There are no NAs in the numeric variables

```
> any(is.na(Dat[, 3:ncol(Dat)]))
[1] FALSE
```

There are no outlayers

```
> range(Dat[, 1:ncol(Dat)]))
[1] -1  1
```

#### Choose up features

features are variables names of the data set Dat.

```
features <- scan(paste(dir, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]
```

#### We are interested in those with "mean()" or "std()" in their names.

selcol keeps the index of those features

```
selcol <- grep("(mean|std)\\(\\)", features)
```
#### Convert features names to valid R names

make.names {base} can do it, but this is customized.
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

#### Read two fixed variables: Subject and Measurement

"Fixed variables come first"

measurements and subjects are help variables for loopings

#### Add Subject

```
Subject <- as.integer(c(scan(paste(dir, "/train/subject_train.txt", sep="")),
                        scan(paste(dir, "/test/subject_test.txt", sep=""))))
Dat$Subject <- Subject
subjects <- 1:30
```

selcol is the index of columns with "mean()" or "std()" in their names.

```
Dat <- cbind(as.data.frame(Subject), Dat[, selcol])
```
#### Add Measurement

```
Measurement <- factor(c(scan(paste(dir, "/train/y_train.txt", sep="")),
                        scan(paste(dir, "/test/y_test.txt", sep=""))))
levels(Measurement) <- scan(paste(dir, "/activity_labels.txt", sep=""),
                            what="character")[c(FALSE, TRUE)]
Dat$Measurement <- Measurement
measurements <- levels(Measurement)

Dat <- cbind(as.data.frame(Measurement), Dat)
```

### Data sets to be created.

D1 is the 10299x68 data set partitioned by Measurement and each ordered by Subject.

```
D1 <- data.frame()
```

D2 is the resulting 180x66 matrix of average for each activity and each subject.

```
D2 <- NULL 
```

### Split by Measurement

Observe that ordering like this
```
Dat[order(c(Dat$Measurement, Dat$Subject)), ]
```
then the job can be done without splitting but sub setting
```
colMeans(Dat[Dat[1] == measurement & Dat[2] == subject, 3:ncol(Dat)], na.rm = T)
```
would be costly in time.

Let's split

```
dat <- split(Dat, Measurement)
```


### Looping dat, the list of Measurement dataframes.

In each dataframe all rows of the Measurement column has the same value.

```
for(measurement in measurements){
    D <- dat[[measurement]]
```

order by Subject this Measurement

```
    D <- D[order(D[2]), ]
```
feeding up D1 with subsets of Measurement ordered by Subject.

```
    D1 <- rbind(D1, D) 
```

for each Subject in this Measurement calculate colMeans.

```
    for(subject in subjects){ 
        tmp <- colMeans(D[D[2] == subject, 3:ncol(D)])
```

this make posible to concatenate only the values

```
        names(tmp) <- NULL  ## !! important
```

feed up the matrix D2 with a new row

```
        D2 <- rbind(D2, tmp) 
```

#### Row names

rnames contains row names of D2, the resulting data set.

Names are like this "WALKING_UPSTAIRS.S_04".

```
        rnames <- c(rnames, 
                    paste(measurement, 
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
## The produced data sets are tidy because

1. Each variable forms a colummn
2. Each observation forms a row
3. Each type of observational unit forms a table.
