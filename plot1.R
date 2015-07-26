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
# aggregate() is a very handy function
itds <- aggregate(NEI$Emissions, by = list(Year = NEI$year), FUN = sum)
colnames(itds) <- c("Year", "Total Emissions")
# and plot it
png(filename="plot1.png")
plot(itds)
abline(lm(`Total Emissions` ~ Year, data=itds), col="blue")
dev.off()
