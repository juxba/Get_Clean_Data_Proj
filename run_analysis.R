#########################################
# Getting and Cleaning Data Analisys    #
# Project script                        #    
#########################################
p <- paste(getwd(), "/", sep="")
# Get the file if not already here
if (!file.exists(paste(p, "UCI HAR Dataset", sep=""))) {
    sc <- scan("","It can take a while, continue Y/n? ")
    if(sc != "Y") stop("This terminates execution")
    
    ptmp <- paste(p, "/tmp.zip", sep="")
    # Download file, unzip and remove the temporary file
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = ptmp, method = "wget")
    unzip(ptmp)
    file.remove(ptmp)
}
## Reading data part
p <- paste(p, "UCI HAR Dataset", sep="")
#
Dat <- rbind(read.table(paste(p, "/train/X_train.txt", sep=""), colClasses="numeric"),
             read.table(paste(p, "/test/X_test.txt", sep=""), colClasses="numeric"))
#
f <- scan(paste(p, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]
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
Subject <- as.integer(c(scan(paste(p, "/train/subject_train.txt", sep="")),
                        scan(paste(p, "/test/subject_test.txt", sep=""))))
Dat$Subject <- Subject
#
Measurement <- factor(c(scan(paste(p, "/train/y_train.txt", sep="")),
                        scan(paste(p, "/test/y_test.txt", sep=""))))
levels(Measurement) <- scan(paste(p, "/activity_labels.txt", sep=""),
                            what="character")[c(FALSE, TRUE)]
Dat$Measurement <- Measurement
#
# Dat[, selcol] is a subset of columns with "mean()" or "std()" in their names.
Dat1 <- cbind(as.data.frame(Subject), Dat[, selcol])
#
Dat1 <- cbind(as.data.frame(Measurement), Dat1)
#
# Split by Measurement
Dat1 <- split(Dat1, Measurement)
#
D2 <- NULL  # D2 is the resulting 180x66 matrix average
            # of each variable for each activity and each subject. 
D1 <- data.frame()  # D1 is the 10299x68 dataset1
                    # partitioned by Measurement and each ordered by Subject.
for(i in 1:length(Dat1)){
    d <- Dat1[[i]]
    o <- order(d[2]) # order by Subject this Measurement
    d <- d[o, ]
    D1 <- rbind(D1, d) # building up D1 
    for(j in 1:30){ # for each Subject in this Measurement calculate its columns means.
        m <- NULL
        for(k in 3:ncol(d)) # for each numeric column take the mean.
            m <- c(m, mean(d[d[2] == j, k]))
        D2 <- rbind(D2, m) # build up the matrix D2 with a new row
    }
}
colnames(D2) <- colnames(D1)[3:ncol(D1)]
rownames(D2) <- NULL
#
write.table(D2, "D2_dataset.txt", sep =" ")
#