library(dplyr)
#rm(list = ls(all = TRUE))
getCPCData <- function(url, var) {

  #Reading the HTML code from the website
  tmp <- xml2::read_html(url)
  tmpData <- tmp %>%
    rvest::html_nodes(xpath = "/html/body") %>%
    rvest::html_text()

  # format -------------------------------------------------------------------------------------------
  tmpData2 <- unlist(strsplit(tmpData, split = "\n"))

  # ---- get names ...
  Names <- tmpData2[2]
  Names <- unlist(strsplit(Names, split = " |  |   |    |     |      "))
  Names <- Names[!Names %in% c("F", "C")]
  Names[19:22] <- paste0(rep(c('Forecasted', 'Climatological'),2), Names[19:22])

  # finish formatting
  tmpData2 <- tmpData2[-(1:2)]
  tmpData3 <- unlist(strsplit(tmpData2, split = " |  |   "))

  if(any(nchar(tmpData3) > 7)){
    tmpData4 <- c()
    for(i in 1:length(tmpData3)) {

        if(nchar(tmpData3[i]) > 7) {
          if(nchar(tmpData3[i]) <= 13) {

            x <- substring(tmpData3[i], c(1, 7), c(6, 13))
          } else {

            x <- substring(tmpData3[i], c(1, 7, 14), c(6, 13, 19))
          }
          print(i)
          print(x)
        } else {
            x <- tmpData3[i]
            }

      tmpData4 <- c(tmpData4, x)
    }
  } else {
    tmpData4 <- tmpData3
  }

  tmpData4 <- matrix(tmpData4, ncol = 1326)
  tmpData4 <- t(tmpData4)

  tmpData4 <- data.frame(tmpData4, stringsAsFactors = FALSE)
  names(tmpData4) <- Names
  tmpData4[] <- lapply(tmpData4, as.numeric)

  if(var == 'temp'){ #
   # tmpData4[,c('ForecastedMEAN', 'ClimatologicalMEAN', 'ForecastedSD', 'ClimatologicalSD')] <- (tmpData4[,c('ForecastedMEAN', 'ClimatologicalMEAN', 'ForecastedSD', 'ClimatologicalSD')] - 32) * (5/9)
    tmpData4 <- tmpData4[,c('YEAR', 'MN', 'LEAD', 'CD','ForecastedMEAN', 'ClimatologicalMEAN', 'ForecastedSD', 'ClimatologicalSD')]
    }
  if(var == 'ppt'){
    #tmpData4[,c('ForecastedMEAN', 'ClimatologicalMEAN', 'ForecastedSD', 'ClimatologicalSD')] <- tmpData4[,c('ForecastedMEAN', 'ClimatologicalMEAN', 'ForecastedSD', 'ClimatologicalSD')] * 2.54
    tmpData4 <- tmpData4[,c('YEAR', 'MN', 'LEAD', 'CD','ForecastedMEAN', 'ClimatologicalMEAN', 'ForecastedSD', 'ClimatologicalSD', 'PO')]
    }

  # get anomalies ------------------------------------------------------------------------------------------
  tmpData4 <- tmpData4[order(tmpData4$CD, tmpData4$LEAD),]

 # tmpData4 <- tmpData4[,c('YEAR', 'MN', 'LEAD', 'CD', 'AnomalyMEAN', 'AnomalySD')]
  tmpData4

}

tempurl <- 'https://www.cpc.ncep.noaa.gov/pacdir/NFORdir/HUGEdir2/cpcllftd.dat'
tempData <- getCPCData(tempurl, 'temp')
#summary(tempData)

ppturl <- 'https://www.cpc.ncep.noaa.gov/pacdir/NFORdir/HUGEdir2/cpcllfpd.dat'
pptData <- getCPCData(ppturl, 'ppt')
#summary(pptData)

write.csv(tempData, 'main/CurrentAnomalyTempData.csv', row.names = FALSE) # farenheit
write.csv(pptData, 'main/CurrentAnomalyPPTData.csv', row.names = FALSE) # inches

#write.csv(tempData, '/usr/local/app/STDF/shorttermdroughtforecaster/CurrentAnomalyTempData.csv', row.names = FALSE) # farenheit
#write.csv(pptData, '/usr/local/app/STDF/shorttermdroughtforecaster/CurrentAnomalyPPTData.csv', row.names = FALSE) # inches
