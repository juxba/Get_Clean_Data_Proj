# p <- setwd()
p <- "/home/julio/MOOCs/Coursera/Getting and Cleaning Data/workingdir/Proj/"

# Get the file if not already here
if (!file.exists(paste(p, "UCI HAR Dataset", sep=""))) {
    sc <- scan("","It can take a while, continue Y/n? ")
    if(sc != "Y") stop("This terminates execution") 
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    ptmp <- paste(p, "/tmp.zip", sep="")
    download.file(fileUrl, destfile = ptmp, method = "wget")
    unzip(ptmp)
    file.remove(ptmp)
}
p <- paste(p, "UCI HAR Dataset", sep="")
#
Dat <- rbind(read.table(paste(p, "/train/X_train.txt", sep=""), colClasses="numeric"),
             read.table(paste(p, "/test/X_test.txt", sep=""), colClasses="numeric"))
#
f <- scan(paste(p, "/features.txt", sep=""), what="character")[c(FALSE, TRUE)]
ind <- grep("(mean|std)\\(\\)", f)
names(Dat) <- sapply(f, # make.names {base} could do, but this is costumized
                     function(s){
                                s <- gsub("\\(\\)", "", s)
                                s <- gsub("-", "_", s)
                                s <- gsub(",", ".", s)
                                s <- gsub("\\(|\\)", ".", s)
                                s <- s # none of above
                                s
                    })
#
dummy <- c(scan(paste(p, "/train/subject_train.txt", sep="")),
         scan(paste(p, "/test/subject_test.txt", sep="")))
Subject <- factor(dummy)
#levels(Subject) <- paste("S.", levels(Subject), sep="")
Dat$Subject <- Subject
Sortcol <- as.integer(dummy)
Dat$Sortcol <- Sortcol
#
Measurement <- factor(c(scan(paste(p, "/train/y_train.txt", sep="")),
                         scan(paste(p, "/test/y_test.txt", sep=""))))
levels(Measurement) <- scan(paste(p, "/activity_labels.txt", sep=""),
                             what="character")[c(FALSE, TRUE)]
Dat$Measurement <- Measurement
#
Ds1 <- cbind(as.data.frame(Subject), Dat[, ind])
Ds1 <- cbind(as.data.frame(Measurement), Ds1)
Ds1 <- cbind(as.data.frame(Sortcol), Ds1)
Ds1 <- split(Ds1, Measurement)
#
D1 <- data.frame()
for(i in 1:length(Ds1)){
    D1 <- rbind(D1, Ds1[[i]])
}

Ds2 <- lapply(Ds1, function(x) split(x, x$Subject))

D2 <- data.frame()
Res <- NULL
for(i in 1:length(Ds2)){
    d2 <- data.frame()
    for(j in 1:length(Ds2[[i]])){
        df <- Ds2[[i]][[j]]
        d2 <- rbind(d2, df)
    }
    o <- order(d2$Sortcol)
    D2 <- rbind(D2, d2[o, ])
    M <- d2[o, ]
    for(j in 1:30){
        m <- NULL
        for(k in 4:ncol(M))
            m <- c(m, mean(M[M[1] == j, k], na.rm = TRUE))
        Res <- rbind(Res, m)
        colnames(Res) <- names(D1)[4:ncol(D1)]
    }
}

#
#write.csv(Res, "result.csv")
#