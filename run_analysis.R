######################################################################
# Getting and Cleaning Data Analisys                                 #
# Project script                                                     #
# deliver the required datasets: The data.frame D1 and the matrix D2 #
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
f <- scan(paste(Dir, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]
selcol <- grep("(mean|std)\\(\\)", f)  # Choose up features: we are interested 
                                       # in those with "mean()" or "std()" in their names.
# Convert features names to valid R names
# make.names {base} can do it, but this is costumized.
names(Dat) <- sapply(f,
                     function(s){
                         s <- gsub("\\(\\)", "", s)
                         s <- gsub("-", "_", s)
                         s <- gsub(",", ".", s)
                         s <- gsub("\\(|\\)", ".", s)
                         s <- s # none of above
                         s
                     })
# Add two new fixed variables columns: Subject & Measurement
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
# Create a subset of Dat called dat 
# Dat[, selcol] is a subset of columns with "mean()" or "std()" in their names.
# Append Subject column
dat <- cbind(as.data.frame(Subject), Dat[, selcol])
# Append Measurement column
dat <- cbind(as.data.frame(Measurement), dat)
#
# Split by Measurement
dat <- split(dat, Measurement)
#
D2 <- NULL  # D2 is the resulting 180x66 matrix average
            # of each variable for each activity and each subject. 
D1 <- data.frame()  # D1 is the 10299x68 dataset1
                    # partitioned by Measurement and each ordered by Subject.
for(i in 1:length(dat)){
    d <- dat[[i]]    # a Measurement
    o <- order(d[2]) # order by Subject this Measurement
    d <- d[o, ]
    D1 <- rbind(D1, d) # building up D1 
    for(j in 1:30){ # for each Subject in this Measurement calculate its columns means.
        m <- colMeans(d[d[2] == j, 3:ncol(d)])
        names(m) <- NULL
        D2 <- rbind(D2, m) # feed up the matrix D2 with a new row
    }
}
colnames(D2) <- colnames(D1)[3:ncol(D1)]
rownames(D2) <- NULL
#
write.table(D2, "D2_dataset.txt", sep =" ")
#