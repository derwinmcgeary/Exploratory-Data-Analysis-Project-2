### Analysis starts on line 23
# I'm developing on Ubuntu, and I don't know what you're running, dear reader, so for compatibility...
if('downloader'%in%installed.packages()[,1]){
  library("downloader")
} else {
  install.packages("downloader")
  library("downloader")
}

# We don't want to download 29MB every time! If you already have the file, you can rename it to
# "NEI_data.zip" and put it in the working directory
dataurl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
zipfile <- "NEI_data.zip"
if(file.exists(zipfile)) { print("We already have the file") } else {
  download(dataurl, zipfile ,mode="wb")
}

datafiles <- unzip(zipfile)
print(datafiles)
SCC <- readRDS(datafiles[1])
NEI <- readRDS(datafiles[2])

######### Analysis starts here ###########################################
png(filename="plot2.png")
# We're only interested in Baltimore (fips 24510)
sub <- subset(NEI, fips == "24510", select=c(Emissions,year))
# aggregate() does most of the work
itds <- aggregate(sub$Emissions, by = list(Year = sub$year), FUN = sum)

colnames(itds) <- c("Year", "Total Emissions")
plot(itds)
title(main="Total emissions in Baltimore")
abline(lm(`Total Emissions` ~ Year, data=itds), col="blue")

dev.off()
