# I'm developing on Ubuntu, and I don't know what you're running, dear reader, so for compatibility...
if('downloader'%in%installed.packages()[,1]){
  library("downloader")
} else {
  install.packages("downloader")
  library("downloader")
}
library(ggplot2)
library(stringi)
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

## find all SCC values in SCC where Short.Name includes "Coal" (or "coal")
coalscc <- subset(SCC, stri_detect_regex(Short.Name,"Coal", case_insensitive=TRUE), select = c(SCC))
coalsccs <- coalscc$SCC
## subset NEI to include only the above SCC values, plus Emissions and Year
coalnei <- subset(NEI, SCC%in%coalsccs, select = c(Emissions,year))
## aggregate by year
coalnei_agg <- aggregate(coalnei$Emissions, by = list(Year = coalnei$year), FUN = sum)
colnames(coalnei_agg) <- c("Year", "Emissions")
## and plot
f <- qplot(Year, Emissions, data = coalnei_agg) + geom_smooth(method = "lm") + labs(title = "Coal Emissions in the USA")
print(f)