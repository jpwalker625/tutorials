#!/usr/bin/env Rscript

#
# Jabus Tyerman

source("/var/shiny-server/www/HTSevents/load_packages.R")
source("/var/shiny-server/www/HTSevents/hts_functions.R")

wd <- "/var/shiny-server/www/HTSevents/"
setwd(wd)


x <- read.csv("HTS_events_failure_modes_list_jabus_2014-01-14.csv",stringsAsFactors = FALSE, header=TRUE)


for (i in 1:nrow(x)){
  sql <- paste("INSERT INTO easybake.hts_et_failure_modes VALUES ('",x[i,1], "','", x[i,2], "','", x[i,3],"', NULL, '",  x[i,5], "')", sep="")
  res<- pull(sql)
}

