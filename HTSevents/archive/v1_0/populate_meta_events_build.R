#!/usr/bin/env Rscript

#
# Jabus Tyerman

source("/var/shiny-server/www/HTSevents/load_packages.R")
source("/var/shiny-server/www/HTSevents/hts_functions.R")

wd <- "/var/shiny-server/www/HTSevents/"
setwd(wd)

sql <- paste("INSERT INTO easybake.hts_et_meta_events VALUES (0,'",
as.POSIXct(Sys.time()),"','",
as.POSIXct(Sys.time()),"','",
as.POSIXct(Sys.time()),"','",
as.POSIXct(Sys.time()),
"', 'Jabus', 'Build')",
sep="")

res<- pull(sql)


