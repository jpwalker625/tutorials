#!/usr/bin/env Rscript

#
# Jabus Tyerman

source("/var/shiny-server/www/HTSevents/load_packages.R")
source("/var/shiny-server/www/HTSevents/hts_functions.R")

wd <- "/var/shiny-server/www/HTSeventsBETA/"
setwd(wd)

get_next_fail_id<- function() {
  con <- sql_getDataoutConnection() #linex connection, uses amyRis
  sql3 <- c("select max(fail_id) from [dataout].[easybake].[hts_et_fails]")
  res<- sqlQuery(con, sql3) 

  return(as.numeric(res)+1)
}

this.id <- get_next_fail_id()

fail <- list(
  fail_id= this.id, 
  event_id = 0, 
  failure_mode_id = 0,
  failure_value = "Fail",
  is_disabled = 0
)

sql <- paste("INSERT INTO easybake.hts_et_fails VALUES (", unlist(fail$fail_id), ", ", unlist(fail$event_id),",", unlist(fail$failure_mode_id),",'", unlist(fail$failure_value), "',", unlist(fail$is_disabled), ")", sep="")

con <- sql_getDataoutConnection() #linex connection, uses amyRis
x <- sqlQuery(con, sql) 
odbcCloseAll()

print(x)



