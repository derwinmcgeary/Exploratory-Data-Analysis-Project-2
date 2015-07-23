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

##### To business!
baltimore <- subset(NEI, fips == "24510", select=c(Emissions,year, type))
baltimore_agg <- aggregate(baltimore$Emissions, by = list(Year = baltimore$year, Type = baltimore$type), FUN = sum)
colnames(baltimore_agg) <- c("Year", "Type", "Emissions")
g <- qplot(Year, Emissions, data = baltimore_agg, facets = .~ Type) + geom_smooth(method = "lm")
print(g)
# usa_agg <- aggregate(NEI$Emissions, by = list(Year = NEI$year, Type = NEI$type), FUN = sum)
# colnames(usa_agg) <- c("Year", "Type", "Emissions")
# h <- qplot(Year, Emissions, data = usa_agg, facets = .~ Type) + geom_smooth(method = "lm")
# h + labs(title = "Emissions by year and type")