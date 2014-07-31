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
# Choose up features: we are interested
# in those with "mean()" or "std()" in their names.
Dat <- Dat[, grep("(mean|std)\\(\\)", features)]
#
# Subject and Measurement
Subject <- as.integer(c(scan(paste(dir, "/train/subject_train.txt", sep="")),
                        scan(paste(dir, "/test/subject_test.txt", sep=""))))
#
Measurement <- factor(c(scan(paste(dir, "/train/y_train.txt", sep="")),
                        scan(paste(dir, "/test/y_test.txt", sep=""))))
levels(Measurement) <- scan(paste(dir, "/activity_labels.txt", sep=""),
                            what="character")[c(FALSE, TRUE)]
#
# D2 is the resulting data set
D2 <- aggregate(Dat, by = list(interaction(Subject, Measurement)), mean)
#
rownames(D2) <- D2[, 1]
D2[1] <- NULL
#
# write.table(D2, "D2_dataset.txt", sep =" ")
#