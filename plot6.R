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

## subset NEI to include only rows where type == ON-ROAD AND fips == "24510" or
## fips == "06037", plus Emissions and Year

baltimore_la_cars <- subset(NEI, fips%in%c("24510","06037") & type == "ON-ROAD", select=c(fips, year, Emissions))

## aggregate by year
output <- aggregate(baltimore_la_cars$Emissions, by = list(Year = baltimore_la_cars$year, Locale = baltimore_la_cars$fips), FUN = sum)
colnames(output) <- c("Year", "Location", "Emissions")
output$Location <- gsub("24510","Baltimore",output$Location)
output$Location <- gsub("06037","LA County",output$Location)
output$Location <- factor(output$Location)
# I want to take the mean for each Location, there has GOT to be a better way
output$mean[output$Location == "LA County"] <- mean(output$Emissions[output$Location == "LA County"])
output$mean[output$Location == "Baltimore"] <- mean(output$Emissions[output$Location == "Baltimore"])
output$Normalised <- output$Emissions/output$mean
output$Equalised <- output$Emissions - output$mean
## and plot
i <- qplot(Year, 
           Equalised, 
           data = output, 
           color = Location, 
           facets = .~ Location) + 
  geom_smooth(method="lm") + # + geom_smooth(method = "lm")
  labs(title = "Relative Change in Motor Vehicle Emissions in Baltimore and LA, 1999-2008")
print(i)