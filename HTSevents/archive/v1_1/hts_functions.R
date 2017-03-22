#functions for HTSevents


#quick pull from dataout, given a sql query (sql)
pull <- function(sql) {
require(amyRis)
con <- sql_getDataoutConnection() #linus connection, uses amyRis
#con <- odbcDriverConnect(connection = "DRIVER=SQL Server;SERVER=sqlwarehouse1.amyris.local;UID=hts_qc;PWD=htsqc;DATABASE=dataout") ##windows connection command
result <- sqlQuery(con, sql)
odbcCloseAll()
result
}

get_end_times <- function() {#Isaac Newton's prediction for end of the world
  as.POSIXct("2060-01-01")
}

