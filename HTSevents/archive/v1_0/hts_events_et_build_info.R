#!/usr/bin/env Rscript

#add build info to database

source("/var/shiny-server/www/HTSevents/load_packages.R")
source("/var/shiny-server/www/HTSevents/hts_functions.R")

wd <- "/var/shiny-server/www/HTSevents/"
setwd(wd)

vers <- c("1.1")

build<- list(
  db_info_id <- 1,
  build_date <- as.character(Sys.time()), 
  build_version <- vers,
  author <- c("Jabus Tyerman")
)

sql <- paste("INSERT INTO easybake.hts_et_build_info VALUES ('", paste(build, collapse="','"), "')", sep="")

x <- pull(sql)
print(x)
