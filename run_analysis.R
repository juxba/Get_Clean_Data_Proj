######################################################################
# Getting and Cleaning Data Analisys                                 #
# Project script                                                     #
# delivers the required datasets: The data.frame D1 and the matrix D2 #
######################################################################
Dir <- paste(getwd(), "/", sep="")
# Get the file if not already here
if (!file.exists(paste(Dir, "UCI HAR Dataset", sep=""))) {
    sc <- scan("","It can take a while, continue Y/n? ")
    if(sc != "Y") stop("This terminates execution")
    
    tmp <- paste(Dir, "tmp.zip", sep="")
    # Download file, unzip and remove the temporary file
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = tmp, method = "wget")
    unzip(tmp)
    file.remove(tmp)
}
## Reading data part
Dir <- paste(Dir, "UCI HAR Dataset", sep="")
#
Dat <- rbind(read.table(paste(Dir, "/train/X_train.txt", sep=""), colClasses="numeric"),
             read.table(paste(Dir, "/test/X_test.txt", sep=""), colClasses="numeric"))
#
features <- scan(paste(Dir, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]
selcol <- grep("(mean|std)\\(\\)", features)  # Choose up features: we are interested 
                                       # in those with "mean()" or "std()" in their names.
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
# "Fixed variables come first"
Subject <- as.integer(c(scan(paste(Dir, "/train/subject_train.txt", sep="")),
                        scan(paste(Dir, "/test/subject_test.txt", sep=""))))
Dat$Subject <- Subject
#
Measurement <- factor(c(scan(paste(Dir, "/train/y_train.txt", sep="")),
                        scan(paste(Dir, "/test/y_test.txt", sep=""))))
levels(Measurement) <- scan(paste(Dir, "/activity_labels.txt", sep=""),
                            what="character")[c(FALSE, TRUE)]
Dat$Measurement <- Measurement
#
# This two are the datasets to be delivered
D2 <- NULL      # D2 is the resulting 180x66 matrix
                # of average for each activity and each subject. 
D1 <- data.frame()  # D1 is the 10299x68 dataset1
                    # partitioned by Measurement and each ordered by Subject.
#
# Create a subset of Dat called dat
#
# Dat[, selcol] is a subset of columns with "mean()" or "std()" in their names.
# Append Subject column
Dat <- cbind(as.data.frame(Subject), Dat[, selcol])
# Append Measurement column
Dat <- cbind(as.data.frame(Measurement), Dat)
#
# Split by Measurement
dat <- split(Dat, Measurement)
#
# Programmatly access to the list dat
for(measurement in 1:length(dat)){
    d <- dat[[measurement]]
#    o <- order(d[2]) # order by Subject this Measurement
    d <- d[order(d[2]), ]
    D1 <- rbind(D1, d) # feeding up D1 with subsets of Measurement ordered by Subject.  
    for(subject in 1:30){ # for each Subject in this Measurement calculate colMeans.
        m <- colMeans(d[d[2] == subject, 3:ncol(d)])
        names(m) <- NULL  ## !! important
        D2 <- rbind(D2, m) # feed up the matrix D2 with a new row
    }
}
# Assign names to columns and rows of D2
# Columns
colnames(D2) <- colnames(D1)[3:ncol(D1)]
# Rows
rnames <- NULL
for(level in levels(Measurement))
    for(subject in 1:30)
        rnames <- c(rnames, paste(level, ".S_", subject, sep=""))
rownames(D2) <- rnames
#
write.table(D2, "D2_dataset.txt", sep =" ")
#