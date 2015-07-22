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
# I want to take the mean for each Location, and ave() is a nice way to do it
output$mean <- ave(output$Emissions, output$Location, FUN=mean)

## Emissions isn't a great measurement to plot because the absolute values are so different

output$Normalised <- output$Emissions/output$mean
# Normalising the Emissions by dividing by the mean gives us
# something we can plot side-by-side
# but that means the vertical scales of the two plots are different

output$Equalised <- output$Emissions - output$mean
# So instead I simply subtract the mean, placing the two curves on one level
# but preserving the vertical scale

## and plot
png(filename="plot6.png")
qplot(Year, 
           Emissions, 
           data = output, 
           color = Location, 
           facets = Location ~ .) + facet_grid(Location ~ ., scales="free_y") +
  geom_smooth(method="lm") + # + geom_smooth(method = "lm")
  labs(title = "Relative Change in Motor Vehicle Emissions in Baltimore and LA, 1999-2008")
dev.off()
