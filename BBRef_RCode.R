library(XML)
library(RCurl)
library(rlist)
library(Lahman)
library(tidyverse)
library(openxlsx)
teams <- unique(Teams$franchID)
years <- 1871:2017

urls <- matrix(0, length(teams), length(years))
for(i in 1:length(teams)) {
  for(j in 1:length(years)) {
    urls[i, j] <- paste0("https://www.baseball-reference.com/teams/", teams[i], "/", years[j], ".shtml")
  }
}
url_vector <- as.vector(urls)

list_of_batting <- list()
list_of_pitching <- list()
for(i in 1:5000) {
  url <- url_vector[i]
  
  res <- try(readLines(url), silent = TRUE)
  
  ## check if website exists
  if(inherits(res, "try-error")) {
    list_of_batting[[i]] <- NA
    list_of_pitching[[i]] <- NA
  }
  else {
    urltxt <- readLines(url)
    urltxt <- gsub("-->", "", gsub("<!--", "", urltxt))
    doc <- htmlParse(urltxt)
    tables_full <- readHTMLTable(doc)
    tmp1 <- tables_full$players_value_batting
    tmp2 <- tables_full$players_value_pitching
    list_of_batting[[i]] <- tmp1
    list_of_pitching[[i]] <- tmp2
  }
  print(i)
  closeAllConnections()
}

for(i in 5001:10000) {
  url <- url_vector[i]
  
  res <- try(readLines(url), silent = TRUE)
  
  ## check if website exists
  if(inherits(res, "try-error")) {
    list_of_batting[[i]] <- NA
    list_of_pitching[[i]] <- NA
  }
  else {
    urltxt <- readLines(url)
    urltxt <- gsub("-->", "", gsub("<!--", "", urltxt))
    doc <- htmlParse(urltxt)
    tables_full <- readHTMLTable(doc)
    tmp1 <- tables_full$players_value_batting
    tmp2 <- tables_full$players_value_pitching
    list_of_batting[[i]] <- tmp1
    list_of_pitching[[i]] <- tmp2
  }
  print(i)
  closeAllConnections()
}

for(i in 10001:17640) {
  url <- url_vector[i]
  
  res <- try(readLines(url), silent = TRUE)
  
  ## check if website exists
  if(inherits(res, "try-error")) {
    list_of_batting[[i]] <- NA
    list_of_pitching[[i]] <- NA
  }
  else {
    urltxt <- readLines(url)
    urltxt <- gsub("-->", "", gsub("<!--", "", urltxt))
    doc <- htmlParse(urltxt)
    tables_full <- readHTMLTable(doc)
    tmp1 <- tables_full$players_value_batting
    tmp2 <- tables_full$players_value_pitching
    list_of_batting[[i]] <- tmp1
    list_of_pitching[[i]] <- tmp2
  }
  print(i)
  closeAllConnections()
}

## find indices where the link exists
ind_batting <- which(!is.na(list_of_batting))
ind_pitching <- which(!is.na(list_of_pitching))

## find links that exist
url_batting <- url_vector[ind_batting]
url_pitching <- url_vector[ind_pitching]

## extract year from each url
years_batting <- as.numeric(unlist(regmatches(url_batting, gregexpr("[[:digit:]]+", url_batting))))
years_pitching <- as.numeric(unlist(regmatches(url_pitching, gregexpr("[[:digit:]]+", url_pitching))))

## extract team from each url
teams_batting <- basename(dirname(url_batting))
teams_pitching <- basename(dirname(url_pitching))

## remove NAs from lists
na.omit.list <- function(y) { 
  return(y[!sapply(y, function(x) all(is.na(x)))]) 
}

test_batting <- na.omit.list(list_of_batting)
test_pitching <- na.omit.list(list_of_pitching)

## add columns for year and team
test_batting <- mapply(cbind, test_batting, "Year" = years_batting, 
                       "Team" = teams_batting, SIMPLIFY = F)
test_pitching <- mapply(cbind, test_pitching, "Year" = years_pitching,
                        "Team" = teams_pitching, SIMPLIFY = F)

bbref_batting <- bind_rows(test_batting)
bbref_pitching <- bind_rows(test_pitching)

setwd("~/Downloads/Baseball Data")
write.xlsx(bbref_batting, "BBRef_Batting.xlsx")
write.xlsx(bbref_pitching, "BBRef_Pitching.xlsx")

df_bbref_batting <- read.xlsx("BBRef_Batting.xlsx", na.strings = c("--", ""))
df_bbref_batting <- df_bbref_batting %>%
  mutate(Age = as.numeric(Age),
         WAR = as.numeric(WAR),
         oWAR = as.numeric(oWAR),
         dWAR = as.numeric(dWAR),
         Salary = as.numeric(gsub('\\$|,', '', Salary)))

df_bbref_pitching <- read.xlsx("BBRef_Pitching.xlsx", na.strings = c("--", ""))
df_bbref_pitching <- df_bbref_pitching %>%
  mutate(Age = as.numeric(Age),
         WAR = as.numeric(WAR),
         Salary = as.numeric(gsub('\\$|,', '', Salary)))

# save(list_of_batting, list_of_pitching, file = "BBallRef.RData")
# save.image()