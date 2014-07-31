############################################################################
# Getting and Cleaning Data Analisys                                       #
# Project script                                                           #
#                                     # only!                              #
# delivers the required tidy dataset: the matrix D2                        #
############################################################################
dir <- paste(getwd(), "/", sep="")
# Get the files if not already here
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
## Reading data part
dir <- paste(dir, "UCI HAR Dataset", sep="")
#
Dat <- rbind(read.table(paste(dir, "/train/X_train.txt", sep=""), colClasses="numeric"),
             read.table(paste(dir, "/test/X_test.txt", sep=""), colClasses="numeric"))
#
features <- scan(paste(dir, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]
# Choose up features: we are interested
# in those with "mean()" or "std()" in their names.
selcol <- grep("(mean|std)\\(\\)", features)
#
# Convert features names to valid R names
# make.names {base} can do it, but this is costumized.
names(Dat) <- sapply(features,
                     function(s){
                         s <- gsub("\\(\\)", "", s)
                         s <- gsub("-", "_", s)
                         s <- gsub(",", ".", s)
                         s <- gsub("\\(|\\)", ".", s)
                         s <- s # none of above
                         s
                     })
# Add two fixed variables columns: Subject and Measurement
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
#
# Append Subject column
# selcol is the index of columns with "mean()" or "std()" in their names.
# "Fixed variables come first"
# Dat <- cbind(as.data.frame(Subject), Dat[, selcol])
Dat <- cbind(Subject, Dat[, selcol])
# Append Measurement column
Dat <- cbind(Measurement, Dat)
#
# Split by Measurement
dat <- split(Dat, Measurement)
#
# These two are the datasets to be delivered
D2 <- NULL 
# D2 is the resulting 180x66 matrix
# of average for each activity and each subject. 
#
x <- lapply(dat,
            function(y) sapply(y[3:ncol(y)],
                               function(z) tapply(z, y$Subject, mean)))
for(i in 1:length(x))
    D2 <- rbind(D2, x[[i]])
#
# D2 <- rbind(x$WALKING, x$WALKING_UPSTAIRS, x$WALKING_DOWNSTAIRS,
#             x$SITTING, x$STANDING, x$LAYING)
#
rnames <- NULL # row names
for(measurement in measurements){
    for(subject in subjects){
        rnames <- c(rnames, 
                    paste(measurement, # ex. produces "WALKING_UPSTAIRS.S_04"
                          ifelse(subject < 10, ".S_0", ".S_"),
                          subject,
                          sep=""))
    }
}
#
# Assign names to rows and columns
rownames(D2) <- rnames
colnames(D2) <- colnames(Dat)[3:ncol(Dat)]
#
# write.table(D2, "D2_dataset.txt", sep =" ")
#