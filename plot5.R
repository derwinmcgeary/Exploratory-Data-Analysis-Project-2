# I'm developing on Ubuntu, and I don't know what you're running, dear reader, so for compatibility...
if('downloader'%in%installed.packages()[,1]){
  library("downloader")
} else {
  install.packages("downloader")
  library("downloader")
}
library(ggplot2)
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

## find all SCC values in SCC where Data.Category is "Onroad"

## subset NEI to include only rows where type == ON-ROAD AND fips == "24510", plus Emissions and Year
baltimore_cars <- subset(NEI, fips == "24510" & type == "ON-ROAD", select=c(Emissions,year))
## aggregate by year
output <- aggregate(baltimore_cars$Emissions, by = list(Year = baltimore_cars$year), FUN = sum)
colnames(output) <- c("Year", "Emissions")
## and plot
png(filename="plot5.png")
g <- qplot(Year, Emissions, data = output) + geom_smooth(method = "lm") + labs(title = "Baltimore motor vehicle emissions")
print(g)
dev.off()
